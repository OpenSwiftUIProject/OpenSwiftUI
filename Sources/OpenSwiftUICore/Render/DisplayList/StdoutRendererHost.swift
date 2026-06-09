//
//  StdoutRendererHost.swift
//  OpenSwiftUICore

#if !OPENSWIFTUI_SWIFTUI_RENDERER
import Foundation

// MARK: - StdoutRendererHost

final package class StdoutRendererHost<Content>: ViewRendererHost, ViewGraphRenderDelegate where Content: View {
    typealias RootView = ModifiedContent<Content, HitTestBindingModifier>

    package let viewGraph: ViewGraph
    package let renderer: DisplayList.ViewRenderer
    package let rootView: Content
    package let environment: EnvironmentValues
    package let options: _RendererConfiguration.StdoutOptions

    package var currentTimestamp: Time = .zero
    package var propertiesNeedingUpdate: ViewRendererHostProperties = .all
    package var renderingPhase: ViewRenderingPhase = .none
    package var externalUpdateCount: Int = .zero

    package init(
        rootView: Content,
        environment: EnvironmentValues,
        options: _RendererConfiguration.StdoutOptions
    ) {
        self.rootView = rootView
        self.environment = environment
        self.options = options
        Update.begin()
        // The stdout renderer only needs layout and display list output.
        viewGraph = ViewGraph(rootViewType: RootView.self, requestedOutputs: [.displayList, .layout])
        renderer = DisplayList.ViewRenderer(
            platform: .init(definition: StdoutPlatformViewDefinition.self)
        )
        renderer.configuration = .stdout(options)
        renderer.host = self
        initializeViewGraph()
        Update.end()
    }

    package func renderOnce() {
        render(interval: .zero, targetTimestamp: nil)
    }

    package func updateRootView() {
        viewGraph.setRootView(Self.makeRootView(rootView))
    }

    package func updateEnvironment() {
        viewGraph.setEnvironment(environment)
    }

    package func updateTransform() {
        viewGraph.invalidateTransform()
    }

    package func updateSize() {
        viewGraph.setProposedSize(options.surface)
    }

    package func updateSafeArea() {
        viewGraph.setSafeAreaInsets(.zero)
    }

    package func updateContainerSize() {
        viewGraph.setContainerSize(.fixed(options.surface))
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

private final class StdoutPlatformViewDefinition: PlatformViewDefinition, @unchecked Sendable {}
#endif
