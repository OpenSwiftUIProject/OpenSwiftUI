//
//  Gradient.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  ID: 3CA72A515D037D62EA3FD1FE1FD1F3CB
//  Status: WIP

public import Foundation

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
        guard stops.count > 1 else { return }
        var preLocation = stops[0].location
        for stop in stops.dropFirst() {
            if preLocation > stop.location {
                Log.runtimeIssues("Gradient stop locations must be ordered.")
                break
            }
            preLocation = stop.location
        }
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
        for stop in stops {
            try encoder.messageField(1, stop)
        }
        encoder.enumField(2, colorSpace, defaultValue: .device)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var stops: [ResolvedGradient.Stop] = []
        var colorSpace = ResolvedGradient.ColorSpace.default
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
        try encoder.messageField(1, color)
        encoder.cgFloatField(2, location)
        interpolation.map { interpolation in
            encoder.messageField(3) { encoder in
                encoder.floatField(1, interpolation.p1x)
                encoder.floatField(2, interpolation.p1y)
                encoder.floatField(3, interpolation.p2x, defaultValue: 1)
                encoder.floatField(4, interpolation.p2y, defaultValue: 1)
            }
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var color: Color.Resolved = .clear
        var location: CGFloat = .zero
        var interpolation: BezierTimingFunction<Float>?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: color = try decoder.messageField(field)
            case 2: location = try decoder.cgFloatField(field)
            case 3: interpolation = try decoder.messageField(field) { decoder in
                var p1x: Float = 0
                var p1y: Float = 0
                var p2x: Float = 1
                var p2y: Float = 1
                while let field = try decoder.nextField() {
                    switch field.tag {
                    case 1: p1x = try decoder.floatField(field)
                    case 2: p1y = try decoder.floatField(field)
                    case 3: p2x = try decoder.floatField(field)
                    case 4: p2y = try decoder.floatField(field)
                    default: try decoder.skipField(field)
                    }
                }
                return BezierTimingFunction(p1: (p1x, p1y), p2: (p2x, p2y))
            }
            default: try decoder.skipField(field)
            }
        }
        self.init(color: color, location: location, interpolation: interpolation)
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
            let opacity = color.opacity
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
                    let lr = color.linearRed
                    let lg = color.linearGreen
                    let lb = color.linearBlue
                    let l = 0.412221461535 * lr + 0.536332547665 * lg + 0.051445994526 * lb
                    let m = 0.211903497577 * lr + 0.680699527264 * lg + 0.107396960258 * lb
                    let s = 0.088302463293 * lr + 0.281718850136 * lg + 0.629978716373 * lb
                    r = copysign(pow(abs(l), 1.0 / 3.0), l)
                    g = copysign(pow(abs(m), 1.0 / 3.0), m)
                    b = copysign(pow(abs(s), 1.0 / 3.0), s)
            }
            return InterpolatableColor(r: r * opacity, g: g * opacity, b: b * opacity, a: opacity)
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
                    r =  4.076741695404 * cubeR - 3.307711601257 * cubeG + 0.230969935656 * cubeB
                    g = -1.268437981606 * cubeR + 2.609757423401 * cubeG - 0.341319382191 * cubeB
                    b = -0.004196086433 * cubeR - 0.703418612480 * cubeG + 1.707614660263 * cubeB
                    resolved = Color.Resolved(linearRed: r, linearGreen: g, linearBlue: b, opacity: a)
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
        guard !other.stops.isEmpty else { return }
        if stops.isEmpty {
            if scale == 1.0 {
                self = other
            } else {
                let scale = Float(scale)
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
            let scale = Float(scale)
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
            let scale = Float(scale)
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

    private mutating func setColorSpace(_ newColorSpace: ResolvedGradient.ColorSpace) {
        guard self.colorSpace != newColorSpace else { return }
        for i in stops.indices {
            stops[i].color = newColorSpace.convertIn(self.colorSpace.convertOut(stops[i].color))
        }
        self.colorSpace = newColorSpace
    }
    
    package mutating func scale(by scale: Double) {
        guard !stops.isEmpty else { return }
        let factor = Float(scale)
        for i in stops.indices {
            let color = stops[i].color
            let colorScaled = ResolvedGradient.ColorSpace.InterpolatableColor(
                r: color.r * factor,
                g: color.g * factor,
                b: color.b * factor,
                a: color.a * factor
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
        lhs.add(rhs, scaledBy: 1.0)
    }

    package static func -= (_ lhs: inout ResolvedGradientVector, _ rhs: ResolvedGradientVector) {
        lhs.add(rhs, scaledBy: -1.0)
    }

    package static let zero = ResolvedGradientVector()
}
