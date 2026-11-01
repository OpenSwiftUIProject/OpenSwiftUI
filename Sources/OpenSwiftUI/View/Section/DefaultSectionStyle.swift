//
//  DefaultSectionStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

struct DefaultSectionStyle: SectionStyle {
    func makeBody(configuration: Configuration) -> some View {
        var section = Section(
            header: configuration.header,
            content: configuration.content,
            footer: configuration.footer
        )
        section.isExpanded = configuration.isExpanded
        return section
            .sectionStyle(SidebarSectionStyle(), in: SidebarListStyleContext())
            #if os(macOS)
            .sectionStyle(TextInputSuggestionSectionStyle(), in: TextInputSuggestionsContext())
            .sectionStyle(SidebarSectionStyle(), in: SystemPreferencesSidebarListStyleContext())
            #endif
            .sectionStyle(MenuSectionStyle(), in: MenuStyleContext())
            #if !os(macOS)
            .sectionStyle(InlineActionsSectionStyle(), in: AnyListStyleContext())
            #endif
            .sectionStyle(PlainSectionStyle())
    }
}
