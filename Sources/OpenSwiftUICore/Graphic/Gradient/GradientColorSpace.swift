//
//  GradientColorSpace.swift
//  OpenSwiftUICore
//
//  Status: Blocked by AnyGradient

import Foundation

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

//    public func colorSpace(_ space: Gradient.ColorSpace) -> AnyGradient {
//        preconditionFailure("TODO")
//    }
}

//extension AnyGradient {
//    public func colorSpace(_ space: Gradient.ColorSpace) -> AnyGradient {
//        preconditionFailure("TODO")
//    }
//}
