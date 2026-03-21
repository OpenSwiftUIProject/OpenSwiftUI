//
//  CAHostingLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 5BC40379787EC8BFAE898D075045DC37 (SwiftUICore)

#if canImport(QuartzCore)
@_spiOnly public import QuartzCore

// MARK: - CAHostingLayer [TBA]

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

// MARK: - Sendable [TBA]

@_spi(ForUIKitOnly)
@_spi(ForAppKitOnly)
@available(*, unavailable)
extension CAHostingLayer: @unchecked Sendable {}

// MARK: - EventGraphHost [TBA]

extension CAHostingLayer: EventGraphHost {}

// MARK: - EventBindingManagerDelegate [TBA]

extension CAHostingLayer: EventBindingManagerDelegate {}

// MARK: - ViewRendererHost [TBA]

@_spi(ForUIKitOnly)
@_spi(ForAppKitOnly)
extension CAHostingLayer: ViewRendererHost {
    package func `as`<T>(_ type: T.Type) -> T? {
        _openSwiftUIUnimplementedFailure()
    }

    package func modifyViewInputs(_ inputs: inout _ViewInputs) {}

    package func updateRootView() {
        _openSwiftUIUnimplementedFailure()
    }

    package func updateEnvironment() {
        _openSwiftUIUnimplementedFailure()
    }

    package func updateSize() {
        _openSwiftUIUnimplementedFailure()
    }

    package func updateSafeArea() {
        _openSwiftUIUnimplementedFailure()
    }

    package func requestUpdate(after delay: Double) {
        _openSwiftUIUnimplementedFailure()
    }

    package func renderDisplayList(
        _ list: DisplayList,
        asynchronously: Bool,
        time: Time,
        nextTime: Time,
        targetTimestamp: Time?,
        version: DisplayList.Version,
        maxVersion: DisplayList.Version
    ) -> Time {
        _openSwiftUIUnimplementedFailure()
    }

    public func preferencesDidChange() {}

    package func updateScrollableContainerSize() {}

    package func updateFocusedItem() {}

    package func updateFocusedValues() {}

    package func updateFocusStore() {}

    package func updateAccessibilityFocus() {}

    package var responderNode: ResponderNode? {
        _openSwiftUIUnimplementedFailure()
    }

    package func updateTransform() {
        _openSwiftUIUnimplementedFailure()
    }

    package func updateContainerSize() {}

    package func updateAccessibilityEnvironment() {}
}

// MARK: - TestHost [TBA]

@_spi(ForUIKitOnly)
@_spi(ForAppKitOnly)
extension CAHostingLayer: TestHost {
    package var attributeCountInfo: AttributeCountTestInfo {
        _openSwiftUIUnimplementedFailure()
    }

    package var viewCacheIsEmpty: Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package func setTestSize(_ size: CGSize) {
        _openSwiftUIUnimplementedFailure()
    }

    package func setTestSafeAreaInsets(_ insets: EdgeInsets) {
        _openSwiftUIUnimplementedFailure()
    }

    package func renderForTest(interval: Double) {
        _openSwiftUIUnimplementedFailure()
    }

    public func _renderForTest(interval: Double) {
        _openSwiftUIUnimplementedFailure()
    }

    public func _renderAsyncForTest(interval: Double) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    final package func forEachDescendantHost(body: (any TestHost) -> Void) {
        _openSwiftUIUnimplementedFailure()
    }

    package func forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {}

    package var testSize: CGSize {
        frame.size
    }

    package func sendTestEvents(_ events: [EventID: any EventType]) {
        _openSwiftUIUnimplementedFailure()
    }

    package func resetTestEvents() {
        _openSwiftUIUnimplementedFailure()
    }

    package func invalidateProperties(_ props: ViewRendererHostProperties, mayDeferUpdate: Bool) {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ViewGraphRenderDelegate [TBA]

extension CAHostingLayer: ViewGraphRenderDelegate {
    package var renderingRootView: AnyObject {
        _openSwiftUIUnimplementedFailure()
    }

    package func updateRenderContext(_ context: inout ViewGraphRenderContext) {
        _openSwiftUIUnimplementedFailure()
    }

    package func withMainThreadRender(wasAsync: Bool, _ body: () -> Time) -> Time {
        body()
    }
}

// MARK: - Other Conformances [TBA]

@_spi(ForOpenSwiftUIOnly)
extension CAHostingLayer: GraphDelegate {}

extension CAHostingLayer: ViewGraphDelegate {}

@_spi(ForUIKitOnly)
@_spi(ForAppKitOnly)
extension CAHostingLayer: _BenchmarkHost {}

#endif
