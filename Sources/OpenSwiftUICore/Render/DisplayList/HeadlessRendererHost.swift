//
//  HeadlessRendererHost.swift
//  OpenSwiftUICore
//

#if !OPENSWIFTUI_SWIFTUI_RENDERER
package import Foundation
package import OpenCoreGraphicsShims

// MARK: - HeadlessRendererHost

/// A one-shot host shared by renderers that do not own a native platform view.
final package class HeadlessRendererHost<Content>: ViewRendererHost, ViewGraphRenderDelegate where Content: View {
    package let viewGraph: ViewGraph
    package let renderer: DisplayList.ViewRenderer
    package let rootView: Content
    package let environment: EnvironmentValues
    package let surface: CGSize

    package var currentTimestamp: Time = .zero
    package var propertiesNeedingUpdate: ViewRendererHostProperties = .all
    package var renderingPhase: ViewRenderingPhase = .none
    package var externalUpdateCount: Int = .zero

    package init(
        rootView: Content,
        environment: EnvironmentValues,
        surface: CGSize,
        configuration: _RendererConfiguration
    ) {
        self.rootView = rootView
        self.environment = environment
        self.surface = surface
        Update.begin()
        viewGraph = ViewGraph(rootViewType: Content.self, requestedOutputs: [.displayList, .layout])
        renderer = DisplayList.ViewRenderer(
            platform: .init(definition: HeadlessPlatformViewDefinition.self)
        )
        renderer.configuration = configuration
        renderer.host = self
        initializeViewGraph()
        Update.end()
    }

    package func renderOnce() {
        render(interval: .zero, targetTimestamp: nil)
    }

    package func updateRootView() {
        viewGraph.setRootView(rootView)
    }

    package func updateEnvironment() {
        viewGraph.setEnvironment(environment)
    }

    package func updateTransform() {
        viewGraph.invalidateTransform()
    }

    package func updateSize() {
        viewGraph.setProposedSize(surface)
    }

    package func updateSafeArea() {
        viewGraph.setSafeAreaInsets(.zero)
    }

    package func updateContainerSize() {
        viewGraph.setContainerSize(.fixed(surface))
    }

    package func updateFocusStore() {}

    package func updateFocusedItem() {}

    package func updateFocusedValues() {}

    package func updateAccessibilityEnvironment() {}

    package func `as`<T>(_ type: T.Type) -> T? {
        if ViewGraphRenderDelegate.self == T.self {
            return unsafeBitCast(self as any ViewGraphRenderDelegate, to: T.self)
        } else if DisplayList.ViewRenderer.self == T.self {
            return unsafeBitCast(renderer, to: T.self)
        } else {
            return nil
        }
    }

    package func requestUpdate(after delay: Double) {}

    package var renderingRootView: AnyObject {
        self
    }

    package func updateRenderContext(_ context: inout ViewGraphRenderContext) {
        context.contentsScale = 1.0
        context.opaqueBackground = false
    }

    package func withMainThreadRender(wasAsync: Bool, _ body: () -> Time) -> Time {
        body()
    }
}

private final class HeadlessPlatformViewDefinition: PlatformViewDefinition, @unchecked Sendable {}
#endif
