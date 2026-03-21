//
//  CAHostingLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 5BC40379787EC8BFAE898D075045DC37 (SwiftUICore)

#if canImport(QuartzCore)
@_spiOnly public import QuartzCore

// MARK: - CAHostingLayer

@_spi(ForUIKitOnly)
@_spi(ForAppKitOnly)
@available(OpenSwiftUI_v6_0, *)
public class CAHostingLayer<Content>: CALayer where Content: View {
    final package let viewGraph: ViewGraph

    final let renderer = DisplayList.ViewRenderer(platform: .init(definition: CAHostingLayerPlatformDefinition.self))

    final package let eventBindingManager: EventBindingManager = .init()

    package var propertiesNeedingUpdate: ViewRendererHostProperties = .all

    package var renderingPhase: ViewRenderingPhase = .none

    var isRendering: Bool = false

    package var isHiddenForReuse: Bool = false

    package var currentTimestamp: Time = .init()

    package var externalUpdateCount: Int = 0

    package var environmentOverride: EnvironmentValues? {
        didSet {
            invalidateProperties(.environment, mayDeferUpdate: true)
        }
    }

    var safeAreaInsetsOverride: EdgeInsets? {
        didSet {
            invalidateProperties(.safeArea, mayDeferUpdate: false)
        }
    }

    var accessibilityVersion: DisplayList.Version = .init()

    package var accessibilityEnabled: Bool {
        get { viewGraph.accessibilityEnabled }
        set { viewGraph.accessibilityEnabled = newValue }
    }

    private var canAdvanceTimeAutomatically: Bool = true

    private var allowFrameChanges: Bool = true

    private var nextTimerTime: Time?

    private var updateTimer: Timer?

    private var isUpdating: Bool = false

    private var needsDeferredUpdate: Bool = false

    final package let focusedResponder: ResponderNode? = nil

    public init(rootView: Content, environment: EnvironmentValues = .init()) {
        self.rootView = rootView
        self.environment = environment
        self.referenceInstant = .now
        Update.begin()
        let modifiedRootView = Self.makeRootView(rootView)
        self.viewGraph = ViewGraph(rootView: modifiedRootView, environment: environment)
        super.init()
        postInit()
        Update.end()
    }

    public override init(layer: Any) {
        guard let hosting = layer as? CAHostingLayer<Content> else {
            _openSwiftUIUnreachableCode()
        }
        let rootView = hosting.rootView
        let environment = hosting.environment
        self.rootView = rootView
        self.environment = environment
        self.referenceInstant = .now
        Update.begin()
        let modifiedRootView = Self.makeRootView(rootView)
        self.viewGraph = ViewGraph(rootView: modifiedRootView, environment: environment)
        super.init(layer: layer)
        postInit()
        Update.end()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func postInit() {
        initializeViewGraph()
        renderer.host = self
        eventBindingManager.host = self
        eventBindingManager.delegate = self
    }

    override dynamic public var bounds: CGRect {
        get {
            super.bounds
        }
        set {
            guard allowFrameChanges else {
                return
            }
            let oldValue = super.bounds
            super.bounds = newValue
            if oldValue.size != newValue.size {
                invalidateProperties(.size, mayDeferUpdate: false)
            }
        }
    }

    override dynamic public var position: CGPoint {
        get {
            super.position
        }
        set {
            guard allowFrameChanges else { return }
            super.position = newValue
        }
    }

    override dynamic public var contentsScale: CGFloat {
        didSet {
            if oldValue != contentsScale {
                invalidateProperties(.environment, mayDeferUpdate: true)
            }
        }
    }

    override dynamic public func layoutSublayers() {
        super.layoutSublayers()
        guard canAdvanceTimeAutomatically else { return }
        Update.locked {
            let startTime = CACurrentMediaTime()
            isUpdating = true
            render(interval: 0, updateDisplayList: true, targetTimestamp: nil)
            isUpdating = false
            if needsDeferredUpdate {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 / 60.0) { [weak self] in
                    guard let self else { return }
                    let elapsed = CACurrentMediaTime() - startTime
                    currentTimestamp.seconds += elapsed
                    setNeedsLayout()
                }
                needsDeferredUpdate = false
            }
        }
    }

    public var rootView: Content {
        didSet {
            invalidateProperties(.rootView, mayDeferUpdate: true)
        }
    }

    public var environment: EnvironmentValues {
        didSet {
            invalidateProperties(.environment, mayDeferUpdate: true)
        }
    }

    public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        sizeThatFits(_ProposedSize(proposal))
            .rounded(.up, toMultipleOf: environment.pixelLength)
    }

    public func observeSizeThatFitsChanges(
        proposal: ProposedViewSize,
        handler: @escaping (CGSize) -> Void
    ) {
        viewGraph.sizeThatFitsObservers.addObserver(
            for: _ProposedSize(proposal)
        ) { _, newSize in
            handler(newSize)
        }
    }

    public func stopObservingSizeThatFitsChanges(
        proposal: ProposedViewSize
    ) {
        viewGraph.sizeThatFitsObservers.stopObserving(
            proposal: _ProposedSize(proposal)
        )
    }

    final public let referenceInstant: ContinuousClock.Instant

    private lazy var eventContext = CAHostingLayerEvent.Context(referenceInstant: referenceInstant)

    public func send(event: CAHostingLayerEvent) -> Bool {
        let resolved = event._resolve(&eventContext)
        guard !resolved.isEmpty else { return false }
        var allDispatchedIDs: [EventID] = []
        for resolvedEvent in resolved {
            let id = EventID(
                type: type(of: resolvedEvent.event),
                serial: resolvedEvent.sequence
            )
            let dispatched = eventBindingManager.send([id: resolvedEvent.event])
            allDispatchedIDs.append(contentsOf: dispatched)
        }
        return !allDispatchedIDs.isEmpty
    }

    package func didBind(to newBinding: EventBinding, id: EventID) {
        _openSwiftUIEmptyStub()
    }

    package func didUpdate(
        phase: GesturePhase<Void>,
        in eventBindingManager: EventBindingManager
    ) {
        guard phase.isTerminal else {
            return
        }
        eventBindingManager.reset(resetForwardedEventDispatchers: false)
    }
}

@_spi(ForUIKitOnly)
@_spi(ForAppKitOnly)
@available(*, unavailable)
extension CAHostingLayer: @unchecked Sendable {}

// MARK: - CAHostingLayer + EventGraphHost

extension CAHostingLayer: EventGraphHost {}

// MARK: - CAHostingLayer + EventBindingManagerDelegate

extension CAHostingLayer: EventBindingManagerDelegate {}

// MARK: - CAHostingLayer + ViewRendererHost

@_spi(ForUIKitOnly)
@_spi(ForAppKitOnly)
extension CAHostingLayer: ViewRendererHost {
    package func `as`<T>(_ type: T.Type) -> T? {
        if EventGraphHost.self == T.self {
            return unsafeBitCast(self as any EventGraphHost, to: T.self)
        } else if CALayer.self == T.self {
            return unsafeBitCast(self as CALayer, to: T.self)
        } else if ViewGraphRenderDelegate.self == T.self {
            return unsafeBitCast(self as any ViewGraphRenderDelegate, to: T.self)
        } else if DisplayList.ViewRenderer.self == T.self {
            return unsafeBitCast(renderer, to: T.self)
        } else {
            return nil
        }
    }

    package func updateRootView() {
        let modifiedRootView = Self.makeRootView(rootView)
        viewGraph.setRootView(modifiedRootView)
    }

    package func updateEnvironment() {
        var environment = environment
        environment.displayScale = contentsScale
        environmentOverride.map {
            environment.plist.override(with: $0.plist)
        }
        viewGraph.setEnvironment(environment)
    }

    package func updateSize() {
        viewGraph.setProposedSize(bounds.size)
    }

    package func updateSafeArea() {
        let insets = safeAreaInsetsOverride ?? EdgeInsets()
        viewGraph.setSafeAreaInsets(insets)
    }

    package func requestUpdate(after delay: Double) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                requestUpdate(after: delay)
            }
            return
        }
        Update.locked {
            if delay < 0.25 {
                if isUpdating {
                    needsDeferredUpdate = true
                } else {
                    setNeedsLayout()
                }
            } else {
                guard (currentTimestamp + delay) < (nextTimerTime ?? .infinity) else { return }
                updateTimer?.invalidate()
                nextTimerTime = currentTimestamp + delay
                let timer = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
                    guard let self else { return }
                    updateTimer = nil
                    nextTimerTime = nil
                    setNeedsLayout()
                }
                RunLoop.main.add(timer, forMode: .common)
                updateTimer = timer
            }
        }
    }

    public func preferencesDidChange() {
        _openSwiftUIEmptyStub()
    }

    package func updateContainerSize() {
        _openSwiftUIEmptyStub()
    }

    package func updateFocusStore() {
        _openSwiftUIEmptyStub()
    }

    package func updateFocusedItem() {
        _openSwiftUIEmptyStub()
    }

    package func updateFocusedValues() {
        _openSwiftUIEmptyStub()
    }

    package func updateAccessibilityEnvironment() {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - CAHostingLayer + ViewGraphRenderDelegate

extension CAHostingLayer: ViewGraphRenderDelegate {
    package var renderingRootView: AnyObject {
        self
    }

    package func updateRenderContext(_ context: inout ViewGraphRenderContext) {
        context.contentsScale = contentsScale
    }
}

// MARK: - CAHostingLayer + TestHost

@_spi(ForUIKitOnly)
@_spi(ForAppKitOnly)
extension CAHostingLayer: TestHost {
    package var attributeCountInfo: AttributeCountTestInfo {
        .init()
    }

    package var viewCacheIsEmpty: Bool {
        Update.locked {
            renderer.viewCacheIsEmpty
        }
    }

    package func setTestSize(_ size: CGSize) {
        guard bounds.size != size else { return }
        allowFrameChanges = true
        let superBounds = superlayer?.bounds ?? .zero
        super.frame = size.centeredIn(superBounds)
        allowFrameChanges = false
    }

    package func setTestSafeAreaInsets(_ insets: EdgeInsets) {
        safeAreaInsetsOverride = insets
    }

    package func renderForTest(interval: Double) {
        _renderForTest(interval: interval)
    }

    public func _renderForTest(interval: Double) {
        advanceTimeForTest(interval: interval)
        let saved = canAdvanceTimeAutomatically
        canAdvanceTimeAutomatically = false
        repeat {
            RunLoop.flushObservers()
            render(targetTimestamp: nil)
            CATransaction.flush()
        } while !propertiesNeedingUpdate.isEmpty
        canAdvanceTimeAutomatically = saved
    }

    public func _renderAsyncForTest(interval: Double) -> Bool {
        advanceTimeForTest(interval: interval)
        let saved = canAdvanceTimeAutomatically
        canAdvanceTimeAutomatically = false
        var result = true
        repeat {
            RunLoop.flushObservers()
            let didRender = Update.locked {
                renderAsync(interval: 0, targetTimestamp: nil) != nil
            }
            if didRender {
                CATransaction.flush()
                if result {
                    result = !viewGraph.updateRequiredMainThread
                }
            } else {
                result = false
            }
        } while !propertiesNeedingUpdate.isEmpty
        canAdvanceTimeAutomatically = saved
        return result
    }

    final package func forEachDescendantHost(body: (any TestHost) -> Void) {
        func visit(_ layer: CALayer) {
            if let host = layer as? TestHost {
                body(host)
            }
            let sublayers = layer.sublayers ?? []
            for sublayer in sublayers {
                visit(sublayer)
            }
        }
        visit(self)
    }

    package func forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {
        _openSwiftUIEmptyStub()
    }

    package var testSize: CGSize {
        frame.size
    }
}

#endif
