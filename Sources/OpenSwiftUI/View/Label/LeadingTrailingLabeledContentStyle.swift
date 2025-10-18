//
//  LeadingTrailingLabeledContentStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 883FC595DC5A078A9D167DD7587DD054 (SwiftUI)

import OpenSwiftUICore

// MARK: - ListLabeledContentPrefersHorizontalLayout

struct ListLabeledContentPrefersHorizontalLayout: ViewInputBoolFlag {}

extension View {
    func listLabeledContentPrefersHorizontalLayout() -> some View {
        input(ListLabeledContentPrefersHorizontalLayout.self)
    }
}
