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
