//
//  EmbeddedViewPair.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
/// Builder list storage: flatten siblings for the enclosing Layout container.
public struct _EmbeddedViewPair<First: View, Second: View>: PrimitiveView {
    let first: First
    let second: Second
    public var _layoutCount: Int { first._layoutCount + second._layoutCount }
    public func _measureChild<Sink: EmbeddedRenderSink>(_ index: Int, proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        if index < first._layoutCount { return first._measureChild(index, proposal: proposal, using: &sink) }
        return second._measureChild(index - first._layoutCount, proposal: proposal, using: &sink)
    }
    public func _placeChild<Sink: EmbeddedRenderSink>(_ index: Int, in rect: EmbeddedRect, to sink: inout Sink) {
        if index < first._layoutCount { first._placeChild(index, in: rect, to: &sink) }
        else { second._placeChild(index - first._layoutCount, in: rect, to: &sink) }
    }
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        ZStack { self }._sizeThatFits(proposal, using: &sink)
    }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        ZStack { self }._render(in: rect, to: &sink)
    }
}
#endif
