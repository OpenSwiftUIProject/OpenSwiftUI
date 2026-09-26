//
//  AccessibilityGeometry.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: EE68159C4F54001FA5A3813EBA5DD945 (SwiftUI)

import OpenAttributeGraphShims
@_spi(Private)
import OpenSwiftUICore

// MARK: - ViewModifier + Accessibility Geometry [TBA]

extension ViewModifier {
    nonisolated static func makeAccessibilityGeometryTransform(
        for nodeList: Attribute<AccessibilityNodeList>?,
        kind: Attribute<ContentShapeKinds>?,
        inputs: _ViewInputs,
        outputs: _ViewOutputs
    ) -> Attribute<AccessibilityNodeList> {
        _openSwiftUIUnimplementedFailure()
    }
}

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
