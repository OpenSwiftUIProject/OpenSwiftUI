//
//  AccessibilityDeferredAttachment.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by AccessibilityChildBehavior and AccessibilityRepresentation
//  ID: 0820208E6CE9DACCA3E182CEE5DB708A (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore

// MARK: - View + AccessibilityAttachment

extension View {
    func accessibilityAttachment<Content>(
        content: Content,
        _ transform: @escaping (inout AccessibilityAttachment.Tree) -> Void
    ) -> some View where Content: View {
        accessibilityDisableDeferredAttachments()
            .background {
                content
                    .modifier(DetachedGeometryModifier())
                    .accessibilityRepresentationStyle()
                    .accessibilityEnableDeferredAttachments()
                    .hidden()
                    .accessibilityDeferredAttachmentTransform(transform)
            }
            .accessibility()
            .modifier(DetachDeferredAccessibilityAttachmentModifier())
            .accessibilityEnableDeferredAttachments()
    }

    func accessibilityEnableDeferredAttachments() -> some View {
        modifier(EnableDeferredAccessibilityAttachmentModifier())
    }

    func accessibilityDisableDeferredAttachments() -> some View {
        modifier(DisableDeferredAccessibilityAttachmentModifier())
    }

    func accessibilityDeferredAttachmentTransform(
        _ transform: @escaping (inout AccessibilityAttachment.Tree) -> Void
    ) -> some View {
        transformPreference(AccessibilityAttachment.Key.self, transform)
    }
}

// MARK: - DetachDeferredAccessibilityAttachmentModifier

private struct DetachDeferredAccessibilityAttachmentModifier: MultiViewModifier, PrimitiveViewModifier {
    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresAccessibilityNodes {
            outputs[AccessibilityAttachment.Key.self] = nil
        }
        return outputs
    }
}

// MARK: - EnableDeferredAccessibilityAttachmentModifier

private struct EnableDeferredAccessibilityAttachmentModifier: ViewInputsModifier {
    nonisolated static func _makeViewInputs(modifier: _GraphValue<Self>, inputs: inout _ViewInputs) {
        inputs.preferences.add(AccessibilityAttachment.Key.self)
    }
}

// MARK: - DetachedGeometryModifier

private struct DetachedGeometryModifier: ViewInputsModifier {
    nonisolated static func _makeViewInputs(modifier: _GraphValue<Self>, inputs: inout _ViewInputs) {
        inputs = inputs.withoutGeometryDependencies
        inputs.needsAccessibilityGeometry = false
        inputs.needsAccessibilityViewResponders = false
    }
}

// MARK: - DisableDeferredAccessibilityAttachmentModifier

private struct DisableDeferredAccessibilityAttachmentModifier: ViewInputsModifier {
    nonisolated static func _makeViewInputs(modifier: _GraphValue<Self>, inputs: inout _ViewInputs) {
        if inputs.preferences.requiresAccessibilityNodes {
            inputs.preferences.remove(AccessibilityAttachment.Key.self)
        }
    }
}

// MARK: - AccessibilityAttachment.Key

extension AccessibilityAttachment {
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

// MARK: - AccessibilityAttachment.DeferredTransform

extension AccessibilityAttachment {
    struct DeferredTransform: Rule {
        @Attribute var attachment: AccessibilityAttachment

        var value: (inout Tree) -> Void {
            { tree in
                tree.combine(with: attachment)
            }
        }
    }
}

// MARK: - AccessibilityAttachment.Tree

extension AccessibilityAttachment {
    enum Tree: Equatable {
        case leaf(AccessibilityAttachment)
        case branch([Tree])
        case empty

        var mergedProperties: AccessibilityProperties? {
            switch self {
            case let .leaf(attachment):
                attachment.mergedProperties
            case let .branch(children):
                AccessibilityChildBehavior.defaultCombine(
                    childProperties: children.compactMap { $0.attachment?.mergedProperties },
                    createsCustomActions: true
                )
            case .empty:
                nil
            }
        }

        var attachment: AccessibilityAttachment? {
            switch self {
            case let .leaf(attachment):
                attachment
            case let .branch(children):
                AccessibilityAttachment.combine(children.compactMap(\.attachment))
            case .empty:
                nil
            }
        }

        mutating func combine(with attachment: AccessibilityAttachment) {
            switch self {
            case let .leaf(child):
                self = .empty
                self = .leaf(attachment.combined(with: child))
            case var .branch(children):
                self = .empty
                for index in children.indices {
                    children[index].combine(with: attachment)
                }
                self = .branch(children)
            case .empty:
                self = .leaf(attachment)
            }
        }

        var properties: AccessibilityProperties? {
            switch self {
            case let .leaf(attachment):
                attachment.properties
            case let .branch(children):
                AccessibilityChildBehavior.defaultCombine(
                    childProperties: children.compactMap { $0.attachment?.properties },
                    createsCustomActions: true
                )
            case .empty:
                nil
            }
        }
    }
}

// MARK: - AccessibilityAttachment + Properties

extension AccessibilityAttachment {
    var mergedProperties: AccessibilityProperties {
        var properties = properties
        let bridgedProperties = Graph.withoutUpdate {
            properties.bridgedElement.map { element -> AccessibilityProperties in
                #if os(macOS) || os(iOS) || os(visionOS)
                element.bridgedProperties
                #else
                _openSwiftUIPlatformUnimplementedFailure()
                #endif
            }
        }
        bridgedProperties.map {
            properties.merge(with: $0)
            properties.bridgedElement = nil
        }
        return properties
    }
}
