#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
import Android
import Foundation
import UIKit
@_spi(ForOpenSwiftUIOnly) @_spi(DisplayList_ViewSystem) import OpenSwiftUICore

@MainActor
final class AndroidHostingView<Content: View>: AndroidUIKitView {
    private let content: Content
    private lazy var host = AndroidViewGraphHost(rootView: content, target: self)
    private let displayLink = DisplayLink()
    private let touchRecognizer = AndroidTouchGestureRecognizer()

    init(rootView: Content) {
        content = rootView
        super.init(frame: .init(x: 0, y: 0, width: 640, height: 480))
        backgroundColor = .black
        touchRecognizer.attach(to: host.eventBridge)
        addGestureRecognizer(touchRecognizer)
    }

    deinit { displayLink.invalidate() }

    func startRendering() {
        displayLink.callback = { [weak self] in
            MainActor.assumeIsolated { self?.host.renderIfNeeded() }
        }
        host.requestUpdate(after: 0)
        displayLink.isPaused = false
    }

    func stopRendering() {
        touchRecognizer.cancelTouches()
        displayLink.isPaused = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        host.setSize(bounds.foundationRect.size)
    }
}

private final class AndroidViewGraphHost<Content: View>: ViewRendererHost, ViewGraphRenderDelegate, EventGraphHost {
    typealias RootView = ModifiedContent<Content, HitTestBindingModifier>
    let viewGraph: ViewGraph
    let renderer: DisplayList.ViewRenderer
    let rootView: Content
    let eventBindingManager = EventBindingManager()
    lazy var eventBridge = EventBindingBridge(eventBindingManager: eventBindingManager)
    var focusedResponder: ResponderNode? { nil }
    private weak var target: AnyObject?
    private var size = Foundation.CGSize(width: 640, height: 480)
    private var nextDeadline: Double = 0
    private var lastTimestamp = ProcessInfo.processInfo.systemUptime

    var currentTimestamp: Time = .zero
    var propertiesNeedingUpdate: ViewRendererHostProperties = .all
    var renderingPhase: ViewRenderingPhase = .none
    var externalUpdateCount = 0

    init(rootView: Content, target: AnyObject) {
        self.rootView = rootView
        self.target = target
        Update.begin()
        viewGraph = ViewGraph(rootViewType: RootView.self, requestedOutputs: [.displayList, .layout, .viewResponders])
        renderer = DisplayList.ViewRenderer(platform: .init(definition: AndroidUIViewPlatformViewDefinition.self))
        renderer.host = self
        initializeViewGraph()
        eventBindingManager.host = self
        eventBindingManager.delegate = eventBridge
        Update.end()
    }

    func setSize(_ newSize: Foundation.CGSize) {
        Update.locked {
            guard size != newSize else { return }
            size = newSize
            invalidateProperties([.size, .containerSize])
        }
    }

    func renderIfNeeded() {
        Update.locked {
            let now = ProcessInfo.processInfo.systemUptime
            guard target != nil, now >= nextDeadline else { return }
            nextDeadline = .infinity
            let interval = now - lastTimestamp
            lastTimestamp = now
            render(interval: interval, targetTimestamp: nil)
            if getenv("OPENSWIFTUI_PRINT_TREE") != nil {
                fflush(nil)
            }
        }
    }

    func requestUpdate(after delay: Double) {
        Update.locked {
            nextDeadline = min(nextDeadline, ProcessInfo.processInfo.systemUptime + delay)
        }
    }

    func updateRootView() { viewGraph.setRootView(Self.makeRootView(rootView)) }
    func updateEnvironment() { viewGraph.setEnvironment(EnvironmentValues()) }
    func updateTransform() { viewGraph.invalidateTransform() }
    func updateSize() { viewGraph.setProposedSize(size) }
    func updateSafeArea() { viewGraph.setSafeAreaInsets(.zero) }
    func updateContainerSize() { viewGraph.setContainerSize(.fixed(size)) }
    func updateFocusStore() {}
    func updateFocusedItem() {}
    func updateFocusedValues() {}
    func updateAccessibilityEnvironment() {}

    func `as`<T>(_ type: T.Type) -> T? {
        if ViewGraphRenderDelegate.self == T.self {
            return unsafeBitCast(self as any ViewGraphRenderDelegate, to: T.self)
        } else if DisplayList.ViewRenderer.self == T.self {
            return unsafeBitCast(renderer, to: T.self)
        } else if EventGraphHost.self == T.self {
            return unsafeBitCast(self as any EventGraphHost, to: T.self)
        }
        return nil
    }

    var renderingRootView: AnyObject { target! }
    func updateRenderContext(_ context: inout ViewGraphRenderContext) {
        context.contentsScale = 1
        context.opaqueBackground = true
    }
    func withMainThreadRender(wasAsync: Bool, _ body: () -> Time) -> Time { body() }
}
#endif
