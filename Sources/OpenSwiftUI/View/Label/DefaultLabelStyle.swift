//
//  DefaultLabelStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - LabelStyle + DefaultLabelStyle

@available(OpenSwiftUI_v2_0, *)
extension LabelStyle where Self == DefaultLabelStyle {
    /// A label style that resolves its appearance automatically based on the
    /// current context.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var automatic: DefaultLabelStyle {
        .init()
    }
}

// MARK: - DefaultLabelStyle

/// The default label style in the current context.
///
/// You can also use ``LabelStyle/automatic`` to construct this style.
@available(OpenSwiftUI_v2_0, *)
public struct DefaultLabelStyle: LabelStyle {
    /// Creates an automatic label style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        Label(configuration)
            .labelStyle(ListLabelStyle(), in: .plainList)
            .labelStyle(SidebarLabelStyle(), in: .sidebarList)
            .labelStyle(InsetListLabelStyle(), in: .insetList)
            .labelStyle(ListLabelStyle(), in: .groupedForm)
            .labelStyle(ListLabelStyle(), in: .groupedList)
            .labelStyle(ListLabelStyle(), in: .insetGroupedList)
            .labelStyle(ToolbarItemLabelStyle(), in: .toolbar)
            .labelStyle(TitleAndIconLabelStyle(), in: .swipeActions)
            .labelStyle(TitleAndIconLabelStyle(), in: .accessibilityQuickAction)
            .labelStyle(AccessibilityLabelStyle(), in: .accessibilityRepresentable)
            .labelStyle(MultimodalListGridLabelStyle(), in: .multimodalListGrid)
            .labelStyle(MultimodalListStackLabelStyle(), in: .multimodalListStack)
            .labelStyle(WrappingLabelStyle(), idiom: .clarityUI)
            .labelStyle(FallbackLabelStyle())
    }
}

@available(*, unavailable)
extension DefaultLabelStyle: Sendable {}
