//
//  EmbeddedOffset.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
public struct _EmbeddedOffset<Content: View>: PrimitiveView {
    let content: Content
    let x: Int32
    let y: Int32

    public func _handlePhyicButton(_ button: PhysicalButton) -> Bool { content._handlePhyicButton(button) }
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        content._sizeThatFits(proposal, using: &sink)
    }

    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        content._render(in: EmbeddedRect(x: rect.x + x, y: rect.y + y,
                                         width: rect.width, height: rect.height), to: &sink)
    }
}

extension View {
    public func offset(x: Int32 = 0, y: Int32 = 0) -> _EmbeddedOffset<Self> {
        _EmbeddedOffset(content: self, x: x, y: y)
    }
}
#endif
