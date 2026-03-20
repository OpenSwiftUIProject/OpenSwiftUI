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

    final let renderer: DisplayList.ViewRenderer

    final package let eventBindingManager: EventBindingManager

    package var propertiesNeedingUpdate: ViewRendererHostProperties

    package var renderingPhase: ViewRenderingPhase

    var isRendering: Bool

    package var isHiddenForReuse: Bool

    package var currentTimestamp: Time

    package var externalUpdateCount: Int

    package var environmentOverride: EnvironmentValues?

    var safeAreaInsetsOverride: EdgeInsets?

    var accessibilityVersion: DisplayList.Version

    private var canAdvanceTimeAutomatically: Bool

    private var allowFrameChanges: Bool

    private var nextTimerTime: Time?

    private var updateTimer: Timer?

    private var isUpdating: Bool

    private var needsDeferredUpdate: Bool

    final package let focusedResponder: ResponderNode?

    final public let referenceInstant: ContinuousClock.Instant

    private lazy var eventContext: CAHostingLayerEvent.Context? = nil

    // MARK: - Computed Properties [TBA]

    package var accessibilityEnabled: Bool {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }

    @objc override dynamic public var bounds: CGRect {
        get { super.bounds }
        set {
            let oldBounds = super.bounds
            super.bounds = newValue
            if oldBounds.size != newValue.size {
                invalidateProperties(.size, mayDeferUpdate: true)
            }
        }
    }

    @objc override dynamic public var position: CGPoint {
        get { super.position }
        set {
            guard allowFrameChanges else { return }
            super.position = newValue
        }
    }

    @objc override dynamic public var contentsScale: CGFloat {
        get { super.contentsScale }
        set {
            let oldValue = super.contentsScale
            super.contentsScale = newValue
            if oldValue != newValue {
                invalidateProperties(.environment, mayDeferUpdate: true)
            }
        }
    }

    public var rootView: Content {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }

    public var environment: EnvironmentValues {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }

    // MARK: - Init [TBA]

    public init(rootView: Content, environment: EnvironmentValues = .init()) {
        _openSwiftUIUnimplementedFailure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods [TBA]

    @objc override dynamic public func layoutSublayers() {
        _openSwiftUIUnimplementedFailure()
    }

    public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        _openSwiftUIUnimplementedFailure()
    }

    public func send(event: CAHostingLayerEvent) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package func didBind(to newBinding: EventBinding, id: EventID) {
        _openSwiftUIUnimplementedFailure()
    }

    package func didUpdate(phase: GesturePhase<Void>, in eventBindingManager: EventBindingManager) {
        _openSwiftUIUnimplementedFailure()
    }

    package func requestHoverUpdate(in eventBindingManager: EventBindingManager) {}

    deinit {}
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
