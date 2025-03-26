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

    nonisolated var layoutDirectionBehavior: LayoutDirectionBehavior { get }

    nonisolated func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize
}

extension Shape {
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
