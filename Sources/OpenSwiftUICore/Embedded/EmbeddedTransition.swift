//
//  EmbeddedTransition.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// Insertion effects for identified Embedded views. Removal is immediate.
/// Scale changes primitive geometry; the platform's fixed text font is retained.
public struct AnyTransition: Equatable, Sendable {
    package var scale: Bool
    package var fades: Bool
    public static var identity: Self { .init(scale: false, fades: false) }
    public static var opacity: Self { .init(scale: false, fades: true) }
    public static var scale: Self { .init(scale: true, fades: false) }
    public func combined(with other: Self) -> Self {
        .init(scale: scale || other.scale, fades: fades || other.fades)
    }
}

public struct _EmbeddedTransition<Content: View>: PrimitiveView {
    let content: Content
    let transition: AnyTransition
    public func _handlePhyicButton(_ button: PhysicalButton) -> Bool { content._handlePhyicButton(button) }
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        content._sizeThatFits(proposal, using: &sink)
    }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        sink.beginTransition(transition, in: rect)
        content._render(in: rect, to: &sink)
        sink.endTransition()
    }
}
extension View {
    public func transition(_ transition: AnyTransition) -> _EmbeddedTransition<Self> {
        .init(content: self, transition: transition)
    }
}
#endif
