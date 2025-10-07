//
//  AccessibilityLabeledContent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 28161D0154DF546094400EFEC8044F4B (SwiftUI)

import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - AccessibilityLabeledContentPresentation

enum AccessibilityLabeledContentPresentation {
    case standard
    case merged
}

// MARK: - AccessibilityCombinedLabeledContent

struct AccessibilityCombinedLabeledContent: ViewInputBoolFlag {}

// MARK: - AccessibilityLabeledContentContentModifier [WIP]

struct AccessibilityLabeledContentContentModifier<Label> where Label: View {
    private struct Attachment {
        // @OptionalAttribute var labelChild: AccessibilityAttachment.Tree?
        @Attribute var presentation: AccessibilityLabeledContentPresentation?
    }

    private struct LabelChild {
        @Attribute var label: Label

        var value: some View {
            _openSwiftUIUnimplementedFailure()
        }
    }
    var label: Label

    var presentation: AccessibilityLabeledContentPresentation?

    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - AccessibilityLabeledContentLabelModifier [WIP]

struct AccessibilityLabeledContentLabelModifier {
    private struct Attachment {
        @Attribute var presentation: AccessibilityLabeledContentPresentation

        var value: AccessibilityAttachmentModifier {
            _openSwiftUIUnimplementedFailure()
        }
    }

    var presentation: AccessibilityLabeledContentPresentation?

    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ResolvedPresentation [WIP]

struct ResolvedPresentation {
    @Attribute var explicit: AccessibilityLabeledContentPresentation?

    @Attribute var labelsVisibility: Visibility
}

// FIXME
struct AccessibilityAttachmentModifier {}

enum Visibility {
    case automatic
    case visible
    case hidden
}
