//
//  TransformEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenCoreGraphicsShims
public import OpenSwiftUICore

// MARK: - _TransformEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _TransformEffect: GeometryEffect, Equatable {
    public var transform: CGAffineTransform

    @inlinable
    nonisolated public init(transform: CGAffineTransform) {
        self.transform = transform
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(transform)
    }
}

// MARK: - View + transformEffect

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Applies an affine transformation to this view's rendered output.
    ///
    /// Use `transformEffect(_:)` to rotate, scale, translate, or skew the
    /// output of the view according to the provided
    /// [CGAffineTransform](https://developer.apple.com/documentation/corefoundation/cgaffinetransform).
    ///
    /// In the example below, the text is rotated at -30˚ on the `y` axis.
    ///
    ///     let transform = CGAffineTransform(rotationAngle: -30 * (.pi / 180))
    ///
    ///     Text("Projection effect using transforms")
    ///         .transformEffect(transform)
    ///         .border(Color.gray)
    ///
    /// ![A screenshot of a view showing text that is rotated at -30 degrees on
    /// the y axis.](OpenSwiftUI-View-transformEffect)
    ///
    /// - Parameter transform: A
    /// [CGAffineTransform](https://developer.apple.com/documentation/corefoundation/cgaffinetransform) to
    /// apply to the view.
    @inlinable
    nonisolated public func transformEffect(_ transform: CGAffineTransform) -> some View {
        modifier(_TransformEffect(transform: transform))
    }
}

// MARK: - VisualEffect + transformEffect

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Applies a projection transformation to the view's rendered output.
    ///
    /// Use `transformEffect(_:)` to rotate, scale, translate, or skew the
    /// output of the view according to the provided
    /// ``ProjectionTransform``.
    ///
    /// - Parameter transform: A
    /// ``ProjectionTransform`` to
    /// apply to the view.
    ///
    /// - Returns: An effect that applies a projection transformation to the
    ///   view's rendered output.
    public func transformEffect(_ transform: ProjectionTransform) -> some VisualEffect {
        // Visual effects use only the affine components of this transform.
        transformEffect(CGAffineTransform(transform))
    }

    /// Applies an affine transformation to the view's rendered output.
    ///
    /// Use `transformEffect(_:)` to rotate, scale, translate, or skew the
    /// output of the view according to the provided
    /// [CGAffineTransform](https://developer.apple.com/documentation/corefoundation/cgaffinetransform).
    ///
    /// - Parameter transform: A
    /// [CGAffineTransform](https://developer.apple.com/documentation/corefoundation/cgaffinetransform) to
    /// apply to the view.
    ///
    /// - Returns: An effect that applies an affine transformation to the
    ///   view's rendered output.
    ///
    public func transformEffect(_ transform: CGAffineTransform) -> some VisualEffect {
        geometryEffect(_TransformEffect(transform: transform))
    }
}

@_spi(_)
@available(OpenSwiftUI_v5_0, *)
@available(*, deprecated, message: "Use transformEffect instead")
extension VisualEffect {
    public func transform(_ transform: ProjectionTransform) -> some VisualEffect {
        transformEffect(transform)
    }

    public func transform(_ transform: CGAffineTransform) -> some VisualEffect {
        transformEffect(transform)
    }
}

// MARK: - HoverEffectContent + transformEffect

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension HoverEffectContent {
    /// Applies an affine transformation to the view's rendered output.
    ///
    /// Use `transformEffect(_:)` to rotate, scale, translate, or skew the
    /// output of the view according to the provided
    /// [CGAffineTransform](https://developer.apple.com/documentation/corefoundation/cgaffinetransform).
    ///
    /// - Parameter transform: A
    /// [CGAffineTransform](https://developer.apple.com/documentation/corefoundation/cgaffinetransform) to
    /// apply to the view.
    ///
    /// - Returns: An effect that applies an affine transformation to the
    ///   view's rendered output.
    public func transformEffect(_ transform: CGAffineTransform) -> some HoverEffectContent {
        geometryEffect(_TransformEffect(transform: transform))
    }
}
