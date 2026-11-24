//
//  HeadlessRendererHost.swift
//  OpenSwiftUICore
//

#if !OPENSWIFTUI_SWIFTUI_RENDERER
package import Foundation
package import OpenCoreGraphicsShims

// MARK: - HeadlessRendererHost

#if os(WASI)
@_spi(ForOpenSwiftUIOnly)
public protocol WebHeadlessHostProtocol: AnyObject {
    var eventBindingManager: EventBindingManager { get }
    var focusedResponderProvider: ((ResponderNode?) -> ResponderNode?)? { get set }
}
#endif

/// A host shared by renderers that do not own a native platform view.
///
/// Most clients render once. The WASI Web renderer retains the host and uses
/// its event-loop scheduler to publish frames after state changes.
final package class HeadlessRendererHost<Content>: ViewRendererHost, ViewGraphRenderDelegate where Content: View {
    package let viewGraph: ViewGraph
    package let renderer: DisplayList.ViewRenderer
    package private(set) var rootView: Content
    package let environment: EnvironmentValues
    package private(set) var surface: CGSize

    #if os(WASI)
    private let schedulesUpdates: Bool
    private let eventBridge: _WebEventBridge?
    package let eventBindingManager = EventBindingManager()
    package var rootViewForSurface: ((CGSize) -> Content)?
    package var focusedResponderProvider: ((ResponderNode?) -> ResponderNode?)?
    private var scheduledUpdateTime: Time?
    private var scheduledUpdateGeneration: UInt64 = 0
    private var isPerformingScheduledRender = false
    #endif

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
        var resolvedEnvironment = environment
        #if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
        if case let .web(options) = configuration.renderer {
            resolvedEnvironment.staticTextMeasurementProvider = .init { request in
                options.measureText(_WebTextMeasurementRequest(request)).staticMetrics
            }
        }
        #endif
        self.environment = resolvedEnvironment
        self.surface = surface
        #if os(WASI)
        if case let .web(options) = configuration.renderer {
            schedulesUpdates = true
            eventBridge = options.eventBridge
        } else {
            schedulesUpdates = false
            eventBridge = nil
        }
        #endif
        Update.begin()
        var outputs: ViewGraph.Outputs = [.displayList, .layout]
        #if os(WASI)
        if schedulesUpdates {
            outputs.insert(.viewResponders)
        }
        #endif
        #if os(WASI)
        viewGraph = ViewGraph(
            rootViewType: ModifiedContent<Content, HitTestBindingModifier>.self,
            requestedOutputs: outputs
        )
        #else
        viewGraph = ViewGraph(rootViewType: Content.self, requestedOutputs: outputs)
        #endif
        renderer = DisplayList.ViewRenderer(
            platform: .init(definition: HeadlessPlatformViewDefinition.self)
        )
        renderer.configuration = configuration
        renderer.host = self
        initializeViewGraph()
        #if os(WASI)
        eventBindingManager.host = self
        eventBridge?.connect(to: eventBindingManager)
        eventBridge?.surfaceResizeHandler = { [weak self] newSize in
            self?.updateSurfaceSize(newSize)
        }
        #endif
        Update.end()
    }

    #if os(WASI)
    package func updateSurfaceSize(_ newSize: CGSize) {
        guard newSize.width.isFinite, newSize.height.isFinite,
              newSize.width > 0, newSize.height > 0,
              newSize != surface else {
            return
        }
        Update.ensure {
            surface = newSize
            if let rootViewForSurface {
                rootView = rootViewForSurface(newSize)
            }
            #if !OPENSWIFTUI_SWIFTUI_RENDERER
            if case var .web(options) = renderer.configuration.renderer {
                options.surface = newSize
                renderer.configuration = .web(options)
            }
            #endif
            propertiesNeedingUpdate.formUnion([.rootView, .size, .containerSize])
            requestUpdate(after: .zero)
        }
    }
    #endif

    package func renderOnce() {
        #if os(WASI)
        if schedulesUpdates {
            currentTimestamp = .systemUptime
        }
        isPerformingScheduledRender = true
        defer { isPerformingScheduledRender = false }
        #endif
        render(interval: .zero, targetTimestamp: nil)
    }

    package func updateRootView() {
        #if os(WASI)
        viewGraph.setRootView(Self.makeRootView(rootView))
        #else
        viewGraph.setRootView(rootView)
        #endif
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
        #if os(WASI)
        if EventGraphHost.self == T.self, schedulesUpdates {
            return unsafeBitCast(self as any EventGraphHost, to: T.self)
        }
        #endif
        if ViewGraphRenderDelegate.self == T.self {
            return unsafeBitCast(self as any ViewGraphRenderDelegate, to: T.self)
        } else if DisplayList.ViewRenderer.self == T.self {
            return unsafeBitCast(renderer, to: T.self)
        } else {
            return nil
        }
    }

    #if os(WASI)
    /// Drives state updates for interactive headless renderers. The Web host
    /// has no native run loop, so pending graph transactions must explicitly
    /// schedule another render on the JavaScript event loop.
    public func beginTransaction() {
        requestUpdate(after: .zero)
    }
    #endif

    package func requestUpdate(after delay: Double) {
        #if os(WASI)
        guard schedulesUpdates, delay.isFinite else { return }
        let delay = max(delay, .zero)
        let deadline = Time.systemUptime + delay
        if isPerformingScheduledRender, delay == .zero {
            return
        }
        if let scheduledUpdateTime, scheduledUpdateTime <= deadline {
            return
        }
        scheduledUpdateGeneration &+= 1
        let generation = scheduledUpdateGeneration
        scheduledUpdateTime = deadline
        withDelay(delay) { [weak self] in
            guard let self,
                  self.scheduledUpdateGeneration == generation else {
                return
            }
            self.scheduledUpdateTime = nil
            self.isPerformingScheduledRender = true
            defer { self.isPerformingScheduledRender = false }
            self.currentTimestamp = .systemUptime
            self.render(interval: .zero, targetTimestamp: nil)
        }
        #endif
    }

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

#if os(WASI)
extension HeadlessRendererHost: EventGraphHost, WebHeadlessHostProtocol {
    package var focusedResponder: ResponderNode? {
        focusedResponderProvider?(responderNode)
    }

    package func sendEvents(
        _ events: [EventID: any EventType],
        rootNode: ResponderNode,
        at time: Time
    ) -> GesturePhase<Void> {
        // Browser hosts have no native display clock. Keep view and gesture
        // time on the same monotonic clock, including timer-only updates.
        // Gesture responders currently inherit the captured view-input time.
        currentTimestamp = time
        viewGraph.setTime(time)
        return viewGraph.sendEvents(events, rootNode: rootNode, at: time)
    }
}
#endif

private final class HeadlessPlatformViewDefinition: PlatformViewDefinition, @unchecked Sendable {}
#endif
