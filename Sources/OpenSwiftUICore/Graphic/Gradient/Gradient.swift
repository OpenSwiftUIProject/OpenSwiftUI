//
//  Gradient.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3CA72A515D037D62EA3FD1FE1FD1F3CB (SwiftUICore)

public import Foundation

// MARK: - Gradient

/// A color gradient represented as an array of color stops.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Gradient: Equatable {
    /// One color and its location in a gradient.
    @frozen
    public struct Stop: Equatable {
        /// The color at this stop.
        public var color: Color

        /// The normalized location of this stop.
        public var location: CGFloat

        /// Creates a color stop.
        public init(color: Color, location: CGFloat) {
            self.color = color
            self.location = location
        }

        package func resolve(in environment: EnvironmentValues) -> ResolvedGradient.Stop {
            ResolvedGradient.Stop(
                color: color.resolve(in: environment),
                location: location
            )
        }
    }

    /// The gradient's color stops.
    public var stops: [Stop]

    /// Creates a gradient from an array of color stops.
    public init(stops: [Stop]) {
        self.stops = stops
    }

    package init(_ resolved: ResolvedGradient) {
        self.init(stops: resolved.stops.map {
            Stop(color: Color($0.color), location: $0.location)
        })
    }

    /// Creates a gradient by evenly distributing an array of colors.
    public init(colors: [Color]) {
        switch colors.count {
        case 0:
            stops = []
        case 1:
            stops = [Stop(color: colors[0], location: 0)]
        default:
            let step = 1.0 / CGFloat(colors.count - 1)
            stops = colors.enumerated().map { index, color in
                Stop(color: color, location: CGFloat(index) * step)
            }
        }
    }

    package func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        ResolvedGradient(
            stops: stops.map { $0.resolve(in: environment) },
            colorSpace: .default
        )
    }

    package var constantColor: Color? {
        switch stops.count {
        case 0: .clear
        case 1: stops[0].color
        default: nil
        }
    }

    package var fallbackColor: Color? {
        stops.first?.color
    }
}

// MARK: - Gradient + Hashable

@available(OpenSwiftUI_v4_0, *)
extension Gradient: Hashable {}

// MARK: - Gradient.Stop + Hashable

@available(OpenSwiftUI_v4_0, *)
extension Gradient.Stop: Hashable {}

// MARK: - Gradient + ShapeStyle

@available(OpenSwiftUI_v4_0, *)
extension Gradient: ShapeStyle {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        LinearGradient(
            gradient: self,
            startPoint: .top,
            endPoint: .bottom
        )._apply(to: &shape)
    }
}

// MARK: - Gradient + Reversal

extension Gradient {
    package var reversed: Gradient {
        Gradient(stops: stops.reversed().map { stop in
            Stop(color: stop.color, location: 1 - stop.location)
        })
    }
}

// MARK: - ResolvedGradient

package struct ResolvedGradient: Equatable {
    package typealias Interpolation = BezierTimingFunction<Float>

    package struct Stop: Equatable {
        package var color: Color.Resolved
        package var location: CGFloat
        package var interpolation: Interpolation?

        package init(
            color: Color.Resolved,
            location: CGFloat,
            interpolation: Interpolation? = nil
        ) {
            self.color = color
            self.location = location
            self.interpolation = interpolation
        }
    }

    package enum ColorSpace: UInt8, Hashable {
        case device
        case linear
        case perceptual

        package static let `default`: ColorSpace = isLinkedOnOrAfter(.v4) ? .perceptual : .device
    }

    package var stops: [Stop]
    package var colorSpace: ColorSpace

    package init() {
        self.init(stops: [], colorSpace: .default)
    }

    package init(stops: [Stop], colorSpace: ColorSpace = .default) {
        self.stops = stops
        self.colorSpace = colorSpace
    }

    package var isClear: Bool {
        guard !stops.isEmpty else {
            return true
        }
        return stops.allSatisfy { $0.color.isClear }
    }

    package var isOpaque: Bool {
        guard !stops.isEmpty else {
            return false
        }
        return stops.allSatisfy { $0.color.isOpaque }
    }

    package var hasInterpolations: Bool {
        stops.contains { $0.interpolation != nil }
    }

    package var interpolationsCount: Int {
        stops.reduce(into: 0) { count, stop in
            if stop.interpolation != nil {
                count += 1
            }
        }
    }

    package var constantColor: Color.Resolved? {
        guard let first = stops.first else { return .clear }
        for stop in stops.dropFirst() {
            guard stop.color == first.color else { return nil }
        }
        return first.color
    }

    package mutating func multiplyOpacity(by opacity: Float) {
        for index in stops.indices {
            stops[index].color = stops[index].color.multiplyingOpacity(by: opacity)
        }
    }
}

// MARK: - ResolvedGradient + ProtobufMessage

extension ResolvedGradient: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        for stop in stops {
            try encoder.messageField(1, stop)
        }
        encoder.enumField(2, colorSpace, defaultValue: .device)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var stops: [Stop] = []
        var colorSpace = ColorSpace.default
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: stops.append(try decoder.messageField(field))
            case 2: colorSpace = try decoder.enumField(field) ?? .device
            default: try decoder.skipField(field)
            }
        }
        self.init(stops: stops, colorSpace: colorSpace)
    }
}

// MARK: - ResolvedGradient.ColorSpace + ProtobufEnum

extension ResolvedGradient.ColorSpace: ProtobufEnum {
    package init?(protobufValue: UInt) {
        guard protobufValue < 3 else { return nil }
        self.init(rawValue: UInt8(protobufValue))
    }
}

// MARK: - ResolvedGradient + CodableByProtobuf

extension ResolvedGradient: CodableByProtobuf {}

// MARK: - ResolvedGradient.Stop + ProtobufMessage

extension ResolvedGradient.Stop: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, color)
        encoder.cgFloatField(2, location)
        _ = interpolation.map { interpolation in
            encoder.messageField(3) { encoder in
                encoder.floatField(1, interpolation.p1x)
                encoder.floatField(2, interpolation.p1y)
                encoder.floatField(3, interpolation.p2x, defaultValue: 1)
                encoder.floatField(4, interpolation.p2y, defaultValue: 1)
            }
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var color = Color.Resolved.clear
        var location: CGFloat = 0
        var interpolation: ResolvedGradient.Interpolation?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: color = try decoder.messageField(field)
            case 2: location = try decoder.cgFloatField(field)
            case 3:
                interpolation = try decoder.messageField(field) { decoder -> ResolvedGradient.Interpolation? in
                    var interpolation = ResolvedGradient.Interpolation.linear
                    while let field = try decoder.nextField() {
                        switch field.tag {
                        case 1: interpolation.p1x = try decoder.floatField(field)
                        case 2: interpolation.p1y = try decoder.floatField(field)
                        case 3: interpolation.p2x = try decoder.floatField(field)
                        case 4: interpolation.p2y = try decoder.floatField(field)
                        default: try decoder.skipField(field)
                        }
                    }
                    return interpolation
                }
            default: try decoder.skipField(field)
            }
        }
        self.init(color: color, location: location, interpolation: interpolation)
    }
}

// MARK: - ResolvedGradient.ColorSpace + Color conversion

extension ResolvedGradient.ColorSpace {
    package func mix(_ lhs: Color.Resolved, _ rhs: Color.Resolved, by fraction: Float) -> Color.Resolved {
        let lhs = convertIn(lhs)
        let rhs = convertIn(rhs)
        return convertOut(lhs * (1 - fraction) + rhs * fraction)
    }

    package struct InterpolatableColor: Equatable {
        var r: Float
        var g: Float
        var b: Float
        var a: Float

        static func + (lhs: InterpolatableColor, rhs: InterpolatableColor) -> InterpolatableColor {
            InterpolatableColor(
                r: lhs.r + rhs.r,
                g: lhs.g + rhs.g,
                b: lhs.b + rhs.b,
                a: lhs.a + rhs.a
            )
        }

        static func * (lhs: InterpolatableColor, rhs: Float) -> InterpolatableColor {
            InterpolatableColor(
                r: lhs.r * rhs,
                g: lhs.g * rhs,
                b: lhs.b * rhs,
                a: lhs.a * rhs
            )
        }

        @inline(__always)
        var magnitudeSquared: Double {
            Double(r * r + g * g + b * b + a * a)
        }
    }

    package func convertIn(_ color: Color.Resolved) -> InterpolatableColor {
        let r: Float
        let g: Float
        let b: Float
        switch self {
        case .device:
            r = sRGBFromLinear(color.linearRed)
            g = sRGBFromLinear(color.linearGreen)
            b = sRGBFromLinear(color.linearBlue)
        case .linear:
            r = color.linearRed
            g = color.linearGreen
            b = color.linearBlue
        case .perceptual:
            r = cubeRoot(
                0.4122214708 * color.linearRed +
                0.5363325363 * color.linearGreen +
                0.0514459929 * color.linearBlue
            )
            g = cubeRoot(
                0.2119034982 * color.linearRed +
                0.6806995451 * color.linearGreen +
                0.1073969566 * color.linearBlue
            )
            b = cubeRoot(
                color.linearRed * 0.0883024619 +
                color.linearGreen * 0.2817188376 +
                color.linearBlue * 0.6299787005
            )
        }
        return InterpolatableColor(
            r: r * color.opacity,
            g: g * color.opacity,
            b: b * color.opacity,
            a: color.opacity
        )
    }

    package func convertOut(_ color: InterpolatableColor) -> Color.Resolved {
        let opacity = color.a
        var r = color.r
        var g = color.g
        var b = color.b
        if opacity != 0 {
            let scale = 1 / opacity
            r *= scale
            g *= scale
            b *= scale
        }
        switch self {
        case .device:
            return Color.Resolved(
                linearRed: sRGBToLinear(r),
                linearGreen: sRGBToLinear(g),
                linearBlue: sRGBToLinear(b),
                opacity: opacity
            )
        case .linear:
            return Color.Resolved(
                linearRed: r,
                linearGreen: g,
                linearBlue: b,
                opacity: opacity
            )
        case .perceptual:
            let l = r * (r * r)
            let m = g * (g * g)
            let s = b * (b * b)
            return Color.Resolved(
                linearRed: s * 0.2309699292 + (l * 4.0767416621 - m * 3.3077115913),
                linearGreen: m * 2.6097574011 - l * 1.2684380046 - s * 0.3413193965,
                linearBlue: l * -0.0041960863 - m * 0.7034186147 + s * 1.7076147010,
                opacity: opacity
            )
        }
    }

    @inline(__always)
    private func cubeRoot(_ value: Float) -> Float {
        Float(signOf: value, magnitudeOf: pow(abs(value), 1.0 / 3.0))
    }

    @inline(__always)
    private func sRGBToLinear(_ value: Float) -> Float {
        let magnitude = value > 0 ? value : -value
        let result: Float
        if magnitude <= 0.04045 {
            result = magnitude * (1.0 / 12.92)
        } else if magnitude == 1 {
            result = 1
        } else {
            // Keep the reciprocal product and offset as separate Float operations.
            let reciprocal: Float = 1.0 / 1.055
            let offset: Float = 0.055 * reciprocal
            result = pow(magnitude * reciprocal + offset, 2.4)
        }
        return value > 0 ? result : -result
    }
}

// MARK: - ResolvedGradient + Animatable

extension ResolvedGradient: Animatable {
    package var animatableData: ResolvedGradientVector {
        get {
            guard isLinkedOnOrAfter(.v5) else { return .zero }
            return ResolvedGradientVector(self)
        }
        set {
            guard isLinkedOnOrAfter(.v5) else { return }
            stops.removeAll(keepingCapacity: true)
            stops.reserveCapacity(newValue.stops.count)
            for stop in newValue.stops {
                stops.append(Stop(
                    color: newValue.colorSpace.convertOut(stop.color),
                    location: stop.location,
                    interpolation: stop.interpolation
                ))
            }
        }
    }
}

// MARK: - ResolvedGradientVector

package struct ResolvedGradientVector: VectorArithmetic {
    fileprivate struct Stop: Equatable {
        var color: ResolvedGradient.ColorSpace.InterpolatableColor
        var location: CGFloat
        var interpolation: ResolvedGradient.Interpolation?
    }

    fileprivate var stops: [Stop]
    fileprivate var colorSpace: ResolvedGradient.ColorSpace

    package init() {
        stops = []
        colorSpace = .device
    }

    package init(_ base: ResolvedGradient) {
        stops = base.stops.map { stop in
            Stop(
                color: base.colorSpace.convertIn(stop.color),
                location: stop.location,
                interpolation: stop.interpolation
            )
        }
        colorSpace = base.colorSpace
    }

    package static var zero: ResolvedGradientVector { ResolvedGradientVector() }

    package static func += (lhs: inout ResolvedGradientVector, rhs: ResolvedGradientVector) {
        lhs.add(rhs, scaledBy: 1)
    }

    package static func -= (lhs: inout ResolvedGradientVector, rhs: ResolvedGradientVector) {
        lhs.add(rhs, scaledBy: -1)
    }

    package mutating func scale(by rhs: Double) {
        let scalar = Float(rhs)
        for index in stops.indices {
            stops[index].color = stops[index].color * scalar
        }
    }

    package var magnitudeSquared: Double {
        stops.reduce(into: 0.0) { result, stop in
            result += stop.color.magnitudeSquared
        }
    }

    package static func + (
        lhs: ResolvedGradientVector,
        rhs: ResolvedGradientVector
    ) -> ResolvedGradientVector {
        var result = lhs
        result += rhs
        return result
    }

    package static func - (
        lhs: ResolvedGradientVector,
        rhs: ResolvedGradientVector
    ) -> ResolvedGradientVector {
        var result = lhs
        result -= rhs
        return result
    }

    private mutating func add(_ rhs: ResolvedGradientVector, scaledBy scale: Double) {
        guard !rhs.stops.isEmpty else { return }
        guard !stops.isEmpty else {
            if scale == 1 {
                self = rhs
            } else {
                let factor = Float(scale)
                stops.reserveCapacity(rhs.stops.count)
                for stop in rhs.stops {
                    stops.append(Stop(
                        color: stop.color * factor,
                        location: stop.location,
                        interpolation: nil
                    ))
                }
                colorSpace = rhs.colorSpace
            }
            return
        }

        setColorSpace(rhs.colorSpace)
        let factor = Float(scale)

        if stops.count == rhs.stops.count,
           stops.indices.allSatisfy({ stops[$0].location == rhs.stops[$0].location }) {
            for index in stops.indices {
                stops[index].color = stops[index].color + rhs.stops[index].color * factor
                if stops[index].interpolation != nil || rhs.stops[index].interpolation != nil {
                    let lhsCurve = stops[index].interpolation ?? .linear
                    let rhsCurve = rhs.stops[index].interpolation ?? .linear
                    // Curve components scale the left side, unlike color components.
                    stops[index].interpolation = ResolvedGradient.Interpolation(
                        p1: (lhsCurve.p1x * factor + rhsCurve.p1x, lhsCurve.p1y * factor + rhsCurve.p1y),
                        p2: (lhsCurve.p2x * factor + rhsCurve.p2x, lhsCurve.p2y * factor + rhsCurve.p2y)
                    )
                }
            }
            return
        }

        func mix(stops: [Stop], count: Int, at index: Int, location: CGFloat) -> Stop {
            let color: ResolvedGradient.ColorSpace.InterpolatableColor
            if index < 1 {
                color = stops[0].color
            } else if index >= count {
                color = stops[count - 1].color
            } else {
                let lower = stops[index - 1]
                let upper = stops[index]
                if lower.location == upper.location {
                    color = lower.color
                } else {
                    let fraction = Float((location - lower.location) / (upper.location - lower.location))
                    color = lower.color * (1 - fraction) + upper.color * fraction
                }
            }
            return Stop(color: color, location: location, interpolation: nil)
        }

        let lhsStops = stops
        let lhsCount = lhsStops.count
        let rhsCount = rhs.stops.count
        var mergedStops: [Stop] = []
        mergedStops.reserveCapacity(max(lhsCount, rhsCount))
        var lhsIndex = 0
        var rhsIndex = 0

        while lhsIndex < lhsCount || rhsIndex < rhsCount {
            let lhsLocation = lhsIndex < lhsCount ? lhsStops[lhsIndex].location : .infinity
            let rhsLocation = rhsIndex < rhsCount ? rhs.stops[rhsIndex].location : .infinity
            let lhsStop: Stop
            let rhsStop: Stop

            if lhsLocation == rhsLocation {
                lhsStop = lhsStops[lhsIndex]
                rhsStop = rhs.stops[rhsIndex]
                lhsIndex += 1
                rhsIndex += 1
            } else if lhsLocation < rhsLocation {
                lhsStop = lhsStops[lhsIndex]
                lhsIndex += 1
                rhsStop = mix(stops: rhs.stops, count: rhsCount, at: rhsIndex, location: lhsLocation)
            } else {
                rhsStop = rhs.stops[rhsIndex]
                rhsIndex += 1
                lhsStop = mix(stops: lhsStops, count: lhsCount, at: lhsIndex, location: rhsLocation)
            }
            mergedStops.append(Stop(
                color: lhsStop.color + rhsStop.color * factor,
                location: lhsStop.location,
                interpolation: lhsStop.interpolation
            ))
        }

        stops = mergedStops
    }

    private mutating func setColorSpace(_ newColorSpace: ResolvedGradient.ColorSpace) {
        guard colorSpace != newColorSpace else { return }
        for index in stops.indices {
            let resolved = colorSpace.convertOut(stops[index].color)
            stops[index].color = newColorSpace.convertIn(resolved)
        }
        colorSpace = newColorSpace
    }
}
