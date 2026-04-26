//
//  Gradient.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  ID: 3CA72A515D037D62EA3FD1FE1FD1F3CB
//  Status: WIP

public import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

// MARK: - GradientProvider

package protocol GradientProvider: Hashable {
    func resolve(in: EnvironmentValues) -> ResolvedGradient
    func fallbackColor(in: EnvironmentValues) -> Color?
}

extension GradientProvider {
    package func fallbackColor(in: EnvironmentValues) -> Color? {
        nil
    }
}

// MARK: - Gradient

public struct Gradient: GradientProvider, ShapeStyle, Hashable {
    public var stops: [Gradient.Stop]

    public init(stops: [Gradient.Stop]) {
        self.stops = stops
    }

    public struct Stop: Hashable {
        public var color: Color
        public var location: CGFloat

        public init(color: Color, location: CGFloat) {
            self.color = color
            self.location = location
        }

        func resolve(in environment: EnvironmentValues) -> ResolvedGradient.Stop {
            ResolvedGradient.Stop(
                color: color.resolve(in: environment),
                location: location,
                interpolation: nil
            )
        }
    }

    public init(colors: [Color]) {
        let count = colors.count
        if count > 1 {
            let step = 1.0 / CGFloat(colors.count - 1)
            var stops: [Gradient.Stop] = []
            for (i, color) in colors.enumerated() {
                stops.append(.init(color: color, location: CGFloat(i) * step))
            }
            self.stops = stops
        } else if count == 1 {
            self.stops = [.init(color: colors[0], location: 0)]
        } else {
            self.stops = []
        }
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        LinearGradient(
            gradient: self,
            startPoint: .top,
            endPoint: .bottom
        )._apply(to: &shape)
    }

    package func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        ResolvedGradient(stops: stops.map{ $0.resolve(in: environment) })
    }
}

@available(*, unavailable)
extension Gradient.Stop: Sendable {}

// MARK: - ResolvedGradient

package struct ResolvedGradient: Equatable {
    var stops: [ResolvedGradient.Stop]
    var colorSpace: ResolvedGradient.ColorSpace

    init(stops: [ResolvedGradient.Stop], colorSpace: ResolvedGradient.ColorSpace = .default) {
        self.stops = stops
        self.colorSpace = colorSpace
    }

    init() {
        self.stops = []
        self.colorSpace = .default
    }

    mutating func multiplyOpacity(by opacity: Float) {
        for i in stops.indices {
            stops[i].color.opacity = stops[i].color.opacity * opacity
        }
    }

    #if canImport(CoreGraphics)
    var cgGradient: CGGradient? {
        _openSwiftUIUnimplementedFailure()
    }
    #endif

    var constantColor: Color.Resolved? {
        guard !stops.isEmpty else {
            return .clear
        }
        let color = stops[0].color
        for stop in stops.dropFirst() {
            guard stop.color == color else {
                return nil
            }
        }
        return color
    }

    var hasInterpolations: Bool {
        guard !stops.isEmpty else { return false }
        return stops.contains{ $0.interpolation != nil }
    }

    var interpolationsCount: Int {
        guard !stops.isEmpty else { return 0 }
        return stops.count { $0.interpolation != nil }
    }

    var isClear: Bool {
        guard !stops.isEmpty else { return true }
        return stops.allSatisfy { $0.color.isClear }
    }

    var isOpaque: Bool {
        guard !stops.isEmpty else { return false }
        return stops.allSatisfy { $0.color.isOpaque }
    }

    package struct Stop: Equatable {
        var color: Color.Resolved
        var location: CGFloat
        var interpolation: BezierTimingFunction<Float>?

        init(color: Color.Resolved, location: CGFloat, interpolation: BezierTimingFunction<Float>?) {
            self.color = color
            self.location = location
            self.interpolation = interpolation
        }
    }
}

extension ResolvedGradient: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ResolvedGradient: CodableByProtobuf {}

extension ResolvedGradient: Animatable {
    package var animatableData: ResolvedGradientVector {
        get { _SemanticFeature_v5.isEnabled ? ResolvedGradientVector(self) : .zero }
        set {
            guard _SemanticFeature_v5.isEnabled else { return }
            stops.removeAll(keepingCapacity: true)
            stops.reserveCapacity(newValue.stops.count)
            for stop in newValue.stops {
                stops.append(
                    Stop(
                        color: newValue.colorSpace.convertOut(stop.color),
                        location: stop.location,
                        interpolation: stop.interpolation
                    )
                )
            }
        }
    }
}

extension ResolvedGradient.Stop: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ResolvedGradient.ColorSpace

extension ResolvedGradient {
    package enum ColorSpace: UInt8, Hashable {
        case device
        case linear
        case perceptual

        package static var `default`: ColorSpace {
            _SemanticFeature_v4.isEnabled ? .perceptual : .device
        }

        package func mix(_ lhs: Color.Resolved, _ rhs: Color.Resolved, by fraction: Float) -> Color.Resolved {
            let lColor = convertIn(lhs)
            let rColor = convertIn(rhs)
            return convertOut(InterpolatableColor(
                r: lColor.r * (1 - fraction) + rColor.r * fraction,
                g: lColor.g * (1 - fraction) + rColor.g * fraction,
                b: lColor.b * (1 - fraction) + rColor.b * fraction,
                a: lColor.a * (1 - fraction) + rColor.a * fraction
            ))
        }

        package struct InterpolatableColor: Equatable {
            var r: Float
            var g: Float
            var b: Float
            var a: Float
        }

        package func convertIn(_ color: Color.Resolved) -> InterpolatableColor {
            var r: Float
            var g: Float
            var b: Float
            switch self {
                case .device:
                    r = color.red
                    g = color.green
                    b = color.blue
                case .linear:
                    r = color.linearRed
                    g = color.linearGreen
                    b = color.linearBlue
                case .perceptual:
                    r = 0.4122215   * color.linearRed + 0.5363325  * color.linearGreen + 0.05144599 * color.linearBlue
                    g = 0.2119035   * color.linearRed + 0.6806995  * color.linearGreen + 0.107397   * color.linearBlue
                    b = 0.088302463 * color.linearRed + 0.28171885 * color.linearGreen + 0.62997872 * color.linearBlue
                    r = pow(r, 1.0 / 3.0)
                    g = pow(g, 1.0 / 3.0)
                    b = pow(b, 1.0 / 3.0)
            }
            r = r * color.opacity
            g = g * color.opacity
            b = b * color.opacity
            return InterpolatableColor(r: r, g: g, b: b, a: color.opacity)
        }

        package func convertOut(_ color: InterpolatableColor) -> Color.Resolved {
            var r = color.r
            var g = color.g
            var b = color.b
            let a = color.a
            if a != 0 {
                r = r * (1.0 / a)
                g = g * (1.0 / a)
                b = b * (1.0 / a)
            }
            var resolved: Color.Resolved
            switch self {
                case .device:
                    resolved = Color.Resolved(red: r, green: g, blue: b, opacity: a)
                case .linear:
                    resolved = Color.Resolved(linearRed: r, linearGreen: g, linearBlue: b, opacity: a)
                case .perceptual:
                    let cubeR = r * r * r
                    let cubeG = g * g * g
                    let cubeB = b * b * b
                    r = 4.0767416954   * cubeR - 3.3077116013 * cubeG + 0.2309699357 * cubeB
                    g = -1.2684379816  * cubeR + 2.6097574234 * cubeG - 0.3413193822 * cubeB
                    b = -0.00419608643 * cubeR - 0.7034186125 * cubeG + 1.7076146603 * cubeB
                    resolved = Color.Resolved(red: r, green: g, blue: b, opacity: a)
            }
            return resolved
        }
    }
}

extension ResolvedGradient.ColorSpace: ProtobufEnum {}

// MARK: - ResolvedGradientVector

package struct ResolvedGradientVector: VectorArithmetic {
    fileprivate var stops: [ResolvedGradientVector.Stop]
    package var colorSpace: ResolvedGradient.ColorSpace

    fileprivate struct Stop: Equatable {
        var color: ResolvedGradient.ColorSpace.InterpolatableColor
        var location: CGFloat
        var interpolation: BezierTimingFunction<Float>?
    }

    package init() {
        self.stops = []
        self.colorSpace = .device
    }

    package init(_ gradient: ResolvedGradient) {
        self.stops = gradient.stops.map {
            Stop(
                color: gradient.colorSpace.convertIn($0.color),
                location: $0.location,
                interpolation: $0.interpolation
            )
        }
        self.colorSpace = gradient.colorSpace
    }

    private mutating func add(_ other: ResolvedGradientVector, scaledBy scale: Double) {
        let scale = Float(scale)
        if stops.isEmpty {
            if scale == 1 {
                self = other
            } else {
                self.stops = other.stops.map {
                    Stop(
                        color: ResolvedGradient.ColorSpace.InterpolatableColor(
                            r: $0.color.r * scale,
                            g: $0.color.g * scale,
                            b: $0.color.b * scale,
                            a: $0.color.a * scale
                        ),
                        location: $0.location,
                        interpolation: nil
                    )
                }
                self.colorSpace = other.colorSpace
            }
            return
        }
        
        func mix(
            stops: [ResolvedGradientVector.Stop],
            count: Int,
            at index: Int,
            location: CGFloat
        ) -> ResolvedGradientVector.Stop {
            var color: ResolvedGradient.ColorSpace.InterpolatableColor
            if index <= 0 {
                color = stops[0].color
            } else if index >= count {
                color = stops[count - 1].color
            } else {
                let lLocation = stops[index - 1].location
                let rLocation = stops[index].location
                color = stops[index - 1].color
                if lLocation != rLocation {
                    let t = Float((location - lLocation) / (rLocation - lLocation))
                    let u = 1 - t
                    let rColor = stops[index].color
                    color = .init(
                        r: color.r * u + rColor.r * t,
                        g: color.g * u + rColor.g * t,
                        b: color.b * u + rColor.b * t,
                        a: color.a * u + rColor.a * t
                    )
                }
            }
            return .init(color: color, location: location, interpolation: nil)
        }

        setColorSpace(other.colorSpace)
        if stops.count == other.stops.count, zip(stops, other.stops).allSatisfy({ $0.location == $1.location }) {
            for i in stops.indices {
                stops[i].color.r += other.stops[i].color.r * scale
                stops[i].color.g += other.stops[i].color.g * scale
                stops[i].color.b += other.stops[i].color.b * scale
                stops[i].color.a += other.stops[i].color.a * scale

                guard stops[i].interpolation != nil || other.stops[i].interpolation != nil else { continue }
                let li = stops[i].interpolation ?? .linear
                let ri = other.stops[i].interpolation ?? .linear
                stops[i].interpolation = BezierTimingFunction<Float>(
                    p1: (li.p1x * scale + ri.p1x, li.p1y * scale + ri.p1y),
                    p2: (li.p2x * scale + ri.p2x, li.p2y * scale + ri.p2y)
                )
            }
        } else {
            var result: [Stop] = []
            result.reserveCapacity(max(stops.count, other.stops.count))
            var i = 0
            var j = 0
            while i < stops.count || j < other.stops.count {
                let lLocation = i < stops.count ? stops[i].location : .infinity
                let rLocation = j < other.stops.count ? other.stops[j].location : .infinity
                var stop: Stop
                let color: ResolvedGradient.ColorSpace.InterpolatableColor
                if lLocation == rLocation {
                    stop = stops[i]
                    color = other.stops[j].color
                    i += 1
                    j += 1
                } else if lLocation < rLocation {
                    stop = stops[i]
                    color = mix(stops: other.stops, count: other.stops.count, at: j, location: lLocation).color
                    i += 1
                } else {
                    stop = mix(stops: stops, count: stops.count, at: i, location: rLocation)
                    color = other.stops[j].color
                    j += 1
                }
                stop.color.r += color.r * scale
                stop.color.g += color.g * scale
                stop.color.b += color.b * scale
                stop.color.a += color.a * scale
                result.append(stop)
            }
            self.stops = result
        }
    }

    private mutating func setColorSpace(_ colorSpace: ResolvedGradient.ColorSpace) {
        guard self.colorSpace != colorSpace else { return }
        for i in stops.indices {
            stops[i].color = colorSpace.convertIn(colorSpace.convertOut(stops[i].color))
        }
        self.colorSpace = colorSpace
    }
    
    package mutating func scale(by scale: Double) {
        for i in stops.indices {
            let color = stops[i].color
            let colorScaled = ResolvedGradient.ColorSpace.InterpolatableColor(
                r: color.r * Float(scale),
                g: color.g * Float(scale),
                b: color.b * Float(scale),
                a: color.a * Float(scale)
            ) 
            stops[i].color = colorScaled
        }
    }

    package var magnitudeSquared: Double {
        guard !stops.isEmpty else { return 0 }
        var result = 0.0
        for stop in stops {
            let color = stop.color
            let sum = color.r * color.r + color.g * color.g + color.b * color.b + color.a * color.a
            result += Double(sum)
        }
        return result
    }

    package static func + (_ lhs: ResolvedGradientVector, _ rhs: ResolvedGradientVector) -> ResolvedGradientVector {
        var result = lhs
        result.add(rhs, scaledBy: 1)
        return result
    }

    package static func - (_ lhs: ResolvedGradientVector, _ rhs: ResolvedGradientVector) -> ResolvedGradientVector {
        var result = lhs
        result.add(rhs, scaledBy: -1)
        return result
    }

    package static func += (_ lhs: inout ResolvedGradientVector, _ rhs: ResolvedGradientVector) {
        lhs = lhs + rhs
    }

    package static func -= (_ lhs: inout ResolvedGradientVector, _ rhs: ResolvedGradientVector) {
        lhs = lhs - rhs
    }

    package static let zero = ResolvedGradientVector()
}
