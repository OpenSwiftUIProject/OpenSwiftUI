//
//  EmbeddedRenderSink.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// A platform renderer. Calls are synchronous, in back-to-front order.
/// Names and text are static literals, with no bundle or Foundation dependency.
/// A sink must clip to its viewport and report unsupported/missing assets.
public protocol EmbeddedRenderSink {
    mutating func beginIdentity(_ id: UInt32)
    mutating func endIdentity()
    mutating func beginTransition(_ transition: AnyTransition, in rect: EmbeddedRect)
    mutating func endTransition()
    mutating func measureImage(_ name: StaticString) -> EmbeddedSize
    mutating func measureText(_ text: StaticString, proposal: ProposedViewSize) -> EmbeddedSize
    mutating func fill(_ rect: EmbeddedRect, color: Color)
    mutating func image(_ name: StaticString, in rect: EmbeddedRect)
    mutating func text(_ text: StaticString, in rect: EmbeddedRect, color: Color)
}
extension EmbeddedRenderSink {
    public mutating func beginIdentity(_ id: UInt32) {}
    public mutating func endIdentity() {}
    public mutating func beginTransition(_ transition: AnyTransition, in rect: EmbeddedRect) {}
    public mutating func endTransition() {}
}
#endif
