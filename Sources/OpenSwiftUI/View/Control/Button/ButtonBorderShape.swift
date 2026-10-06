//
//  ButtonBorderShape.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
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

// MARK: - ButtonBorderShape

/// A shape used to draw a button's border.
///
/// Use the ``View/buttonBorderShape(_:)`` view modifier to apply the shape to
/// bordered buttons within a view hierarchy.
@available(OpenSwiftUI_v3_0, *)
public struct ButtonBorderShape: Equatable, Sendable {
    enum Guts: Equatable, Sendable {
        case automatic
        case capsule
        case roundedRectangleAutomatic
        case roundedRectangle(radius: CGFloat)
        case circle
    }

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
    // macOS + tvOS: OpenSwiftUI_v5_0
    // @available(macOS 14.0, tvOS 17.0, *)
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
    // macOS + tvOS: OpenSwiftUI_v5_0
    // @available(macOS 14.0, tvOS 17.0, *)
    public static func roundedRectangle(radius: CGFloat) -> ButtonBorderShape {
        ButtonBorderShape(guts: .roundedRectangle(radius: radius))
    }

    /// A circular shape.
    ///
    /// Use the ``View/buttonBorderShape(_:)`` view modifier to apply the shape
    /// to bordered buttons within a view hierarchy.
    @available(OpenSwiftUI_v5_0, *)
    public static let circle = ButtonBorderShape(guts: .circle)
}

extension ButtonBorderShape {
    @_spi(UIFrameworks)
    @available(OpenSwiftUI_v4_0, *)
    @available(macOS, unavailable)
    public var cornerRadius: CGFloat? {
        guard case let .roundedRectangle(radius) = guts else {
            return nil
        }
        return radius
    }
}

// MARK: - ButtonBorderShape + Shape

@available(OpenSwiftUI_v5_0, *)
extension ButtonBorderShape: Shape {
    nonisolated public func path(in rect: CGRect) -> Path {
        guard let proxy = GeometryProxy.current else {
            return Path(rect)
        }
        return ResolvedBorderShape(
            controlSize: proxy.environment.controlSize,
            base: proxy.environment._buttonBorderShape,
            padding: .zero
        ).path(in: rect)
    }
}

@available(OpenSwiftUI_v5_0, *)
extension Shape where Self == ButtonBorderShape {
    /// A shape that defers to the environment to determine the resolved button border shape.
    ///
    /// You can override the resolved shape in a given view hierarchy by using
    /// the ``View/buttonBorderShape(_:)`` modifier. If no button border shape
    /// is specified, it is resolved automatically for the given context and platform.
    public static var buttonBorder: ButtonBorderShape {
        .automatic
    }
}

// MARK: - ButtonBorderShapeKey

private struct ButtonBorderShapeKey: EnvironmentKey {
    static let defaultValue: ButtonBorderShape = .automatic
}

// MARK: - EnvironmentValues + ButtonBorderShape

@available(OpenSwiftUI_v3_0, *)
extension EnvironmentValues {
    @usableFromInline
    var _buttonBorderShape: ButtonBorderShape {
        get { self[ButtonBorderShapeKey.self] }
        set { self[ButtonBorderShapeKey.self] = newValue }
    }
}

// MARK: - BorderedButtonStyle + ButtonStyleConvertible

@_spi(UIFrameworks)
extension BorderedButtonStyle: ButtonStyleConvertible {
    @MainActor
    @preconcurrency
    public var buttonStyleRepresentation: some ButtonStyle {
        #if os(iOS) || os(visionOS)
        BorderedButtonStyle_Phone(tint: nil, isProminent: isProminent)
        #elseif os(macOS)
        // TODO
        _openSwiftUIPlatformUnimplementedWarning()
        return BorderedButtonStyle_Phone(tint: nil, isProminent: isProminent)
        #else
        // TODO
        _openSwiftUIPlatformUnimplementedWarning()
        return BorderedButtonStyle_Phone(tint: nil, isProminent: isProminent)
        #endif
    }
}

@_spi(Private)
extension EnvironmentValues {
    public var buttonBorderShape: ButtonBorderShape {
        _buttonBorderShape
    }
}

// MARK: - BorderedButtonStyle + BorderShape

@_spi(_)
@available(OpenSwiftUI_v3_0, *)
@available(*, deprecated, message: "Use View.buttonBorderShape(_:) instead.")
extension BorderedButtonStyle {
    public struct BorderShape {
        var rawValue: Int

        public static let automatic = BorderShape(rawValue: 0)

        @available(tvOS, unavailable)
        @available(macOS, unavailable)
        public static let capsule = BorderShape(rawValue: 1)

        public static let roundedRectangle = BorderShape(rawValue: 2)
    }

    public init(shape: BorderShape) {
        self.init()
    }
}

@_spi(_)
@available(*, unavailable)
extension BorderedButtonStyle.BorderShape: Sendable {}

// MARK: - ButtonBorderShape + InsettableShape

@available(OpenSwiftUI_v5_0, *)
extension ButtonBorderShape: InsettableShape {
    @inlinable
    nonisolated public func inset(by amount: CGFloat) -> some InsettableShape {
        _Inset(amount: amount)
    }

    @usableFromInline
    @frozen
    struct _Inset: InsettableShape {
        @usableFromInline
        var amount: CGFloat

        @inlinable
        init(amount: CGFloat) {
            self.amount = amount
        }

        @usableFromInline
        nonisolated func path(in rect: CGRect) -> Path {
            ButtonBorderShape.automatic.path(in: rect.insetBy(dx: amount, dy: amount))
        }

        @usableFromInline
        nonisolated var layoutDirectionBehavior: LayoutDirectionBehavior {
            .fixed
        }

        @usableFromInline
        var animatableData: CGFloat {
            get { amount }
            set { amount = newValue }
        }

        @inlinable
        nonisolated func inset(by amount: CGFloat) -> ButtonBorderShape._Inset {
            var copy = self
            copy.amount += amount
            return copy
        }
    }
}

// MARK: - ButtonContainerIsBorderedInput

struct ButtonContainerIsBorderedInput: ViewInputBoolFlag {}

// MARK: - ResolvedBorderShape

struct ResolvedBorderShape: Shape {
    var controlSize: ControlSize
    var base: ButtonBorderShape
    var padding: EdgeInsets

    nonisolated func path(in rect: CGRect) -> Path {
        let rect = rect.inset(by: padding)
        switch base.guts {
        case .automatic:
            if controlSize == .regular || controlSize == .large {
                let radius = ceil(rect.size.height * 0.35 * 0.5)
                return RoundedRectangle(cornerRadius: radius, style: .continuous).path(in: rect)
            } else {
                return Capsule(style: .continuous).path(in: rect)
            }
        case .capsule:
            return Capsule(style: .continuous).path(in: rect)
        case .roundedRectangleAutomatic:
            let radius = ceil(rect.size.height * 0.35 * 0.5)
            return RoundedRectangle(cornerRadius: radius, style: .continuous).path(in: rect)
        case let .roundedRectangle(radius):
            return RoundedRectangle(cornerRadius: radius, style: .continuous).path(in: rect)
        case .circle:
            return Circle().path(in: rect)
        }
    }
}
