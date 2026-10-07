//
//  PlainButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: AEEE04F3F0E4AB1B61A885733139FBF6 (SwiftUI)

public import OpenSwiftUICore

// MARK: - PrimitiveButtonStyle + PlainButtonStyle

@available(OpenSwiftUI_v1_0, *)
extension PrimitiveButtonStyle where Self == PlainButtonStyle {
    /// A button style that doesn't style or decorate its content while idle,
    /// but may apply a visual effect to indicate the pressed, focused, or
    /// enabled state of the button.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(_:)`` modifier.
    @_alwaysEmitIntoClient
    public static var plain: PlainButtonStyle {
        PlainButtonStyle()
    }
}

// MARK: - PlainButtonStyle

/// A button style that doesn't style or decorate its content while idle, but
/// may apply a visual effect to indicate the pressed, focused, or enabled state
/// of the button.
///
/// You can also use ``PrimitiveButtonStyle/plain`` to construct this style.
@available(OpenSwiftUI_v1_0, *)
public struct PlainButtonStyle {
    /// Creates a plain button style.
    public init() {
        _openSwiftUIEmptyStub()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension PlainButtonStyle: PrimitiveButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        Button(configuration)
            .buttonStyle(buttonStyleRepresentation)
    }
}

@available(*, unavailable)
extension PlainButtonStyle: Sendable {}

// MARK: - PlainButtonStyle + ButtonStyleConvertible

@_spi(UIFrameworks)
extension PlainButtonStyle: ButtonStyleConvertible {
    @MainActor
    @preconcurrency
    public var buttonStyleRepresentation: some ButtonStyle {
        PlainButtonStyleBase()
    }
}

// MARK: - PlainButtonStyleBase

private struct PlainButtonStyleBase: ButtonStyle {
    @Environment(\.isEnabled)
    private var isEnabled: Bool

    @Environment(\.isFocused)
    private var isFocused: Bool

    nonisolated init() {
        _openSwiftUIEmptyStub()
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
        }
        .modifier(OpacityRendererEffect(opacity: isEnabled ? (configuration.isPressed ? 0.75 : 1.0) : 0.5))
    }
}
