//
//  AccessibilityLabeledContent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 28161D0154DF546094400EFEC8044F4B (SwiftUI)

import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - AccessibilityLabeledContentModifier

protocol AccessibilityLabeledContentModifier: MultiViewModifier, PrimitiveViewModifier {
    var presentation: AccessibilityLabeledContentPresentation? {
        get
        set
    }

    func _makePresentation(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> Attribute<AccessibilityLabeledContentPresentation>
}

// MARK: - AccessibilityLabeledContentPresentation

enum AccessibilityLabeledContentPresentation {
    case standard
    case merged
}

// MARK: - AccessibilityCombinedLabeledContent

struct AccessibilityCombinedLabeledContent: ViewInputBoolFlag {}


// MARK: - AccessibilityLabeledContentContentModifier [WIP]

struct AccessibilityLabeledContentContentModifier<Label>: AccessibilityLabeledContentModifier where Label: View {
    private struct Attachment: StatefulRule {
        // @OptionalAttribute var labelChild: AccessibilityAttachment.Tree?
        @Attribute var presentation: AccessibilityLabeledContentPresentation?

        typealias Value = AccessibilityAttachmentModifier

        func updateValue() {
            _openSwiftUIUnimplementedFailure()
        }
    }

    private struct LabelChild: Rule {
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
        _openSwiftUIUnimplementedWarning()
        return body(_Graph(), inputs)
    }

    func _makePresentation(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> Attribute<AccessibilityLabeledContentPresentation> {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - AccessibilityLabeledContentLabelModifier [WIP]

struct AccessibilityLabeledContentLabelModifier: AccessibilityLabeledContentModifier {
    private struct Attachment: Rule {
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
        _openSwiftUIUnimplementedWarning()
        return body(_Graph(), inputs)
    }

    func _makePresentation(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> Attribute<AccessibilityLabeledContentPresentation> {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ResolvedPresentation [WIP]

struct ResolvedPresentation: Rule {
    @Attribute var explicit: AccessibilityLabeledContentPresentation?

    @Attribute var labelsVisibility: Visibility

    var value: AccessibilityLabeledContentPresentation {
        _openSwiftUIUnimplementedFailure()
    }
}

// FIXME
struct AccessibilityAttachmentModifier {}

// FIXME
enum Visibility {
    case automatic
    case visible
    case hidden
}

// FIXME
enum AccessibilityAttachment {
    enum Tree {}
}

// FIXME
struct AccessibilityFrameModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}
