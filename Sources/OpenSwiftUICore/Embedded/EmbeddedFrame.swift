//
//  EmbeddedFrame.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
public struct _EmbeddedFrame<Content: View>: PrimitiveView {
    let content: Content
    let width: Int32?
    let height: Int32?
    let alignment: Alignment
    public func _handlePhyicButton(_ button: PhysicalButton) -> Bool { content._handlePhyicButton(button) }
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        let child = content._sizeThatFits(.init(width: width ?? proposal.width, height: height ?? proposal.height), using: &sink)
        return .init(width: width ?? child.width, height: height ?? child.height)
    }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        let child = content._sizeThatFits(.init(width: width ?? rect.width, height: height ?? rect.height), using: &sink)
        content._render(in: alignment.rect(size: child, in: rect), to: &sink)
    }
}
extension View {
    public func frame(width: Int32? = nil, height: Int32? = nil, alignment: Alignment = .center) -> _EmbeddedFrame<Self> {
        precondition((width ?? 0) >= 0 && (height ?? 0) >= 0 && (width ?? 0) <= 32767 && (height ?? 0) <= 32767)
        return .init(content: self, width: width, height: height, alignment: alignment)
    }
}
#endif
