//
//  EmbeddedLayoutSubviews.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
/// Statically typed child access. No existential views or heap-owned view graph.
/// Index-based measurement/placement replaces desktop LayoutSubview proxies.
public struct LayoutSubviews<Content: View, Sink: EmbeddedRenderSink> {
    let content: Content
    public var sink: Sink
    public var count: Int { content._layoutCount }
    init(content: Content, sink: Sink) {
        precondition(content._layoutCount <= 32, "Embedded layouts support at most 32 children")
        self.content = content; self.sink = sink
    }
    public mutating func sizeThatFits(_ index: Int, proposal: ProposedViewSize) -> EmbeddedSize {
        precondition(index >= 0 && index < count)
        return content._measureChild(index, proposal: proposal, using: &sink)
    }
    public mutating func place(_ index: Int, x: Int32, y: Int32, proposal: ProposedViewSize) {
        let size = sizeThatFits(index, proposal: proposal)
        content._placeChild(index, in: .init(x: x, y: y, width: size.width, height: size.height), to: &sink)
    }
}
#endif
