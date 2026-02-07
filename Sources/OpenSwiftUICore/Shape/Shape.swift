//
//  Shape.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

// MARK: - Shape

/// A 2D shape that you can use when drawing a view.
///
/// Shapes without an explicit fill or stroke get a default fill based on the
/// foreground color.
///
/// You can define shapes in relation to an implicit frame of reference, such as
/// the natural size of the view that contains it. Alternatively, you can define
/// shapes in terms of absolute coordinates.
@available(OpenSwiftUI_v1_0, *)
public protocol Shape: Sendable, Animatable, View, _RemoveGlobalActorIsolation {

    /// Describes this shape as a path within a rectangular frame of reference.
    ///
    /// - Parameter rect: The frame of reference for describing this shape.
    ///
    /// - Returns: A path that describes this shape.
    nonisolated func path(in rect: CGRect) -> Path

    /// An indication of how to style a shape.
    ///
    /// OpenSwiftUI looks at a shape's role when deciding how to apply a
    /// ``ShapeStyle`` at render time. The ``Shape`` protocol provides a
    /// default implementation with a value of ``ShapeRole/fill``. If you
    /// create a composite shape, you can provide an override of this property
    /// to return another value, if appropriate.
    @available(OpenSwiftUI_v3_0, *)
    nonisolated static var role: ShapeRole { get }

    /// Returns the behavior this shape should use for different layout
    /// directions.
    ///
    /// If the layoutDirectionBehavior for a Shape is one that mirrors, the
    /// shape's path will be mirrored horizontally when in the specified layout
    /// direction. When mirrored, the individual points of the path will be
    /// transformed.
    ///
    /// Defaults to `.mirrors` when deploying on iOS 17.0, macOS 14.0,
    /// tvOS 17.0, watchOS 10.0 and later, and to `.fixed` if not.
    /// To mirror a path when deploying to earlier releases, either use
    /// `View.flipsForRightToLeftLayoutDirection` for a filled or stroked
    /// shape or conditionally mirror the points in the path of the shape.
    @available(OpenSwiftUI_v5_0, *)
    nonisolated var layoutDirectionBehavior: LayoutDirectionBehavior { get }

    /// Returns the size of the view that will render the shape, given
    /// a proposed size.
    ///
    /// Implement this method to tell the container of the shape how
    /// much space the shape needs to render itself, given a size
    /// proposal.
    ///
    /// See ``Layout/sizeThatFits(proposal:subviews:cache:)``
    /// for more details about how the layout system chooses the size of
    /// views.
    ///
    /// - Parameters:
    ///   - proposal: A size proposal for the container.
    ///
    /// - Returns: A size that indicates how much space the shape needs.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize
}

@available(OpenSwiftUI_v4_0, *)
extension Shape {
    /// Returns the original proposal, with nil components replaced by
    /// a small positive value.
    nonisolated public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
}

// MARK: - ShapeRole

/// Ways of styling a shape.
@available(OpenSwiftUI_v3_0, *)
public enum ShapeRole: Sendable {
    /// Indicates to the shape's style that OpenSwiftUI fills the shape.
    case fill

    /// Indicates to the shape's style that OpenSwiftUI applies a stroke to
    /// the shape's path.
    case stroke

    /// Indicates to the shape's style that OpenSwiftUI uses the shape as a
    /// separator.
    case separator
}

@available(OpenSwiftUI_v3_0, *)
extension Shape {
    public static var role: ShapeRole { .fill }
}

@available(OpenSwiftUI_v5_0, *)
extension Shape {
    public var layoutDirectionBehavior: LayoutDirectionBehavior {
        isDeployedOnOrAfter(.v5) ? .mirrors(in: .rightToLeft) : .fixed
    }

    package func effectivePath(in rect: CGRect) -> Path {
        let p = path(in: rect)
        let behavior = layoutDirectionBehavior
        guard behavior != .fixed,
              let proxy = GeometryProxy.current
        else {
            return p
        }
        let direction = proxy.environment.layoutDirection
        guard behavior.shouldFlip(in: direction) else {
            return p
        }
        let transform = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: rect.width, ty: 0)
        return p.applying(transform)
    }
}
