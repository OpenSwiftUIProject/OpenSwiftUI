//
//  EmbeddedViewHost.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// Retains a root value and its state between synchronous input and render passes.
///
/// Construct content inside the builder so its state can invalidate this host.
/// Call `render` when `needsRender` is true. The platform owns scheduling and
/// scene replacement; this host owns no platform objects or action registry.
public final class EmbeddedViewHost<Content: View> {
    private let content: Content
    private let context: EmbeddedStateContext
    private var renderedRevision: UInt64?
    private var isDispatching = false
    private var animator = EmbeddedAnimationState()
    private var geometry: RootGeometry?

    public init(@ViewBuilder content: () -> Content) {
        let context = EmbeddedStateContext()
        self.context = context
        let previous = EmbeddedStateContext.constructing
        EmbeddedStateContext.constructing = context
        defer { EmbeddedStateContext.constructing = previous }
        self.content = content()
    }

    public var needsRender: Bool { renderedRevision != context.revision || animator.dirty }

    public var isAnimating: Bool { animator.isAnimating }

    /// Advance with actual elapsed time, under the same serialization as input.
    public func advanceAnimation(byMilliseconds milliseconds: UInt32) {
        precondition(!context.isRendering && !isDispatching)
        animator.advance(by: milliseconds)
    }

    /// Apply a synchronous update to retained content (for platform events).
    public func update<Result>(_ body: (Content) -> Result) -> Result {
        precondition(!context.isRendering && !isDispatching, "Update must not reenter a host")
        isDispatching = true
        defer { isDispatching = false }
        return body(content)
    }

    /// Requests another pass, for example after a platform sink failure.
    public func invalidate() { context.revision &+= 1; context.animation = nil }

    /// Delivers one click to the first matching modifier in the current tree.
    @discardableResult
    public func send(_ button: PhysicalButton) -> Bool {
        precondition(!context.isRendering && !isDispatching, "Input must not reenter a host")
        isDispatching = true
        defer { isDispatching = false }
        return content._handlePhyicButton(button)
    }

    public func render<Sink: EmbeddedRenderSink>(rootGeometry: RootGeometry, to sink: inout Sink) {
        precondition(!context.isRendering && !isDispatching, "Rendering must not reenter a host")
        context.isRendering = true
        defer { context.isRendering = false }
        if renderedRevision != context.revision || geometry != rootGeometry {
            var recorder = EmbeddedRecordingSink(base: sink)
            EmbeddedRenderer.render(content, rootGeometry: rootGeometry, to: &recorder)
            sink = recorder.base
            animator.setTarget(recorder.commands, animation: geometry == rootGeometry ? context.animation : nil)
            context.animation = nil
            renderedRevision = context.revision
            geometry = rootGeometry
        }
        animator.draw(to: &sink)
    }
}
#endif
