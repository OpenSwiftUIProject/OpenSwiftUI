//
//  GradientColorProvider.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: FE0C0CD2077F7DA45B2F6C579EB58E7B (SwiftUICore)

public import Foundation

// MARK: - Gradient + Color

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension Gradient {
    public func color(at t: CGFloat) -> Color {
        Color(provider: GradientColorProvider(
            base: .gradient(self),
            location: t
        ))
    }
}

// MARK: - AnyGradient + Color

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension AnyGradient {
    public func color(at t: CGFloat) -> Color {
        Color(provider: GradientColorProvider(
            base: .anyGradient(self),
            location: t
        ))
    }
}

// MARK: - GradientColorProvider

private struct GradientColorProvider: ColorProvider {
    var base: EitherGradient
    var location: CGFloat

    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        let gradient = base.resolve(in: environment)
        switch gradient.stops.count {
        case 0:
            return .clear
        case 1:
            return gradient.stops[0].color
        default:
            break
        }
        for index in 1 ..< gradient.stops.count {
            let upper = gradient.stops[index]
            guard location <= upper.location else { continue }
            let lower = gradient.stops[index - 1]
            guard lower.location <= location else { return lower.color }
            var fraction = Double((location - lower.location) / (upper.location - lower.location))
            if let interpolation = upper.interpolation {
                fraction = UnitCurve.bezier(
                    startControlPoint: UnitPoint(
                        x: CGFloat(interpolation.p1x),
                        y: CGFloat(interpolation.p1y)
                    ),
                    endControlPoint: UnitPoint(
                        x: CGFloat(interpolation.p2x),
                        y: CGFloat(interpolation.p2y)
                    )
                ).value(at: fraction)
            }
            return gradient.colorSpace.mix(lower.color, upper.color, by: Float(fraction))
        }
        return gradient.stops[gradient.stops.count - 1].color
    }
}
