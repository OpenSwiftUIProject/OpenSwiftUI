//
//  GradientColorSpace.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D9C66741AC30F809B56241FAEE383AD3 (SwiftUICore)

import Foundation

@available(OpenSwiftUI_v4_0, *)
extension Gradient {
    /// A method of interpolating between the colors in a gradient.
    public struct ColorSpace: Hashable, Sendable {
        package var base: ResolvedGradient.ColorSpace

        /// Interpolates gradient colors in the output color space.
        public static let device: Gradient.ColorSpace = .init(base: .device)

        @_spi(Private)
        public static let linear: Gradient.ColorSpace = .init(base: .linear)

        /// Interpolates gradient colors in a perceptual color space.
        public static let perceptual: Gradient.ColorSpace = .init(base: .perceptual)
    }

    public func colorSpace(_ space: Gradient.ColorSpace) -> AnyGradient {
        AnyGradient(provider: ColorSpaceGradientProvider(
            base: .gradient(self),
            colorSpace: space.base
        ))
    }
}

@available(OpenSwiftUI_v4_0, *)
extension AnyGradient {
    public func colorSpace(_ space: Gradient.ColorSpace) -> AnyGradient {
        AnyGradient(provider: ColorSpaceGradientProvider(
            base: .anyGradient(self),
            colorSpace: space.base
        ))
    }
}

private struct ColorSpaceGradientProvider: GradientProvider {
    var base: EitherGradient
    var colorSpace: ResolvedGradient.ColorSpace

    func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        var resolved = base.resolve(in: environment)
        resolved.colorSpace = colorSpace
        return resolved
    }

    func fallbackColor(in environment: EnvironmentValues) -> Color? {
        base.fallbackColor(in: environment)
    }
}
