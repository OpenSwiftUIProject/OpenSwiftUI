//
//  SectionActions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

@available(OpenSwiftUI_v6_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    /// Adds custom actions to a section.
    ///
    /// On iOS, the actions are displayed as items after the content
    /// of the section. On macOS, the actions are displayed
    /// when a user hovers over the section.
    ///
    /// The following example adds an 'Add' button to
    /// the 'Categories' section.
    ///
    ///     List {
    ///         Label("Home", systemImage: "house")
    ///         Label("Alerts", systemImage: "bell")
    ///
    ///         Section("Categories") {
    ///             Label("Climate", systemImage: "fan")
    ///             Label("Lights", systemImage: "lightbulb")
    ///         }
    ///         .sectionActions {
    ///             Button("Add Category", systemImage: "plus") { }
    ///         }
    ///     }
    ///
    nonisolated public func sectionActions<Content>(@ViewBuilder content: () -> Content) -> some View where Content: View {
        let actions = content()
        return viewAlias(SectionStyleConfiguration.Actions.self) {
            actions
        }
        ._trait(SectionActionsTraitKey.self, AnyView(actions))
    }
}

struct SectionActionsTraitKey: _ViewTraitKey {
    static var defaultValue: AnyView? { nil }
}

struct SidebarSectionActionButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(configuration)
            #if os(macOS)
            .buttonStyle(SidebarSectionActionButtonStyle_Mac())
            #else
            .buttonStyle(PlatformItemListButtonStyle())
            #endif
    }
}

struct SidebarSectionActionStyleContext: StyleContext {}

struct InlineActionsSectionStyle: SectionStyle {
    func makeBody(configuration: Configuration) -> some View {
        Section {
            configuration.content
                .sectionStyle(DefaultSectionStyle())
            configuration.actions
                .moveDisabled(true)
                .deleteDisabled(true)
        } header: {
            configuration.header
                .sectionStyle(DefaultSectionStyle())
        } footer: {
            configuration.footer
                .sectionStyle(DefaultSectionStyle())
        }
        .sectionStyle(PlainSectionStyle())
    }
}
