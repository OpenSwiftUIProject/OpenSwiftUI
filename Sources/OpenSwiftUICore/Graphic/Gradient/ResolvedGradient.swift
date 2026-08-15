//
//  ResolvedGradient.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

public import Foundation

// MARK: - Gradient

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Gradient: Equatable {
    @frozen
    public struct Stop: Equatable {
        public var color: Color

        public var location: CGFloat

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

    public var stops: [Stop]

    public init(stops: [Stop]) {
        self.stops = stops
    }

    public init(colors: [Color]) {
        switch colors.count {
        case 0:
            stops = []
        case 1:
            stops = [Stop(color: colors[0], location: 0)]
        default:
            let denominator = CGFloat(colors.count - 1)
            stops = colors.indices.map { index in
                Stop(color: colors[index], location: CGFloat(index) / denominator)
            }
        }
    }

    package func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        ResolvedGradient(stops: stops.map { $0.resolve(in: environment) })
    }
}

@available(OpenSwiftUI_v4_0, *)
extension Gradient: Hashable {}

@available(OpenSwiftUI_v4_0, *)
extension Gradient.Stop: Hashable {}

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

    package enum ColorSpace: UInt8, Hashable, Codable {
        case device
        case linear
        case perceptual

        package static let `default`: ColorSpace = .device

        func mix(_ lhs: Color.Resolved, _ rhs: Color.Resolved, by fraction: Float) -> Color.Resolved {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package var stops: [Stop]

    package var colorSpace: ColorSpace

    package init() {
        stops = []
        colorSpace = .default
    }

    package init(stops: [Stop], colorSpace: ColorSpace = .default) {
        self.stops = stops
        self.colorSpace = colorSpace
    }

    package var isClear: Bool {
        stops.allSatisfy { $0.color.opacity == 0 }
    }

    package var isOpaque: Bool {
        !stops.isEmpty && stops.allSatisfy { $0.color.opacity == 1 }
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
        guard let first = stops.first?.color else {
            return nil
        }
        return stops.dropFirst().allSatisfy { $0.color == first } ? first : nil
    }

    package mutating func multiplyOpacity(by value: Float) {
        for index in stops.indices {
            stops[index].color = stops[index].color.multiplyingOpacity(by: value)
        }
    }
}

extension ResolvedGradient: Codable {
    private enum CodingKeys: CodingKey {
        case stops
        case colorSpace
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stops, forKey: .stops)
        try container.encode(colorSpace, forKey: .colorSpace)
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stops = try container.decode([Stop].self, forKey: .stops)
        colorSpace = try container.decode(ColorSpace.self, forKey: .colorSpace)
    }
}

extension ResolvedGradient.Stop: Codable {
    private enum CodingKeys: CodingKey {
        case color
        case location
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try container.encode(location, forKey: .location)
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decode(Color.Resolved.self, forKey: .color)
        location = try container.decode(CGFloat.self, forKey: .location)
        interpolation = nil
    }
}
