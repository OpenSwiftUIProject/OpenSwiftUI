//
//  EmbeddedText.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
/// Static UTF-8 text rendered with the platform's built-in font.
public struct Text: PrimitiveView {
    public let content: StaticString
    private var color: Color = .white

    public init(_ content: StaticString) { self.content = content }

    public func foregroundStyle(_ color: Color) -> Text {
        var result = self
        result.color = color
        return result
    }

    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        sink.measureText(content, proposal: proposal)
    }

    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        if color.alpha > 0 && rect.width > 0 && rect.height > 0 {
            sink.text(content, in: rect, color: color)
        }
    }
}
#endif
