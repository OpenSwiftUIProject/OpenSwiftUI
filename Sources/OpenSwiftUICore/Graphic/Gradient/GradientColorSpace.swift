//
//  GradientColorSpace.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  ID: D9C66741AC30F809B56241FAEE383AD3
//  Status: Compelete

import Foundation

// MARK: - Gradient.ColorSpace

extension Gradient {
    /// A method of interpolating between the colors in a gradient.
    public struct ColorSpace: Hashable, Sendable {
        var base: ResolvedGradient.ColorSpace

        /// Interpolates gradient colors in the output color space.
        public static let device: Gradient.ColorSpace = .init(base: .device)

        @_spi(Private)
        public static let linear: Gradient.ColorSpace = .init(base: .linear)

        /// Interpolates gradient colors in a perceptual color space.
        public static let perceptual: Gradient.ColorSpace = .init(base: .perceptual)
    }

    public func colorSpace(_ space: Gradient.ColorSpace) -> AnyGradient {
        AnyGradient(
            provider: ColorSpaceGradientProvider(base: .gradient(self),
            colorSpace: space.base
        ))
    }
}

extension AnyGradient {
    public func colorSpace(_ space: Gradient.ColorSpace) -> AnyGradient {
        AnyGradient(
            provider: ColorSpaceGradientProvider(base: .anyGradient(self),
            colorSpace: space.base
        ))
    }
}

private struct ColorSpaceGradientProvider: GradientProvider {
    var base: EitherGradient
    
    var colorSpace: ResolvedGradient.ColorSpace

    func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        base.resolve(in: environment)
    }

    func fallbackColor(in environment: EnvironmentValues) -> Color? {
        base.fallbackColor(in: environment)
    }
}
