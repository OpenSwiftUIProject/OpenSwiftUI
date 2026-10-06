//
//  ButtonBorderShape.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7F5E2B4AB82752C449656AF5FDACFF02 (SwiftUI)

public import Foundation
public import OpenSwiftUICore

// MARK: - View + ButtonBorderShape

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Sets the border shape for buttons in this view.
    ///
    /// The border shape is used to draw the platter for a bordered button.
    /// In macOS, some border shapes are only applicable to bordered
    /// buttons in widgets.
    ///
    /// The border shape affects buttons of the
    /// ``PrimitiveButtonStyle/bordered`` and
    /// ``PrimitiveButtonStyle/borderedProminent`` styles.
    ///
    /// - Parameter shape: The shape to use.
    @inlinable
    nonisolated public func buttonBorderShape(_ shape: ButtonBorderShape) -> some View {
        environment(\._buttonBorderShape, shape)
    }
}

// MARK: - ButtonBorderShape [WIP]

/// A shape used to draw a button's border.
///
/// Use the ``View/buttonBorderShape(_:)`` view modifier to apply the shape to
/// bordered buttons within a view hierarchy.
@available(OpenSwiftUI_v3_0, *)
public struct ButtonBorderShape: Equatable, Sendable {
    var guts: Guts

    /// A shape that defers to the system to determine an appropriate shape
    /// for the given context and platform.
    ///
    /// Use the ``View/buttonBorderShape(_:)`` view modifier to apply the shape
    /// to bordered buttons within a view hierarchy.
    public static let automatic = ButtonBorderShape(guts: .automatic)

    /// A capsule shape.
    ///
    /// Use the ``View/buttonBorderShape(_:)`` view modifier to apply the shape
    /// to bordered buttons within a view hierarchy.
    ///
    /// - Note: This has no effect on non-widget system buttons in macOS.
    @available(macOS 14.0, tvOS 17.0, *)
    public static let capsule = ButtonBorderShape(guts: .capsule)

    /// A rounded rectangle shape.
    ///
    /// Use the ``View/buttonBorderShape(_:)`` view modifier to apply the shape
    /// to bordered buttons within a view hierarchy.
    public static let roundedRectangle = ButtonBorderShape(guts: .roundedRectangleAutomatic)

    /// A rounded rectangle shape.
    ///
    /// Use the ``View/buttonBorderShape(_:)`` view modifier to apply the shape
    /// to bordered buttons within a view hierarchy.
    ///
    /// - Parameter radius: The corner radius of the rectangle.
    /// - Note: This has no effect on non-widget system buttons in macOS.
    @available(macOS 14.0, tvOS 17.0, *)
    public static func roundedRectangle(radius: CGFloat) -> ButtonBorderShape {
        ButtonBorderShape(guts: .roundedRectangle(radius: radius))
    }

    /// A circular shape.
    ///
    /// Use the ``View/buttonBorderShape(_:)`` view modifier to apply the shape
    /// to bordered buttons within a view hierarchy.
    @available(iOS 17.0, macOS 14.0, tvOS 16.4, watchOS 10.0, *)
    public static let circle = ButtonBorderShape(guts: .circle)

    // TODO: Add Shape and InsettableShape conformances.
}

// MARK: - ButtonBorderShape.Guts

extension ButtonBorderShape {
    enum Guts: Equatable, Sendable {
        case roundedRectangle(radius: CGFloat)
        case automatic
        case capsule
        case roundedRectangleAutomatic
        case circle
    }
}

// MARK: - EnvironmentValues + ButtonBorderShape

@available(OpenSwiftUI_v3_0, *)
extension EnvironmentValues {
    @usableFromInline
    var _buttonBorderShape: ButtonBorderShape {
        get { self[ButtonBorderShapeKey.self] }
        set { self[ButtonBorderShapeKey.self] = newValue }
    }

    @_spi(Private)
    public var buttonBorderShape: ButtonBorderShape {
        self[ButtonBorderShapeKey.self]
    }
}

// MARK: - ButtonContainerIsBorderedInput

struct ButtonContainerIsBorderedInput: ViewInputBoolFlag {}

// TODO: ResolvedBorderShape

// MARK: - ButtonBorderShapeKey

private struct ButtonBorderShapeKey: EnvironmentKey {
    static let defaultValue: ButtonBorderShape = .automatic
}
