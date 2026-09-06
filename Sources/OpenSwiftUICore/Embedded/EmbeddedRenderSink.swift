//
//  EmbeddedRenderSink.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// A platform renderer. Calls are synchronous, in back-to-front order.
/// Names and text are static literals, with no bundle or Foundation dependency.
/// A sink must clip to its viewport and report unsupported/missing assets.
public protocol EmbeddedRenderSink {
    mutating func measureImage(_ name: StaticString) -> EmbeddedSize
    mutating func measureText(_ text: StaticString, proposal: ProposedViewSize) -> EmbeddedSize
    mutating func fill(_ rect: EmbeddedRect, color: Color)
    mutating func image(_ name: StaticString, in rect: EmbeddedRect)
    mutating func text(_ text: StaticString, in rect: EmbeddedRect, color: Color)
}
#endif
