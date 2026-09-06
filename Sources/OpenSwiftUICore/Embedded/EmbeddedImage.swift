//
//  EmbeddedImage.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
/// A named static asset. Defaults to intrinsic size; resizable adopts proposals.
public struct Image: PrimitiveView {
    public let name: StaticString
    private var isResizable = false
    public init(_ name: StaticString) { self.name = name }
    public func resizable() -> Self { var copy = self; copy.isResizable = true; return copy }
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        let natural = sink.measureImage(name)
        return isResizable ? proposal.replacingUnspecifiedDimensions(by: natural) : natural
    }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        if rect.width > 0 && rect.height > 0 { sink.image(name, in: rect) }
    }
}
#endif
