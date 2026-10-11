//
//  ProjectionEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenCoreGraphicsShims
public import OpenSwiftUICore

// MARK: - _ProjectionEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _ProjectionEffect: GeometryEffect, Equatable {
    public var transform: ProjectionTransform

    @inlinable
    nonisolated public init(transform: ProjectionTransform) {
        self.transform = transform
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        transform
    }
}

// MARK: - View + projectionEffect

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Applies a projection transformation to this view's rendered output.
    ///
    /// Use `projectionEffect(_:)` to apply a 3D transformation to the view.
    ///
    /// The example below rotates the text 30˚ around the `z` axis, which is the
    /// axis pointing out of the screen:
    ///
    ///     // This transform represents a 30˚ rotation around the z axis.
    ///     let transform = CATransform3DMakeRotation(
    ///         -30 * (.pi / 180), 0.0, 0.0, 1.0)
    ///
    ///     Text("Projection effects using transforms")
    ///         .projectionEffect(.init(transform))
    ///         .border(Color.gray)
    ///
    /// ![A screenshot showing text rotated 30 degrees around the axis pointing
    /// out of the screen.](OpenSwiftUI-View-projectionEffect)
    ///
    /// - Parameter transform: A ``ProjectionTransform`` to apply to the view.
    @inlinable
    nonisolated public func projectionEffect(_ transform: ProjectionTransform) -> some View {
        modifier(_ProjectionEffect(transform: transform))
    }
}
