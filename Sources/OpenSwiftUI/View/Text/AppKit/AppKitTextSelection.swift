//
//  AppKitTextSelection.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 3295A461CF58C7D9B54CD05769AF1D5B (SwiftUI?)

#if os(macOS)
import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - AppKitTextSelectionRepresentation

struct AppKitTextSelectionRepresentation: PlatformTextSelectionRepresentation {
    static func makeSelectableText(
        resolvedText: Attribute<ResolvedStyledText>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}
#endif
