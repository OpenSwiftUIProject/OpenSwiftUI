//
//  BorderedProminentButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - PrimitiveButtonStyle + BorderedProminentButtonStyle

@available(OpenSwiftUI_v3_0, *)
extension PrimitiveButtonStyle where Self == BorderedProminentButtonStyle {
    /// A button style that applies standard border prominent artwork based on
    /// the button's context.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(_:)`` modifier.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var borderedProminent: BorderedProminentButtonStyle {
        .init()
    }
}

// MARK: - BorderedProminentButtonStyle

/// A button style that applies standard border prominent artwork based
/// on the button's context.
///
/// Use ``PrimitiveButtonStyle/borderedProminent`` to construct this style.
@available(OpenSwiftUI_v3_0, *)
public struct BorderedProminentButtonStyle: PrimitiveButtonStyle {
    /// Creates a bordered prominent button style.
    nonisolated public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        Button(configuration)
            #if !os(macOS)
            .modifier(StaticIf(
                idiom: .clarityUI,
                then: ButtonStyleContainerModifier(style: PlatterButtonStyle(isProminent: true)),
                else: EmptyModifier()
            ))
            #endif
            .modifier(StaticIf(
                idiom: .widget,
                then: ButtonStyleContainerModifier(style: WidgetBorderedProminentButtonStyle()),
                else: EmptyModifier()
            ))
            #if os(macOS)
            .buttonStyle(BorderedButtonStyle_CarMac(tint: nil, isProminent: true))
            #else
            .modifier(StaticIf(
                idiom: .carPlay,
                then: PrimitiveButtonStyleContainerModifier(
                    style: BorderedButtonStyle_CarMac(tint: nil, isProminent: true)
                ),
                else: EmptyModifier()
            ))
            .buttonStyle(buttonStyleRepresentation)
            #endif
            .input(ButtonContainerIsBorderedInput.self)
    }
}

@available(*, unavailable)
extension BorderedProminentButtonStyle: Sendable {}

#if os(iOS) || os(visionOS)

// MARK: - BorderedProminentButtonStyle + ButtonStyleConvertible

@_spi(UIFrameworks)
extension BorderedProminentButtonStyle: ButtonStyleConvertible {
    @MainActor
    @preconcurrency
    public var buttonStyleRepresentation: some ButtonStyle {
        BorderedButtonStyle_Phone(tint: nil, isProminent: true)
    }
}

#endif
