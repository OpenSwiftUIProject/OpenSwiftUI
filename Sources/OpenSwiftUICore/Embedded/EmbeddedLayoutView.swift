//
//  EmbeddedLayoutView.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
public struct _EmbeddedLayoutView<L: Layout, Content: View>: PrimitiveView {
    let layout: L
    let content: Content
    public func _handlePhyicButton(_ button: PhysicalButton) -> Bool { content._handlePhyicButton(button) }
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        var subviews = LayoutSubviews(content: content, sink: sink)
        var cache = layout.makeCache(subviews: &subviews)
        let size = layout.sizeThatFits(proposal: proposal, subviews: &subviews, cache: &cache)
        sink = subviews.sink
        return size
    }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        var subviews = LayoutSubviews(content: content, sink: sink)
        var cache = layout.makeCache(subviews: &subviews)
        let proposal = ProposedViewSize(width: rect.width, height: rect.height)
        _ = layout.sizeThatFits(proposal: proposal, subviews: &subviews, cache: &cache)
        layout.placeSubviews(in: rect, proposal: proposal, subviews: &subviews, cache: &cache)
        sink = subviews.sink
    }
}
#endif
