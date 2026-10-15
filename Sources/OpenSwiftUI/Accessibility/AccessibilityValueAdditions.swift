//
//  AccessibilityValueAdditions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import OpenSwiftUICore

// MARK: - View + AccessibilityValue

extension View {
    func accessibilityValue(
        _ storage: AccessibilityValueStorage
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibility(AccessibilityProperties.ValueKey.self, storage)
    }
}

// MARK: - ModifiedContent + AccessibilityValue

extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    func accessibilityValue(
        _ storage: AccessibilityValueStorage
    ) -> ModifiedContent<Content, Modifier> {
        update(AccessibilityProperties.ValueKey.self, combining: storage)
    }

    func accessibilityValue<V>(
        _ value: V,
        description: Text? = nil
    ) -> ModifiedContent<Content, Modifier> where V: AccessibilityValue, V: Codable {
        accessibilityValue(AccessibilityValueStorage(value, description: description))
    }
}
