//
//  AccessibilityLabeledContent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 28161D0154DF546094400EFEC8044F4B (SwiftUI)

import OpenAttributeGraphShims
@_spi(Private)
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

extension View {
    func accessibilityLabeledContent() -> some View {
        input(AccessibilityCombinedLabeledContent.self)
    }
}

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
class AnyAccessibilityViewModifier {}

// FIXME
struct AccessibilityChildBehavior {
    var modifier: AnyAccessibilityViewModifier
}

// FIXME
struct AccessibilityAttachmentModifier: PrimitiveViewModifier {
    var storage: MutableBox<AccessibilityAttachment>

    let behavior: AccessibilityChildBehavior?

    nonisolated static func _makeView(
        modifier _: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        body(_Graph(), inputs)
    }

    nonisolated static func _makeViewList(
        modifier _: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        body(_Graph(), inputs)
    }
}

// FIXME
struct AccessibilityAttachment {}

extension AccessibilityAttachment {
    enum Tree {
        case leaf(AccessibilityAttachment)
        case branch([Tree])
        case empty
    }

    struct Key: HostPreferenceKey {
        static let defaultValue: Tree = .empty

        static func reduce(value: inout Tree, nextValue: () -> Tree) {
            let nextValue = nextValue()
            switch (value, nextValue) {
            case (_, .empty):
                break
            case (.empty, _):
                value = nextValue
            case let (.branch(lhs), .branch(rhs)):
                value = .branch(lhs + rhs)
            case let (.branch(lhs), _):
                value = .branch(lhs + [nextValue])
            case let (_, .branch(rhs)):
                value = .branch([value] + rhs)
            default:
                value = .branch([value, nextValue])
            }
        }
    }
}

// FIXME
struct AccessibilityFrameModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}
