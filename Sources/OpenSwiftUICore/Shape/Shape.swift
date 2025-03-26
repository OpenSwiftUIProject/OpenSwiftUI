//
//  Shape.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by GeometryProxy

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
    nonisolated func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize
}

extension Shape {
    /// Returns the original proposal, with nil components replaced by
    /// a small positive value.
    nonisolated public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
}


// MARK: - ShapeRole

/// Ways of styling a shape.
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

extension Shape {
    public static var role: ShapeRole {
        .fill
    }
}

extension Shape {
    public var layoutDirectionBehavior: LayoutDirectionBehavior {
        isDeployedOnOrAfter(.v5) ? .mirrors(in: .rightToLeft) : .fixed
    }

    package func effectivePath(in rect: CGRect) -> Path {
        // _threadGeometryProxyData
        preconditionFailure("TODO")
    }
}

/// An absolute shape that has been stroked.
@frozen
public struct _StrokedShape<S>: Shape where S: Shape {
    /// The source shape.
    public var shape: S

    /// The stroke style.
    public var style: StrokeStyle

    @inlinable
    public init(shape: S, style: StrokeStyle) {
        self.shape = shape
        self.style = style
    }

    nonisolated public func path(in rect: CGRect) -> Path {
        shape.path(in: rect).strokedPath(style)
    }

    nonisolated public static var role: ShapeRole {
        .stroke
    }

    nonisolated public var layoutDirectionBehavior: LayoutDirectionBehavior {
        shape.layoutDirectionBehavior
    }

    public var animatableData: AnimatablePair<S.AnimatableData, StrokeStyle.AnimatableData> {
        get {
            AnimatablePair(shape.animatableData, style.animatableData)
        }
        set {
            shape.animatableData = newValue.first
            style.animatableData = newValue.second
        }
    }

    nonisolated public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        shape.sizeThatFits(proposal)
    }
}

extension Shape {
    /// Returns a new shape that is a stroked copy of `self`, using the
    /// contents of `style` to define the stroke characteristics.
    @inlinable
    nonisolated public func stroke(style: StrokeStyle) -> some Shape {
        return _StrokedShape(shape: self, style: style)
    }

    /// Returns a new shape that is a stroked copy of `self` with
    /// line-width defined by `lineWidth` and all other properties of
    /// `StrokeStyle` having their default values.
    @inlinable
    nonisolated public func stroke(lineWidth: CoreFoundation.CGFloat = 1) -> some Shape {
        return stroke(style: StrokeStyle(lineWidth: lineWidth))
    }
}
