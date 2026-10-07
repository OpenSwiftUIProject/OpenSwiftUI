//
//  DefaultButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by various of context)

public import OpenSwiftUICore

// MARK: - PrimitiveButtonStyle + DefaultButtonStyle

@available(OpenSwiftUI_v1_0, *)
extension PrimitiveButtonStyle where Self == DefaultButtonStyle {
    /// The default button style, based on the button's context.
    ///
    /// If you create a button directly on a blank canvas, the style varies by
    /// platform. iOS uses the borderless button style by default, whereas macOS,
    /// tvOS, and watchOS use the bordered button style.
    ///
    /// If you create a button inside a container, like a ``List``, the style
    /// resolves to the recommended style for buttons inside that container for
    /// that specific platform.
    ///
    /// You can override a button's style. To apply the default style to a
    /// button, or to a view that contains buttons, use the
    /// ``View/buttonStyle(_:)`` modifier.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var automatic: DefaultButtonStyle {
        .init()
    }
}

// MARK: - DefaultButtonStyle

/// The default button style, based on the button's context.
///
/// You can also use ``PrimitiveButtonStyle/automatic`` to construct this style.
@available(OpenSwiftUI_v1_0, *)
public struct DefaultButtonStyle: PrimitiveButtonStyle {
    /// Creates a default button style.
    nonisolated public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        #if os(macOS) || os(iOS) || os(visionOS)
        Button(configuration)
            // TODO: iOS/visionOS DefaultListButtonStyle in GroupedFormStyleContext.
            // TODO: iOS/visionOS SidebarButtonStyle in SidebarListStyleContext.
            // TODO: DefaultListButtonStyle in AnyListStyleContext.
            .modifier(
                PrimitiveButtonStyleContainerModifier(style: BorderlessButtonStyle())
                    .requiring(TableStyleContext.self)
            )
            // TODO: BorderlessButtonStyle in TabSectionStyleContext.
            .modifier(
                PrimitiveButtonStyleContainerModifier(style: PlatformItemListButtonStyle())
                    .requiring(MenuStyleContext.self)
            )
            .modifier(
                PrimitiveButtonStyleContainerModifier(style: PlatformItemListButtonStyle())
                    .requiring(SwipeActionsStyleContext.self)
            )
            // TODO: iOS/visionOS ToolbarButtonStyle in ToolbarStyleContext.
            // TODO: SearchCompletionButtonStyle(kind: nil) in TextInputSuggestionsContext.
            // TODO: macOS ToolbarButtonStyle in ToolbarStyleContext.
            // TODO: macOS SheetToolbarButtonStyle in SheetToolbarStyleContext.
            // TODO: macOS ListAccessoryBarButtonStyle in ListAccessoryBarStyleContext.
            // TODO: SidebarSectionActionButtonStyle in SidebarSectionActionStyleContext.
            .modifier(
                PrimitiveButtonStyleContainerModifier(style: PlatformItemListButtonStyle())
                    .requiring(AccessibilityQuickActionStyleContext.self)
            )
            .modifier(
                ButtonStyleContainerModifier(style: AccessibilityButtonStyle())
                    .requiring(AccessibilityRepresentableStyleContext.self)
            )
            #if os(iOS) || os(visionOS)
            .modifier(StaticIf(
                idiom: .clarityUI,
                then: ButtonStyleContainerModifier(style: PlatterButtonStyle(isProminent: false)),
                else: EmptyModifier()
            ))
            #endif
            .buttonStyle(PlatformFallbackButtonStyle())
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}

@available(*, unavailable)
extension DefaultButtonStyle: Sendable {}

// MARK: - PlatformFallbackButtonStyle

struct PlatformFallbackButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(configuration)
            .modifier(StaticIf(
                idiom: .widget,
                then: ButtonStyleContainerModifier(style: WidgetBorderedButtonStyle()),
                else: EmptyModifier()
            ))
            #if os(macOS)
            .buttonStyle(BorderedButtonStyle())
            #else
            .modifier(StaticIf(
                idiom: .carPlay,
                then: PrimitiveButtonStyleContainerModifier(
                    style: BorderedButtonStyle_CarMac(tint: nil, isProminent: false)
                ),
                else: EmptyModifier()
            ))
            .buttonStyle(ConditionallyBorderedStyle())
            #endif
    }
}

// MARK: - View + DefaultButtonStyle

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension View {
    nonisolated public func automaticButtonStyle(_ style: some ButtonStyle) -> some View {
        modifier(AutomaticStyleOverrideModifier(
            PlatformFallbackButtonStyle.self,
            modifier: ButtonStyleModifier(style: style)
        ))
    }

    nonisolated public func automaticButtonStyle(_ style: some PrimitiveButtonStyle) -> some View {
        modifier(AutomaticStyleOverrideModifier(
            PlatformFallbackButtonStyle.self,
            modifier: ButtonStyleModifier(style: style)
        ))
    }
}
