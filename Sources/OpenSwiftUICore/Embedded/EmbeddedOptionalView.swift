//
//  EmbeddedOptionalView.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
extension Optional: View where Wrapped: View {
    public var body: Never { preconditionFailure("Optional views are primitive") }
    public var _layoutCount: Int { self?._layoutCount ?? 0 }
    public func _measureChild<Sink: EmbeddedRenderSink>(_ index: Int, proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        if let content = self { return content._measureChild(index, proposal: proposal, using: &sink) }
        preconditionFailure("Absent child")
    }
    public func _placeChild<Sink: EmbeddedRenderSink>(_ index: Int, in rect: EmbeddedRect, to sink: inout Sink) {
        if let content = self { content._placeChild(index, in: rect, to: &sink) }
    }
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        if let content = self { return content._sizeThatFits(proposal, using: &sink) }
        return .zero
    }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        if let content = self { content._render(in: rect, to: &sink) }
    }
}
#endif
