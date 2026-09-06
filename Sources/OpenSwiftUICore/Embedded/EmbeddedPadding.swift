//
//  EmbeddedPadding.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
public struct _EmbeddedPadding<Content: View>: PrimitiveView {
    let content: Content
    let insets: EdgeInsets
    public func _handlePhyicButton(_ button: PhysicalButton) -> Bool { content._handlePhyicButton(button) }
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        let w = insets.leading + insets.trailing, h = insets.top + insets.bottom
        let child = content._sizeThatFits(.init(width: proposal.width.map { max(0, $0 - w) }, height: proposal.height.map { max(0, $0 - h) }), using: &sink)
        return .init(width: child.width + w, height: child.height + h)
    }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        content._render(in: .init(x: rect.x + insets.leading, y: rect.y + insets.top,
            width: max(0, rect.width - insets.leading - insets.trailing),
            height: max(0, rect.height - insets.top - insets.bottom)), to: &sink)
    }
}
extension View {
    public func padding(_ length: Int32 = 8) -> _EmbeddedPadding<Self> {
        padding(.init(top: length, leading: length, bottom: length, trailing: length))
    }
    public func padding(_ insets: EdgeInsets) -> _EmbeddedPadding<Self> { .init(content: self, insets: insets) }
}
#endif
