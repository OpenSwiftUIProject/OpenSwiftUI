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
    @available(watchOS, deprecated: 100000.0, message: "Use ``View/tint(_)`` instead.")
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(visionOS, unavailable)
    nonisolated public init(tint: Color) {
        self.tint = tint
        self.isProminent = false
    }

    public func makeBody(configuration: Configuration) -> some View {
        #if canImport(Darwin)
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
        #elseif UIKIT_CROSS_PLATFORM
        Button(configuration)
            .buttonStyle(PortableBorderedButtonStyle(tint: tint, isProminent: isProminent))
            .input(ButtonContainerIsBorderedInput.self)
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}

#if UIKIT_CROSS_PLATFORM
struct PortableBorderedButtonStyle: ButtonStyle {
    @Environment(\.tintColor) private var environmentTint: Color?
    @Environment(\._buttonBorderShape) private var borderShape: ButtonBorderShape
    @Environment(\.controlSize) private var controlSize: ControlSize
    @Environment(\.isEnabled) private var isEnabled: Bool

    let tint: Color?
    let isProminent: Bool

    func makeBody(configuration: Configuration) -> some View {
        let resolvedTint = tint ?? environmentTint ?? .accentColor
        let shape = ResolvedBorderShape(
            controlSize: controlSize,
            base: borderShape,
            padding: .zero
        )
        let horizontalPadding: CGFloat = borderShape == .circle ? 10 : 12
        let verticalPadding: CGFloat = borderShape == .circle ? 10 : 7
        return configuration.label
            .foregroundStyle(isProminent ? Color.white : resolvedTint)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background {
                shape.fill(
                    resolvedTint.opacity(
                        isProminent
                            ? (configuration.isPressed ? 0.78 : 1.0)
                            : (configuration.isPressed ? 0.24 : 0.15)
                    )
                )
            }
            .opacity(isEnabled ? 1.0 : 0.45)
            .contentShape(shape)
    }
}
#endif

@available(*, unavailable)
extension BorderedButtonStyle: Sendable {}
