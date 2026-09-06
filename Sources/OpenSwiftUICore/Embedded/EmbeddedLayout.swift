//
//  EmbeddedLayout.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// Embedded measure/place contract with a typed cache and generic child access.
/// Integer geometry and index-based subviews are specific to this profile.
public protocol Layout {
    associatedtype Cache = Void
    func makeCache<Content: View, Sink: EmbeddedRenderSink>(subviews: inout LayoutSubviews<Content, Sink>) -> Cache
    func sizeThatFits<Content: View, Sink: EmbeddedRenderSink>(proposal: ProposedViewSize, subviews: inout LayoutSubviews<Content, Sink>, cache: inout Cache) -> EmbeddedSize
    func placeSubviews<Content: View, Sink: EmbeddedRenderSink>(in bounds: EmbeddedRect, proposal: ProposedViewSize, subviews: inout LayoutSubviews<Content, Sink>, cache: inout Cache)
}
extension Layout where Cache == Void {
    public func makeCache<Content: View, Sink: EmbeddedRenderSink>(subviews: inout LayoutSubviews<Content, Sink>) {}
}
extension Layout {
    public func callAsFunction<Content: View>(@ViewBuilder content: () -> Content) -> _EmbeddedLayoutView<Self, Content> {
        .init(layout: self, content: content())
    }
}
#endif
