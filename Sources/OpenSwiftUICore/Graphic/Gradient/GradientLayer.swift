//
//  GradientLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8B2FB22698072A829ADC7249F8726FC8 (SwiftUICore)

#if canImport(QuartzCore)

import Foundation
import OpenSwiftUI_SPI
import QuartzCore
import QuartzCore_Private

// MARK: - GradientLayer

final class GradientLayer: CAGradientLayer {
    enum Function: Equatable {
        case linear(startPoint: UnitPoint, endPoint: UnitPoint)
        case radial(center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat)
        case elliptical(center: UnitPoint, startRadiusFraction: CGFloat, endRadiusFraction: CGFloat)
        case conic(center: UnitPoint, angle: Angle)
    }

    override init() {
        super.init()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func update(gradient: ResolvedGradient, function: Function, size: CGSize, bounds: CGRect) {
        if isLinkedOnOrAfter(.v4) {
            premultiplied = true
        }
        let geometry = GradientGeometry(size: size, function: function, bounds: bounds)
        type = geometry.type
        startPoint = geometry.startPoint
        endPoint = geometry.endPoint
        let values = Self.clippedValues(gradient: gradient, function: function)
        colors = values.1
        locations = values.0
        interpolations = values.2
        switch gradient.colorSpace {
        case .device:
            colorSpace = Color.Resolved.srgbExtended
        case .linear:
            colorSpace = Color.Resolved.srgbExtendedLinear
        case .perceptual:
            colorSpace = _CGColorSpaceGetPerceptual()
        }
    }

    // MARK: - Clipped Values

    static func clippedValues(
        gradient: ResolvedGradient,
        function: Function
    ) -> ([NSNumber], [CGColor], [CAMediaTimingFunction]?) {
        var scale: CGFloat = 1
        var offset: CGFloat = 0
        switch function {
        case let .radial(_, start, end), let .elliptical(_, start, end):
            if start != 0 {
                if start < end {
                    scale = (end - start) / end
                    offset = start / end
                } else {
                    scale = end / start - 1
                    offset = 1
                }
            }
        case .linear, .conic:
            break
        }

        var start = offset >= 0 ? offset : 0
        start = start > 1 ? 1 : start
        var end = offset + scale
        end = end >= 0 ? end : 0
        end = end > 1 ? 1 : end
        let lowerBound = end < start ? end : start
        let upperBound = start <= end ? end : start
        var locations: [NSNumber] = []
        var colors: [CGColor] = []
        var interpolations: [CAMediaTimingFunction] = []

        func addMissingInterpolations(to count: Int) {
            guard interpolations.count < count else { return }
            let linear = CAMediaTimingFunction(name: .linear)
            while interpolations.count < count {
                interpolations.append(linear)
            }
        }

        var previous: ResolvedGradient.Stop?
        for position in gradient.stops.indices {
            let index = scale > 0 ? position : gradient.stops.count - position - 1
            var stop = gradient.stops[index]
            var location = offset + scale * stop.location
            if location < lowerBound {
                if position + 1 < gradient.stops.count {
                    let nextIndex = scale > 0 ? index + 1 : index - 1
                    let next = gradient.stops[nextIndex]
                    let nextLocation = offset + scale * next.location
                    if lowerBound <= nextLocation {
                        let fraction = Float((lowerBound - location) / (nextLocation - location))
                        stop.color = gradient.colorSpace.mix(stop.color, next.color, by: fraction)
                    }
                }
                location = lowerBound
            } else if upperBound < location {
                if position > 0 {
                    // Use the original neighbor, not the already-clipped previous stop.
                    let previousIndex = scale > 0 ? index - 1 : index + 1
                    let previous = gradient.stops[previousIndex]
                    let previousLocation = offset + scale * previous.location
                    if previousLocation <= upperBound {
                        let fraction = Float((upperBound - previousLocation) / (location - previousLocation))
                        stop.color = gradient.colorSpace.mix(previous.color, stop.color, by: fraction)
                    }
                }
                location = upperBound
            }
            stop.location = location

            if let previous {
                locations.append(NSNumber(value: Double(previous.location)))
                colors.append(previous.color.cgColor)
                if let interpolation = previous.interpolation {
                    addMissingInterpolations(to: colors.count - 1)
                    interpolations.append(CAMediaTimingFunction(
                        controlPoints: interpolation.p1x, interpolation.p1y,
                        interpolation.p2x, interpolation.p2y
                    ))
                } else if gradient.colorSpace == .perceptual {
                    // An explicit timing curve replaces this extra midpoint.
                    let color = gradient.colorSpace.mix(previous.color, stop.color, by: 0.5)
                    let midpoint = previous.location + (location - previous.location) * 0.5
                    locations.append(NSNumber(value: Double(midpoint)))
                    colors.append(color.cgColor)
                }
            }
            previous = stop
        }
        if let previous {
            locations.append(NSNumber(value: Double(previous.location)))
            colors.append(previous.color.cgColor)
        }
        guard !interpolations.isEmpty else {
            return (locations, colors, nil)
        }
        addMissingInterpolations(to: colors.count - 1)
        return (locations, colors, interpolations)
    }

    // MARK: - Async Update

    static func updateAsync(
        layer: inout DisplayList.ViewUpdater.AsyncLayer,
        oldSize: CGSize,
        newSize: CGSize,
        oldFunction: Function,
        newFunction: Function,
        oldGradient: ResolvedGradient,
        newGradient: ResolvedGradient,
        oldBounds: CGRect,
        newBounds: CGRect
    ) -> Bool {
        guard oldGradient.colorSpace == newGradient.colorSpace else {
            return false
        }
        let oldGeometry = GradientGeometry(size: oldSize, function: oldFunction, bounds: oldBounds)
        let newGeometry = GradientGeometry(size: newSize, function: newFunction, bounds: newBounds)
        layer.update(
            DisplayList.ViewUpdater.GradientStartPoint.self,
            from: oldGeometry.startPoint,
            to: newGeometry.startPoint
        )
        layer.update(
            DisplayList.ViewUpdater.GradientEndPoint.self,
            from: oldGeometry.endPoint,
            to: newGeometry.endPoint
        )
        if oldGradient.stops != newGradient.stops || oldFunction != newFunction {
            let oldValues = clippedValues(gradient: oldGradient, function: oldFunction)
            let newValues = clippedValues(gradient: newGradient, function: newFunction)
            guard oldValues.0.count == newValues.0.count else {
                return false
            }
            layer.update(
                DisplayList.ViewUpdater.GradientColors.self,
                from: oldValues.1,
                to: newValues.1
            )
            layer.update(
                DisplayList.ViewUpdater.GradientLocations.self,
                from: oldValues.0,
                to: newValues.0
            )
            layer.update(
                DisplayList.ViewUpdater.GradientInterpolations.self,
                from: oldValues.2,
                to: newValues.2
            )
        }
        return true
    }
}

// MARK: - GradientLayer.GradientGeometry

extension GradientLayer {
    private struct GradientGeometry {
        var size: CGSize
        var startPoint: CGPoint
        var endPoint: CGPoint
        var type: CAGradientLayerType

        init(size: CGSize, function: Function, bounds: CGRect) {
            self.size = size
            switch function {
            case let .linear(start, end):
                type = .axial
                let extent = size.width <= size.height ? size.height : size.width
                let start = CGPoint(
                    x: (start.x * bounds.width + bounds.origin.x) / extent,
                    y: (start.y * bounds.height + bounds.origin.y) / extent
                )
                let end = CGPoint(
                    x: (end.x * bounds.width + bounds.origin.x) / extent,
                    y: (end.y * bounds.height + bounds.origin.y) / extent
                )
                let perpendicular = CGPoint(
                    x: start.x + (end.y - start.y),
                    y: start.y - (end.x - start.x)
                )
                let scaleX = extent / size.width
                let scaleY = extent / size.height
                startPoint = CGPoint(x: scaleX * start.x, y: scaleY * start.y)
                let scaledEnd = CGPoint(x: scaleX * end.x, y: scaleY * end.y)
                let normal = CGPoint(
                    x: scaleX * perpendicular.x - startPoint.x,
                    y: scaleY * perpendicular.y - startPoint.y
                )
                // Remove the component along the transformed perpendicular axis.
                let lengthSquared = normal.y * normal.y + normal.x * normal.x
                let projection = (
                    (scaledEnd.y - startPoint.y) * normal.y +
                    (scaledEnd.x - startPoint.x) * normal.x
                ) / lengthSquared
                endPoint = CGPoint(
                    x: scaledEnd.x - normal.x * projection,
                    y: scaledEnd.y - normal.y * projection
                )
            case let .radial(center, start, end):
                type = .radial
                let radius = start <= end ? end : start
                let radiusX = radius / bounds.width
                let radiusY = radius / bounds.height
                startPoint = CGPoint(
                    x: (center.x * bounds.width + bounds.origin.x) / size.width,
                    y: (center.y * bounds.height + bounds.origin.y) / size.height
                )
                endPoint = CGPoint(
                    x: ((center.x - radiusX) * bounds.width + bounds.origin.x) / size.width,
                    y: ((center.y - radiusY) * bounds.height + bounds.origin.y) / size.height
                )
            case let .elliptical(center, start, end):
                type = .radial
                let radius = start <= end ? end : start
                startPoint = CGPoint(
                    x: (center.x * bounds.width + bounds.origin.x) / size.width,
                    y: (center.y * bounds.height + bounds.origin.y) / size.height
                )
                endPoint = CGPoint(
                    x: ((center.x - radius) * bounds.width + bounds.origin.x) / size.width,
                    y: ((center.y - radius) * bounds.height + bounds.origin.y) / size.height
                )
            case let .conic(center, angle):
                type = .conic
                startPoint = CGPoint(
                    x: (center.x * bounds.width + bounds.origin.x) / size.width,
                    y: (center.y * bounds.height + bounds.origin.y) / size.height
                )
                endPoint = CGPoint(
                    x: startPoint.x + cos(angle),
                    y: sin(angle) + startPoint.y
                )
            }
        }
    }
}

#endif
