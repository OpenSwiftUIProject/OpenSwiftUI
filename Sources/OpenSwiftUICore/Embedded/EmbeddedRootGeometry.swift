//
//  EmbeddedRootGeometry.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// Configures the physical screen and the area offered to the root view.
/// Mirrors the inset -> measure -> center flow of ViewGraph.RootGeometry,
/// without its AttributeGraph rule or layout-direction dependencies.
public struct RootGeometry: Equatable, Sendable {
    public let screenSize: EmbeddedSize
    public let safeAreaInsets: EdgeInsets
    public let centersRootView: Bool
    public init(screenSize: EmbeddedSize, safeAreaInsets: EdgeInsets = .init(), centersRootView: Bool = true) {
        precondition(screenSize.width <= 32767 && screenSize.height <= 32767)
        precondition(safeAreaInsets.leading + safeAreaInsets.trailing <= screenSize.width)
        precondition(safeAreaInsets.top + safeAreaInsets.bottom <= screenSize.height)
        self.screenSize = screenSize
        self.safeAreaInsets = safeAreaInsets
        self.centersRootView = centersRootView
    }
    public var contentBounds: EmbeddedRect {
        .init(x: safeAreaInsets.leading, y: safeAreaInsets.top,
              width: screenSize.width - safeAreaInsets.leading - safeAreaInsets.trailing,
              height: screenSize.height - safeAreaInsets.top - safeAreaInsets.bottom)
    }
    public func resolve<Content: View, Sink: EmbeddedRenderSink>(_ content: Content, using sink: inout Sink) -> EmbeddedRect {
        let bounds = contentBounds
        let size = content._sizeThatFits(.init(width: bounds.width, height: bounds.height), using: &sink)
        return (centersRootView ? Alignment.center : .topLeading).rect(size: size, in: bounds)
    }
}
#endif
