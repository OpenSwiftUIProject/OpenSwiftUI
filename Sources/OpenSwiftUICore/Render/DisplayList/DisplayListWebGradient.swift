//
//  DisplayListWebGradient.swift
//  OpenSwiftUICore
//
//  Status: WIP

#if os(WASI)
package import Foundation
package import OpenCoreGraphicsShims

// MARK: - Web gradient paints [TBA]

package struct WebResolvedGradient {
    package enum Geometry {
        case linear(start: CGPoint, end: CGPoint)
        case radial(center: CGPoint, startRadius: CGFloat, endRadius: CGFloat)
        case elliptical(center: CGPoint, size: CGSize, startRadiusFraction: CGFloat, endRadiusFraction: CGFloat)
        case angular(center: CGPoint, angle: Double)
    }

    package var geometry: Geometry
    package var stops: [ResolvedGradient.Stop]
}

extension AnyResolvedPaint {
    package func webGradient(bounds: CGRect, opacity: Float) -> WebResolvedGradient? {
        var visitor = WebGradientPaintVisitor(bounds: bounds)
        visit(&visitor)
        guard var result = visitor.result else { return nil }
        for index in result.stops.indices {
            result.stops[index].color = result.stops[index].color.multiplyingOpacity(by: opacity)
        }
        return result
    }
}

private struct WebGradientPaintVisitor: ResolvedPaintVisitor {
    var bounds: CGRect
    var result: WebResolvedGradient?

    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
        result = (paint as? any WebGradientPaint)?.webGradient(bounds: bounds)
    }
}

private protocol WebGradientPaint {
    func webGradient(bounds: CGRect) -> WebResolvedGradient?
}

extension AnchoredResolvedPaint: WebGradientPaint {
    fileprivate func webGradient(bounds outerBounds: CGRect) -> WebResolvedGradient? {
        // Match draw(...): the inner paint's anchor replaces the shape bounds.
        (paint as? any WebGradientPaint)?.webGradient(bounds: bounds)
    }
}

extension LinearGradient._Paint: WebGradientPaint {
    fileprivate func webGradient(bounds: CGRect) -> WebResolvedGradient? {
        let start = startPoint.in(bounds)
        let end = endPoint.in(bounds)
        guard start.isWebFinite, end.isWebFinite,
              let stops = gradient.webStops() else { return nil }
        return WebResolvedGradient(geometry: .linear(start: start, end: end), stops: stops)
    }
}

extension RadialGradient._Paint: WebGradientPaint {
    fileprivate func webGradient(bounds: CGRect) -> WebResolvedGradient? {
        let center = center.in(bounds)
        guard center.isWebFinite,
              startRadius.isFinite, endRadius.isFinite,
              startRadius >= 0, endRadius >= 0,
              let stops = gradient.webStops() else { return nil }
        return WebResolvedGradient(
            geometry: .radial(center: center, startRadius: startRadius, endRadius: endRadius),
            stops: stops
        )
    }
}

extension EllipticalGradient._Paint: WebGradientPaint {
    fileprivate func webGradient(bounds: CGRect) -> WebResolvedGradient? {
        let center = center.in(bounds)
        let size = bounds.size
        guard center.isWebFinite,
              size.width.isFinite, size.height.isFinite,
              size.width != 0, size.height != 0,
              startRadiusFraction.isFinite, endRadiusFraction.isFinite,
              startRadiusFraction >= 0, endRadiusFraction >= 0,
              let stops = gradient.webStops() else { return nil }
        // Match EllipticalGradient._Paint.draw: fractions are measured in a
        // unit square stretched independently to the paint bounds' two axes.
        return WebResolvedGradient(
            geometry: .elliptical(
                center: center,
                size: size,
                startRadiusFraction: startRadiusFraction,
                endRadiusFraction: endRadiusFraction
            ),
            stops: stops
        )
    }
}

extension AngularGradient._Paint: WebGradientPaint {
    fileprivate func webGradient(bounds: CGRect) -> WebResolvedGradient? {
        guard startAngle.radians.isFinite, endAngle.radians.isFinite else { return nil }
        let conic = ConicGradient(angular: self, bounds: bounds)
        guard conic.center.isWebFinite, conic.angle.radians.isFinite,
              let stops = conic.gradient.webStops(
                  reversingEqualOffsets: endAngle.radians < startAngle.radians
              ) else { return nil }
        return WebResolvedGradient(
            geometry: .angular(center: conic.center, angle: conic.angle.radians),
            stops: stops
        )
    }
}

private extension CGPoint {
    var isWebFinite: Bool { x.isFinite && y.isFinite }
}

private extension ResolvedGradient {
    func webStops(reversingEqualOffsets: Bool = false) -> [Stop]? {
        guard !stops.isEmpty,
              stops.allSatisfy({ stop in
                  stop.location.isFinite && stop.color.linearRed.isFinite &&
                  stop.color.linearGreen.isFinite && stop.color.linearBlue.isFinite &&
                  stop.color.opacity.isFinite && (stop.interpolation.map {
                      $0.p1x.isFinite && $0.p1y.isFinite && $0.p2x.isFinite && $0.p2y.isFinite
                  } ?? true)
              }) else { return nil }
        // ConicGradient reverses offsets without reversing its stop array.
        // Also reverse equal-offset order in that case so hard color edges
        // reverse direction; all other paints retain their original tie order.
        let ordered = stops.enumerated().sorted {
            $0.element.location == $1.element.location
                ? (reversingEqualOffsets ? $0.offset > $1.offset : $0.offset < $1.offset)
                : $0.element.location < $1.element.location
        }.map(\.element)
        var result: [Stop] = []
        func append(_ color: Color.Resolved, at location: CGFloat) {
            result.append(Stop(color: color, location: location))
        }
        if ordered[0].location >= 0 {
            append(ordered[0].color, at: 0)
        }
        for index in ordered.indices.dropFirst() {
            let lower = ordered[index - 1]
            let upper = ordered[index]
            let start = max(0, lower.location)
            let end = min(1, upper.location)
            guard start <= end else { continue }
            if lower.location == upper.location {
                append(lower.color, at: start)
                append(upper.color, at: end)
                continue
            }
            let curve = lower.interpolation.map {
                UnitCurve.CubicSolver(
                    startControlPoint: UnitPoint(x: Double($0.p1x), y: Double($0.p1y)),
                    endControlPoint: UnitPoint(x: Double($0.p2x), y: Double($0.p2y))
                )
            }
            // Canvas interpolates unpremultiplied colors in its output space.
            // Sample the shared premultiplied device/linear/perceptual function
            // to approximate it, rather than silently changing OSUI's default.
            // Bound subdivision work to 32 intervals per source segment.
            for sample in 0...32 {
                let location = start + (end - start) * CGFloat(sample) / 32
                let fraction = Double((location - lower.location) / (upper.location - lower.location))
                let amount = Float(curve?.value(at: fraction) ?? fraction)
                append(colorSpace.mix(lower.color, upper.color, by: amount), at: location)
            }
        }
        if ordered[ordered.count - 1].location <= 1 {
            append(ordered[ordered.count - 1].color, at: 1)
        }
        // If all stops precede/follow the visible interval, extend the nearest
        // endpoint. Otherwise the clipped segments above supply boundary colors.
        if result.isEmpty {
            append(ordered[0].location > 1 ? ordered[0].color : ordered[ordered.count - 1].color, at: 0)
        }
        return result
    }
}
#endif
