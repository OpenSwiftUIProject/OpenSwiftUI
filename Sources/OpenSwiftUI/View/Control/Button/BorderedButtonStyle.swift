//
//  BorderedButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - PrimitiveButtonStyle + BorderedButtonStyle

@available(OpenSwiftUI_v3_0, *)
extension PrimitiveButtonStyle where Self == BorderedButtonStyle {
    /// A button style that applies standard border artwork based on the
    /// button's context.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(_:)`` modifier.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var bordered: BorderedButtonStyle {
        .init()
    }
}

// MARK: - BorderedButtonStyle

/// A button style that applies standard border artwork based on the button's
/// context.
///
/// You can also use ``PrimitiveButtonStyle/bordered`` to construct this style.
@available(OpenSwiftUI_v3_0, *)
public struct BorderedButtonStyle: PrimitiveButtonStyle {
    let tint: Color?
    let isProminent: Bool

    /// Creates a bordered button style.
    nonisolated public init() {
        tint = nil
        isProminent = false
    }

    /// Creates a bordered button style with a tint color.
    @available(*, deprecated, message: "Use ``View/tint(_)`` instead.")
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(visionOS, unavailable)
    nonisolated public init(tint: Color) {
        self.tint = tint
        self.isProminent = false
    }

    public func makeBody(configuration: Configuration) -> some View {
        #if os(macOS) || os(iOS) || os(visionOS)
        Button(configuration)
            #if os(iOS) || os(visionOS)
            .modifier(StaticIf(
                idiom: .clarityUI,
                then: ButtonStyleContainerModifier(style: PlatterButtonStyle(isProminent: isProminent)),
                else: EmptyModifier()
            ))
            #endif
            .modifier(StaticIf(
                idiom: .widget,
                then: ButtonStyleContainerModifier(style: WidgetBorderedButtonStyle()),
                else: EmptyModifier()
            ))
            #if os(macOS)
            .buttonStyle(BorderedButtonStyle_CarMac(tint: tint, isProminent: isProminent))
            #else
            .modifier(StaticIf(
                idiom: .carPlay,
                then: PrimitiveButtonStyleContainerModifier(
                    style: BorderedButtonStyle_CarMac(tint: tint, isProminent: isProminent)
                ),
                else: EmptyModifier()
            ))
            .buttonStyle(BorderedButtonStyle_Phone(tint: tint, isProminent: isProminent))
            #endif
            .input(ButtonContainerIsBorderedInput.self)
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}

@available(*, unavailable)
extension BorderedButtonStyle: Sendable {}
