//
//  UIKitTextSelection.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: ACB31533DB70E029184E072EF83FF254 (SwiftUI?)

#if os(iOS) || os(visionOS)
import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - UIKitTextSelectionRepresentation

struct UIKitTextSelectionRepresentation: PlatformTextSelectionRepresentation {
    static func makeSelectableText(
        resolvedText: Attribute<ResolvedStyledText>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}
#endif
