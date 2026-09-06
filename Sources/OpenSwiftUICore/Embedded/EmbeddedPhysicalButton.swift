//
//  EmbeddedPhysicalButton.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// Logical board buttons, independent of GPIO/ADC encodings.
public enum PhysicalButton: Equatable {
    case up, down, ok
}

/// A layout-transparent handler for one physical button click.
public struct _EmbeddedPhysicalButton<Content: View>: PrimitiveView {
    let content: Content
    let button: PhysicalButton
    let action: () -> Void

    public func _handlePhyicButton(_ button: PhysicalButton) -> Bool {
        if self.button == button {
            action()
            return true
        }
        return content._handlePhyicButton(button)
    }
    public var _layoutCount: Int { content._layoutCount }
    public func _measureChild<Sink: EmbeddedRenderSink>(_ index: Int, proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        content._measureChild(index, proposal: proposal, using: &sink)
    }
    public func _placeChild<Sink: EmbeddedRenderSink>(_ index: Int, in rect: EmbeddedRect, to sink: inout Sink) {
        content._placeChild(index, in: rect, to: &sink)
    }
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        content._sizeThatFits(proposal, using: &sink)
    }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        content._render(in: rect, to: &sink)
    }
}

extension View {
    /// Handles a board button click. The requested `onPhyicButton` spelling is
    /// intentional. The outermost matching modifier consumes the event; otherwise
    /// containers visit children in declaration order, stopping at the first match.
    /// Hidden conditional/optional branches do not receive events. No focus or
    /// geometric hit testing is implied. Closures run only during host input dispatch.
    public func onPhyicButton(_ button: PhysicalButton, perform action: @escaping () -> Void) -> _EmbeddedPhysicalButton<Self> {
        .init(content: self, button: button, action: action)
    }
}
#endif
