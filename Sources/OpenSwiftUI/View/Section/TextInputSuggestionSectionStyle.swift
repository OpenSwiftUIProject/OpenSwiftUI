//
//  TextInputSuggestionSectionStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import OpenSwiftUICore

#if os(macOS)
struct TextInputSuggestionSectionStyle: SectionStyle {
    func makeBody(configuration: Configuration) -> some View {
        // TODO: SuggestionSection and SuggestionMetrics.
        _openSwiftUIUnimplementedWarning()
        return EmptyView()
    }
}
#endif
