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

    public init(@ViewBuilder content: () -> Content) {
        let context = EmbeddedStateContext()
        self.context = context
        let previous = EmbeddedStateContext.constructing
        EmbeddedStateContext.constructing = context
        defer { EmbeddedStateContext.constructing = previous }
        self.content = content()
    }

    public var needsRender: Bool { renderedRevision != context.revision }

    /// Requests another pass, for example after a platform sink failure.
    public func invalidate() { context.revision &+= 1 }

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
        let revision = context.revision
        EmbeddedRenderer.render(content, rootGeometry: rootGeometry, to: &sink)
        renderedRevision = revision
    }
}
#endif
