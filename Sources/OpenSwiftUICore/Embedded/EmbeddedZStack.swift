//
//  EmbeddedZStack.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
/// Measures all children with the same proposal, then aligns their fitted sizes.
public struct ZStack<Content: View>: PrimitiveView {
    public let content: Content
    let alignment: Alignment
    public init(alignment: Alignment = .center, @ViewBuilder content: () -> Content) {
        self.alignment = alignment; self.content = content()
    }
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        var subviews = LayoutSubviews(content: content, sink: sink)
        var result = EmbeddedSize.zero
        for index in 0..<subviews.count {
            let size = subviews.sizeThatFits(index, proposal: proposal)
            result.width = max(result.width, size.width); result.height = max(result.height, size.height)
        }
        sink = subviews.sink
        return result
    }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        var subviews = LayoutSubviews(content: content, sink: sink)
        let proposal = ProposedViewSize(width: rect.width, height: rect.height)
        for index in 0..<subviews.count {
            let size = subviews.sizeThatFits(index, proposal: proposal)
            let placed = alignment.rect(size: size, in: rect)
            subviews.place(index, x: placed.x, y: placed.y, proposal: proposal)
        }
        sink = subviews.sink
    }
}
#endif
