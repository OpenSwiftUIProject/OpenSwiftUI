//
//  EmbeddedBackground.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
public struct _EmbeddedBackground<Content: View, Background: View>: PrimitiveView {
    let content: Content
    let background: Background
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        content._sizeThatFits(proposal, using: &sink)
    }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        let size = background._sizeThatFits(.init(width: rect.width, height: rect.height), using: &sink)
        background._render(in: Alignment.center.rect(size: size, in: rect), to: &sink)
        content._render(in: rect, to: &sink)
    }
}
extension View {
    public func background<Background: View>(_ background: Background) -> _EmbeddedBackground<Self, Background> {
        .init(content: self, background: background)
    }
}
#endif
