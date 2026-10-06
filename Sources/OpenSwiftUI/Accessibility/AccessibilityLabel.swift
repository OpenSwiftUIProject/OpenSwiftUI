//
//  AccessibilityLabel.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

// MARK: - View + AccessibilityLabel

extension View {
    func accessibilityLabel<Label>(
        _ placement: AccessibilityLabelStorage.Placement,
        @ViewBuilder label: () -> Label
    ) -> some View where Label: View {
        accessibilityAttachment(content: label()) { tree in
            var label = tree.mergedProperties?.labelStorage
            label?.placement = placement
            var attachment = AccessibilityAttachment()
            attachment.properties.labelStorage = label
            tree = .leaf(attachment)
        }
    }
}
