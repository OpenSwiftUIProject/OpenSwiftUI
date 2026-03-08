//
//  ShaftHostingView.swift
//  OpenSwiftUIShaftBackend
//
//  Public API for hosting OpenSwiftUI views in Shaft
//

import Foundation
public import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import Shaft
import ShaftSetup

/// A hosting view that renders OpenSwiftUI views using Shaft's rendering system
public enum ShaftHostingView {
    /// Run an OpenSwiftUI view in a Shaft application
    ///
    /// This sets up Shaft's default backend, creates the rendering pipeline,
    /// and starts the event loop.
    public static func run<Content: OpenSwiftUI.View>(rootView: Content) {
        // Set up Shaft's default backend (SDL3 + Skia)
        ShaftSetup.useDefault()

        // Create the internal host implementation
        let host = ShaftHostingViewImpl(rootView: rootView)
        host.startShaftApp()
    }
}

// MARK: - Internal Implementation

/// Internal implementation that bridges OpenSwiftUI and Shaft
final class ShaftHostingViewImpl<Content: OpenSwiftUI.View>: OpenSwiftUICore.ViewRendererHost {
    let viewGraph: OpenSwiftUICore.ViewGraph
    var currentTimestamp: Time = .zero
    var propertiesNeedingUpdate: OpenSwiftUICore.ViewRendererHostProperties = .all
    var renderingPhase: OpenSwiftUICore.ViewRenderingPhase = .none
    var externalUpdateCount: Int = 0

    private let shaftRenderer: ShaftRenderer
    private var rootView: Content

    /// ValueNotifier that holds the current Shaft widget tree
    private let widgetNotifier: Shaft.ValueNotifier<Shaft.Widget>

    init(rootView: Content) {
        self.rootView = rootView
        self.widgetNotifier = Shaft.ValueNotifier(EmptyWidget())

        // Create our custom Shaft-compatible DisplayList renderer wrapper
        self.shaftRenderer = ShaftRenderer(widgetNotifier: widgetNotifier)

        // Create ViewGraph with displayList output enabled
        self.viewGraph = OpenSwiftUICore.ViewGraph(
            rootViewType: Content.self,
            requestedOutputs: [.displayList, .layout]
        )

        // Set up the view graph
        viewGraph.delegate = self
        viewGraph.setRootView(rootView)
    }

    func startShaftApp() {
        // Create the bridge widget with our notifier
        let bridgeWidget = ShaftBridgeWidget(widgetNotifier: widgetNotifier)

        // Trigger initial render BEFORE runApp (which blocks)
        viewGraph.updateOutputs(at: Time.zero)

        render(targetTimestamp: nil)

        // Run the Shaft app with our bridge widget (this blocks)
        Shaft.runApp(bridgeWidget)
    }

    func requestUpdate(after delay: Double) {
        // Schedule an update after the specified delay
        // TODO: Integrate with Shaft's scheduler
        mark("requestUpdate(after: \(delay))")
        SchedulerBinding.shared.scheduleFrame()
    }

    func renderDisplayList(
        _ list: OpenSwiftUICore.DisplayList,
        asynchronously: Bool,
        time: OpenSwiftUICore.Time,
        nextTime: OpenSwiftUICore.Time,
        targetTimestamp: OpenSwiftUICore.Time?,
        version: OpenSwiftUICore.DisplayList.Version,
        maxVersion: OpenSwiftUICore.DisplayList.Version
    ) -> OpenSwiftUICore.Time {
        return shaftRenderer.render(
            rootView: self,
            from: list,
            time: time,
            version: version,
            maxVersion: maxVersion,
            environment: DisplayList.ViewRenderer.Environment(
                contentsScale: 1.0
            )
        )
    }

    // Required ViewRendererHost methods with stub implementations
    func updateRootView() {
        // TODO: Implement root view updates
        mark("updateRootView()")
    }

    func updateEnvironment() {
        // TODO: Implement environment updates
        mark("updateEnvironment()")
    }

    func updateSize() {
        // TODO: Implement size updates
        // mark("updateSize()")
        let windowSize = CGSize(width: 800, height: 600)  // placeholder
        viewGraph.setProposedSize(windowSize)
    }

    func updateSafeArea() {
        // TODO: Implement safe area updates
        mark("updateSafeArea()")
    }

    func updateContainerSize() {
        // TODO: Implement container size updates
        mark("updateContainerSize()")
    }
}

// MARK: - ViewGraphDelegate

extension ShaftHostingViewImpl: OpenSwiftUICore.ViewGraphDelegate {
    func updateEnvironment(_ environment: inout OpenSwiftUI.EnvironmentValues) {
        mark("🔍 [ViewGraphDelegate.updateEnvironment] Called")
        // Update environment values if needed
    }
}

// MARK: - ViewGraphRenderDelegate

extension ShaftHostingViewImpl: OpenSwiftUICore.ViewGraphRenderDelegate {
    var renderingRootView: AnyObject {
        mark("🔍 [renderingRootView] Called")
        return self
    }

    func updateRenderContext(_ context: inout ViewGraphRenderContext) {
        mark("🔍 [updateRenderContext] Called, setting contentsScale=1.0")
        // Set the contents scale from Shaft's device pixel ratio
        // TODO: Get this from Shaft's view
        context.contentsScale = 1.0
    }

    func withMainThreadRender(wasAsync: Bool, _ body: () -> Time) -> Time {
        mark("🔍 [withMainThreadRender] Called with wasAsync=\(wasAsync)")
        let result = body()
        mark("🔍 [withMainThreadRender] body() returned \(result)")
        return result
    }
}
