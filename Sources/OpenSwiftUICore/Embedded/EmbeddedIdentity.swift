//
//  EmbeddedIdentity.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// Explicit render identity. IDs must be nonzero and unique across a host.
/// This preserves drawing identity across layout changes, not child State.
public struct _EmbeddedIdentity<Content: View>: PrimitiveView {
    let content: Content
    let id: UInt32
    public func _handlePhyicButton(_ button: PhysicalButton) -> Bool { content._handlePhyicButton(button) }
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        content._sizeThatFits(proposal, using: &sink)
    }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        sink.beginIdentity(id)
        content._render(in: rect, to: &sink)
        sink.endIdentity()
    }
}
extension View {
    public func id(_ id: UInt32) -> _EmbeddedIdentity<Self> {
        precondition(id != 0, "Embedded identity zero is reserved")
        return .init(content: self, id: id)
    }
}
#endif
