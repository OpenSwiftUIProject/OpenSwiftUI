//
//  EmbeddedHStack.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
public struct HStack<Content: View>: View {
    let content: Content
    let layout: HStackLayout
    public init(alignment: VerticalAlignment = .center, spacing: Int32? = nil, @ViewBuilder content: () -> Content) {
        self.content = content(); layout = .init(alignment: alignment, spacing: spacing)
    }
    public var body: some View { layout { content } }
}
public struct HStackLayout: Layout {
    public typealias Cache = _EmbeddedStackCache
    public var alignment: VerticalAlignment
    public var spacing: Int32?
    public init(alignment: VerticalAlignment = .center, spacing: Int32? = nil) {
        precondition((spacing ?? 8) >= 0 && (spacing ?? 8) <= 32767)
        self.alignment = alignment; self.spacing = spacing
    }
    private var engine: EmbeddedStackLayout { .init(vertical: false, spacing: spacing ?? 8, alignment: Alignment(horizontal: .leading, vertical: alignment)) }
    public func makeCache<Content: View, Sink: EmbeddedRenderSink>(subviews: inout LayoutSubviews<Content, Sink>) -> Cache { .init() }
    public func sizeThatFits<Content: View, Sink: EmbeddedRenderSink>(proposal: ProposedViewSize, subviews: inout LayoutSubviews<Content, Sink>, cache: inout Cache) -> EmbeddedSize {
        engine.measure(proposal, subviews: &subviews, cache: &cache)
    }
    public func placeSubviews<Content: View, Sink: EmbeddedRenderSink>(in bounds: EmbeddedRect, proposal: ProposedViewSize, subviews: inout LayoutSubviews<Content, Sink>, cache: inout Cache) {
        engine.place(bounds, subviews: &subviews, cache: cache)
    }
}
#endif
