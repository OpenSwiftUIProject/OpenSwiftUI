//
//  UIKitCrossPlatformGradientView.swift
//  OpenSwiftUI

#if UIKIT_CROSS_PLATFORM
import Foundation
import UIKit
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore

final class UIKitCrossPlatformGradientView: UIView {
    struct Fill: Equatable {
        let path: Path
        let paint: PlatformGradient
        let antialias: Bool
    }

    var gradient: Fill? {
        didSet {
            guard gradient != oldValue else { return }
            if gradient == nil { layer.contents = nil }
            layer.setNeedsDisplay()
            UIKit.CALayer.layerTreeIsDirty = true
        }
    }

    override func display(_ layer: UIKit.CALayer) {
        guard let gradient, let screen = UIScreen.main else { return }
        let bounds = gradient.path.boundingRect
        guard bounds.width.isFinite, bounds.height.isFinite,
              bounds.width > 0, bounds.height > 0, !gradient.paint.gradient.isClear else {
            layer.contents = nil
            return
        }
        // Bound temporary bitmap and GPU texture size, including oversized views.
        let scale = min(screen.scale, 2048 / Double(max(bounds.width, bounds.height)))
        let width = max(1, Int(ceil(Double(bounds.width) * scale)))
        let height = max(1, Int(ceil(Double(bounds.height) * scale)))
        let bytes = Self.rasterize(gradient, bounds: bounds, width: width, height: height)
        layer.contents = bytes.withUnsafeBufferPointer {
            UIKit.CGImage.premultipliedRGBA($0.baseAddress!, width: width, height: height)
        }
    }

    @_optimize(speed)
    private static func rasterize(_ fill: Fill, bounds: Foundation.CGRect, width: Int, height: Int) -> [UInt8] {
        let ramp = GradientRamp(fill.paint.gradient)
        let geometry = fill.paint.geometry
        let dx = bounds.width / Foundation.CGFloat(width)
        let dy = bounds.height / Foundation.CGFloat(height)
        let offsetsX = [-dx * 0.25, dx * 0.25]
        let offsetsY = [-dy * 0.25, dy * 0.25]
        let isRect: Bool
        if case .rect = fill.path.storage { isRect = true } else { isRect = false }

        return [UInt8](unsafeUninitializedCapacity: width * height * 4) { buffer, count in
            var index = 0
            for row in 0..<height {
                let y = bounds.minY + (Foundation.CGFloat(row) + 0.5) * dy
                for column in 0..<width {
                    let x = bounds.minX + (Foundation.CGFloat(column) + 0.5) * dx
                    let point = Foundation.CGPoint(x: x, y: y)
                    let coverage: Float
                    if isRect {
                        coverage = 1
                    } else if fill.antialias {
                        var hits = 0
                        for offsetY in offsetsY {
                            for offsetX in offsetsX {
                                if fill.path.contains(.init(x: x + offsetX, y: y + offsetY)) { hits += 1 }
                            }
                        }
                        coverage = Float(hits) * 0.25
                    } else {
                        coverage = fill.path.contains(point) ? 1 : 0
                    }
                    let color = coverage == 0 ? .zero : ramp.sample(at: geometry.fraction(at: point)) * coverage
                    buffer.initializeElement(at: index, to: UInt8((color.x * 255).rounded()))
                    buffer.initializeElement(at: index + 1, to: UInt8((color.y * 255).rounded()))
                    buffer.initializeElement(at: index + 2, to: UInt8((color.z * 255).rounded()))
                    buffer.initializeElement(at: index + 3, to: UInt8((color.w * 255).rounded()))
                    index += 4
                }
            }
            count = index
        }
    }
}

// Sample within a stop interval, never across coincident stops.
private struct GradientRamp {
    private let locations: [Foundation.CGFloat]
    private let colors: [SIMD4<Float>]
    private let intervals: [[SIMD4<Float>]]

    init(_ gradient: ResolvedGradient) {
        let stops = gradient.stops.filter { $0.location.isFinite }.sorted { $0.location < $1.location }
        locations = stops.map(\.location)
        colors = stops.map { Self.premultiplied($0.color) }
        let space = gradient.colorSpace
        intervals = zip(stops, stops.dropFirst()).map { lower, upper in
            guard lower.location < upper.location else { return [] }
            let curve = lower.interpolation.map {
                UnitCurve.bezier(
                    startControlPoint: UnitPoint(x: Foundation.CGFloat($0.p1x), y: Foundation.CGFloat($0.p1y)),
                    endControlPoint: UnitPoint(x: Foundation.CGFloat($0.p2x), y: Foundation.CGFloat($0.p2y))
                )
            }
            return (0...256).map { index in
                let t = Double(index) / 256
                let fraction = Float(curve?.value(at: t) ?? t)
                return Self.premultiplied(space.mix(lower.color, upper.color, by: fraction))
            }
        }
    }

    @inline(__always)
    func sample(at t: Foundation.CGFloat) -> SIMD4<Float> {
        guard let first = locations.first else { return .zero }
        guard t.isFinite, t >= first else { return colors[0] }
        var low = 0
        var high = locations.count
        while low + 1 < high {
            let mid = (low + high) / 2
            if locations[mid] <= t { low = mid } else { high = mid }
        }
        guard high < locations.count else { return colors[low] }
        let fraction = (t - locations[low]) / (locations[high] - locations[low])
        let scaled = min(256, max(0, fraction * 256))
        let sample = min(Int(scaled), 255)
        let weight = Float(scaled - Foundation.CGFloat(sample))
        let interval = intervals[low]
        return interval[sample] * (1 - weight) + interval[sample + 1] * weight
    }

    private static func premultiplied(_ color: Color.Resolved) -> SIMD4<Float> {
        func unit(_ value: Float) -> Float { min(1, max(0, value)) }
        let alpha = unit(color.opacity)
        return SIMD4(unit(color.red) * alpha, unit(color.green) * alpha, unit(color.blue) * alpha, alpha)
    }
}

extension PlatformGradient.Geometry {
    @inline(__always)
    fileprivate func fraction(at point: Foundation.CGPoint) -> Foundation.CGFloat {
        func radialFraction(_ radius: Foundation.CGFloat, start: Foundation.CGFloat, end: Foundation.CGFloat) -> Foundation.CGFloat {
            start == end ? (radius < start ? 0 : 1) : (radius - start) / (end - start)
        }
        switch self {
        case let .linear(start, end):
            let x = end.x - start.x
            let y = end.y - start.y
            let length = x * x + y * y
            return length > 0 ? ((point.x - start.x) * x + (point.y - start.y) * y) / length : 0
        case let .radial(center, start, end):
            return radialFraction(hypot(point.x - center.x, point.y - center.y), start: start, end: end)
        case let .elliptical(center, size, start, end):
            guard size.width != 0, size.height != 0 else { return 0 }
            let r = hypot((point.x - center.x) / size.width, (point.y - center.y) / size.height)
            return radialFraction(r, start: start, end: end)
        case let .conic(center, angle):
            let turns = (atan2(point.y - center.y, point.x - center.x) - angle.radians) / (2 * .pi)
            return turns - floor(turns)
        }
    }
}
#endif
