//
//  Gradient.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

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

@available(OpenSwiftUI_v4_0, *)
extension Gradient: Hashable {}

@available(OpenSwiftUI_v4_0, *)
extension Gradient.Stop: Hashable {}

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

extension Gradient {
    package var reversed: Gradient {
        Gradient(stops: stops.reversed().map { stop in
            Stop(color: stop.color, location: 1 - stop.location)
        })
    }
}
