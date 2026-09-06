//
//  EmbeddedRenderer.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
/// Resolves root geometry, then renders the measured and placed tree.
public enum EmbeddedRenderer {
    public static func render<Content: View, Sink: EmbeddedRenderSink>(
        _ content: Content, rootGeometry: RootGeometry, to sink: inout Sink
    ) {
        let rect = rootGeometry.resolve(content, using: &sink)
        content._render(in: rect, to: &sink)
    }
    public static func render<Content: View, Sink: EmbeddedRenderSink>(
        _ content: Content, in rect: EmbeddedRect, to sink: inout Sink
    ) {
        let size = content._sizeThatFits(.init(width: rect.width, height: rect.height), using: &sink)
        content._render(in: Alignment.center.rect(size: size, in: rect), to: &sink)
    }
}
@_cdecl("openswiftui_embedded_version")
public func openSwiftUIEmbeddedVersion() -> UInt32 { 3 }
#endif
