//
//  GradientColorProvider.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  ID: FE0C0CD2077F7DA45B2F6C579EB58E7B
//  Status: Complete

package import Foundation

// MARK: - GradientColorProvider

private struct GradientColorProvider: ColorProvider {
    var base: EitherGradient
    var location: CGFloat

    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        let resolvedGradient = base.resolve(in: environment)
        let stops = resolvedGradient.stops
        let colorSpace = resolvedGradient.colorSpace

        guard !stops.isEmpty else { return .clear }
        guard stops.count > 1 else { return stops[0].color }

        let index = stops.partitionPoint { $0.location >= location }
        if index == 0 { return stops[0].color }
        if index == stops.count { return stops[stops.count - 1].color }
        let lhs = stops[index - 1]
        let rhs = stops[index]
        var t = (location - lhs.location) / (rhs.location - lhs.location)
        if let interpolation = rhs.interpolation {
            t = UnitCurve(interpolation).value(at: t)
        }
        return colorSpace.mix(lhs.color, rhs.color, by: Float(t))
    }
}

extension AnyGradient {
    package func color(at location: CGFloat) -> Color {
        Color(provider: GradientColorProvider(base: .anyGradient(self), location: location))
    }
}

extension Gradient {
    package func color(at location: CGFloat) -> Color {
        Color(provider: GradientColorProvider(base: .gradient(self), location: location))
    }
}
