//
//  Shapes.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP

public import Foundation

// MARK: - Rectangle + Extension

extension Shape where Self == Rectangle {
    /// A rectangular shape aligned inside the frame of the view containing it.
    @_alwaysEmitIntoClient
    public static var rect: Rectangle { .init() }
}

// MARK: - Rectangle

/// A rectangular shape aligned inside the frame of the view containing it.
@frozen
public struct Rectangle: Shape {
    nonisolated public func path(in rect: CGRect) -> Path {
        Path(rect)
    }

    nonisolated public var layoutDirectionBehavior: LayoutDirectionBehavior {
        .fixed
    }

    /// Creates a new rectangle shape.
    @inlinable
    public init() {}
}

// MARK: - RoundedRectangle + Extension

 extension Shape where Self == RoundedRectangle {
     /// A rectangular shape with rounded corners, aligned inside the frame of
     /// the view containing it.
     @_alwaysEmitIntoClient
     public static func rect(cornerSize: CGSize, style: RoundedCornerStyle = .continuous) -> Self {
         .init(cornerSize: cornerSize, style: style)
     }

     /// A rectangular shape with rounded corners, aligned inside the frame of
     /// the view containing it.
     @_alwaysEmitIntoClient
     public static func rect(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous) -> Self {
         .init(cornerRadius: cornerRadius, style: style)
     }
}

// MARK: - RoundedRectangle

/// A rectangular shape with rounded corners, aligned inside the frame of the
/// view containing it.
@frozen
public struct RoundedRectangle: Shape {
    /// The width and height of the rounded rectangle's corners.
    public var cornerSize: CGSize

    /// The style of corners drawn by the rounded rectangle.
    public var style: RoundedCornerStyle

    /// Creates a new rounded rectangle shape.
    ///
    /// - Parameters:
    ///   - cornerSize: the width and height of the rounded corners.
    ///   - style: the style of corners drawn by the shape.
    @inlinable
    public init(cornerSize: CGSize, style: RoundedCornerStyle = .continuous) {
        self.cornerSize = cornerSize
        self.style = style
    }

    /// Creates a new rounded rectangle shape.
    ///
    /// - Parameters:
    ///   - cornerRadius: the radius of the rounded corners.
    ///   - style: the style of corners drawn by the shape.
    @inlinable
    nonisolated public init(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous) {
        let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
        self.init(cornerSize: cornerSize, style: style)
    }

    nonisolated public func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerSize: cornerSize, style: style)
    }

    nonisolated public var layoutDirectionBehavior: LayoutDirectionBehavior {
        .fixed
    }

    public var animatableData: CGSize.AnimatableData {
        get { cornerSize.animatableData }
        set { cornerSize.animatableData = newValue }
    }
}

// MARK: - UnevenRoundedRectangle + Extension

extension Shape where Self == UnevenRoundedRectangle {
    /// A rectangular shape with rounded corners with different values, aligned
    /// inside the frame of the view containing it.
    @_alwaysEmitIntoClient
    public static func rect(cornerRadii: RectangleCornerRadii, style: RoundedCornerStyle = .continuous) -> Self {
        .init(cornerRadii: cornerRadii, style: style)
    }

    /// A rectangular shape with rounded corners with different values, aligned
    /// inside the frame of the view containing it.

    @_alwaysEmitIntoClient
    public static func rect(topLeadingRadius: CGFloat = 0, bottomLeadingRadius: CGFloat = 0, bottomTrailingRadius: CGFloat = 0, topTrailingRadius: CGFloat = 0, style: RoundedCornerStyle = .continuous) -> Self {
        .init(
            topLeadingRadius: topLeadingRadius,
            bottomLeadingRadius: bottomLeadingRadius,
            bottomTrailingRadius: bottomTrailingRadius,
            topTrailingRadius: topTrailingRadius, style: style
        )
    }
}

// MARK: - UnevenRoundedRectangle

/// A rectangular shape with rounded corners with different values, aligned
/// inside the frame of the view containing it.
@frozen
public struct UnevenRoundedRectangle: Shape {
    /// The radii of each corner of the rounded rectangle.
    public var cornerRadii: RectangleCornerRadii

    /// The style of corners drawn by the rounded rectangle.
    public var style: RoundedCornerStyle

    /// Creates a new rounded rectangle shape with uneven corners.
    ///
    /// - Parameters:
    ///   - cornerRadii: the radii of each corner.
    ///   - style: the style of corners drawn by the shape.
    @inlinable
    public init(cornerRadii: RectangleCornerRadii, style: RoundedCornerStyle = .continuous) {
        self.cornerRadii = cornerRadii
        self.style = style
    }

    /// Creates a new rounded rectangle shape with uneven corners.
    @_alwaysEmitIntoClient
    public init(topLeadingRadius: CGFloat = 0, bottomLeadingRadius: CGFloat = 0, bottomTrailingRadius: CGFloat = 0, topTrailingRadius: CGFloat = 0, style: RoundedCornerStyle = .continuous) {
        self.init(
            cornerRadii: .init(
                topLeading: topLeadingRadius,
                bottomLeading: bottomLeadingRadius,
                bottomTrailing: bottomTrailingRadius,
                topTrailing: topTrailingRadius
            ),
            style: style
        )
    }

    nonisolated public func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadii: cornerRadii, style: style)
    }

    public var animatableData: RectangleCornerRadii.AnimatableData {
        get { cornerRadii.animatableData }
        set { cornerRadii.animatableData = newValue }
    }
}

// MARK: - Capsule + Extension

extension Shape where Self == Capsule {
    /// A capsule shape aligned inside the frame of the view containing it.
    ///
    /// A capsule shape is equivalent to a rounded rectangle where the corner
    /// radius is chosen as half the length of the rectangle's smallest edge.
    @_alwaysEmitIntoClient
    public static var capsule: Capsule {
        .init()
    }

    /// A capsule shape aligned inside the frame of the view containing it.
    ///
    /// A capsule shape is equivalent to a rounded rectangle where the corner
    /// radius is chosen as half the length of the rectangle's smallest edge.
    @_alwaysEmitIntoClient
    public static func capsule(style: RoundedCornerStyle) -> Self {
        .init(style: style)
    }
}

// MARK: - Capsule

/// A capsule shape aligned inside the frame of the view containing it.
///
/// A capsule shape is equivalent to a rounded rectangle where the corner radius
/// is chosen as half the length of the rectangle's smallest edge.
@frozen
public struct Capsule: Shape {
    public var style: RoundedCornerStyle

    /// Creates a new capsule shape.
    ///
    /// - Parameters:
    ///   - style: the style of corners drawn by the shape.
    @inlinable
    public init(style: RoundedCornerStyle = .continuous) {
        self.style = style
    }

    nonisolated public func path(in r: CGRect) -> Path {
        let radius = min(r.width, r.height) / 2
        return Path(roundedRect: r, cornerRadius: radius, style: style)
    }

    nonisolated public var layoutDirectionBehavior: LayoutDirectionBehavior {
        .fixed
    }
}

// MARK: - Ellipse + Extension

extension Shape where Self == Ellipse {
    /// An ellipse aligned inside the frame of the view containing it.
    @_alwaysEmitIntoClient
    public static var ellipse: Ellipse { .init() }
}

// MARK: - Ellipse

/// An ellipse aligned inside the frame of the view containing it.
@frozen
public struct Ellipse: Shape {
    nonisolated public func path(in rect: CGRect) -> Path {
        Path(ellipseIn: rect)
    }

    /// Creates a new ellipse shape.
    @inlinable
    public init() {}

    nonisolated public var layoutDirectionBehavior: LayoutDirectionBehavior {
        .fixed
    }
}

// MARK: - Circle + Extension

extension Shape where Self == Circle {
    /// A circle centered on the frame of the view containing it.
    ///
    /// The circle's radius equals half the length of the frame rectangle's
    /// smallest edge.
    @_alwaysEmitIntoClient
    public static var circle: Circle { .init() }
}

// MARK: - Circle

/// A circle centered on the frame of the view containing it.
///
/// The circle's radius equals half the length of the frame rectangle's smallest
/// edge.
@frozen public struct Circle: Shape {
    nonisolated public func path(in rect: CGRect) -> Path {
        guard !rect.isNull, !rect.isInfinite else {
            return rect.isNull ? Path() : Path(rect)
        }
        var square = rect
        let diff = rect.width - rect.height
        if diff > 0 {
            square.x += diff / 2
            square.size.width = square.height
        } else if diff < 0 {
            square.y -= diff / 2
            square.size.height = square.width
        } else {
            square = rect
        }
        return Path(ellipseIn: square)
    }

    /// Creates a new circle shape.
    @inlinable
    public init() {}

    nonisolated public var layoutDirectionBehavior: LayoutDirectionBehavior {
        .fixed
    }
}

extension Circle {
    nonisolated public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let minValue = min(size.width, size.height)
        return CGSize(width: minValue, height: minValue)
    }
}
