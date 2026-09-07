@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - EmptyViewModifier

protocol EmptyViewModifier: PrimitiveViewModifier {}

extension EmptyViewModifier {
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

// MARK: - Deferred Accessibility Attachment Modifiers

struct DetachDeferredAccessibilityAttachmentModifier: EmptyViewModifier {}

struct EnableDeferredAccessibilityAttachmentModifier: EmptyViewModifier {}

struct DetachedGeometryModifier: EmptyViewModifier {}

struct DisableDeferredAccessibilityAttachmentModifier: EmptyViewModifier {}

// MARK: - AccessibilityRepresentableStyleModifier

struct AccessibilityRepresentableStyleModifier: EmptyViewModifier {}

// MARK: - AccessibilityLabelStyle

struct AccessibilityLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.title
            .modifier(DisableDeferredAccessibilityAttachmentModifier())
            .background {
                configuration.icon
                    .modifier(DetachedGeometryModifier())
                    .modifier(AccessibilityRepresentableStyleModifier())
                    .modifier(EnableDeferredAccessibilityAttachmentModifier())
                    .hidden()
                    .transformPreference(AccessibilityAttachment.Key.self) { _ in }
            }
            .modifier(AccessibilityAttachmentModifier())
            .modifier(DetachDeferredAccessibilityAttachmentModifier())
            .modifier(EnableDeferredAccessibilityAttachmentModifier())
    }
}

// MARK: - AccessibilityLabelModifier

struct AccessibilityLabelModifier<Content: View>: AccessibilityConfigurationModifier {
    func body(content: Content) -> some View {
        content.modifier(ChildModifier())
    }

    private struct ChildModifier: PrimitiveViewModifier {}
}

extension View {
    func accessibilityLabel() -> some View {
        AccessibilityLabelModifier().body(content: self)
    }
}
