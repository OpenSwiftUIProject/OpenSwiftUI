//
//  AccessibilityGeometry.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: EE68159C4F54001FA5A3813EBA5DD945 (SwiftUI)

@_spi(Private)
import OpenSwiftUICore

// MARK: - IgnoreViewRespondersModifier

private struct IgnoreViewRespondersModifier: PrimitiveViewModifier, ViewInputsModifier {
    nonisolated static func _makeViewInputs(
        modifier _: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.needsAccessibilityViewResponders = false
    }
}

// MARK: - AccessibilityProgressViewModifier [WIP]

struct AccessibilityProgressViewModifier {
    var fractionCompleted: Double?

    func body<Content>(content: Content) -> some View where Content: View {
        content
            .modifier(IgnoreViewRespondersModifier())
            // .modifier(AccessibilityAttachmentModifier())
    }
}
