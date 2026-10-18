//
//  NSHostingView.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: WIP
//  ID: 32B6F54841135BB466A5C1362EB89D05 (SwiftUI)

#if os(macOS)
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
public import OpenSwiftUICore
public import AppKit
import OpenSwiftUI_SPI
import COpenSwiftUI

/// An AppKit view that hosts a OpenSwiftUI view hierarchy.
///
/// You use `NSHostingView` objects to integrate OpenSwiftUI views into your
/// AppKit view hierarchies. A hosting view is an
/// [NSView](https://developer.apple.com/documentation/AppKit/NSView) object that manages a single
/// OpenSwiftUI view, which may itself contain other OpenSwiftUI views. Because it is an
/// [NSView](https://developer.apple.com/documentation/AppKit/NSView) object, you can integrate it
/// into your existing AppKit view hierarchies to implement portions of your UI.
/// For example, you can use a hosting view to implement a custom control.
///
/// A hosting view acts as a bridge between your OpenSwiftUI views and your AppKit
/// interface. During layout, the hosting view reports the content size
/// preferences of your OpenSwiftUI views back to the AppKit layout system so that
/// it can size the view appropriately. The hosting view also coordinates event
/// delivery.
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
open class NSHostingView<Content>: NSView, XcodeViewDebugDataProvider where Content: View {
    /// The options for how the hosting view creates and updates constraints
    /// based on the size of its OpenSwiftUI content.
    ///
    /// NSHostingView can create minimum, maximum, and ideal (content size)
    /// constraints that are derived from its OpenSwiftUI view content. These
    /// constraints are only created when Auto Layout constraints are otherwise
    /// being used in the containing window.
    ///
    /// If the NSHostingView is set as the `contentView` of an `NSWindow`, it
    /// will also update the window's `contentMinSize` and `contentMaxSize`
    /// based on the minimum and maximum size of its OpenSwiftUI content.
    ///
    /// `sizingOptions` defaults to `.standardBounds` (which includes
    /// `minSize`, `intrinsicContentSize`, and `maxSize`), but can be set to an
    /// explicit value to control this behavior. For instance, setting a value
    /// of `.minSize` will only create the constraints necessary to maintain the
    /// minimum size of the OpenSwiftUI content, or setting a value of `[]` will
    /// create no constraints at all.
    ///
    /// If a use case can make assumptions about the size of the `NSHostingView`
    /// relative to its displayed content, such as the always being displayed in
    /// a fixed frame, setting this to a value with fewer options can improve
    /// performance as it reduces the amount of layout measurements that need to
    /// be performed. If an `NSHostingView` has a `frame` that is smaller or
    /// larger than that required to display its OpenSwiftUI content, the content
    /// will be centered within that frame.
    public var sizingOptions: NSHostingSizingOptions = .standardBounds {
        didSet {
            guard sizingOptions != oldValue else { return }
            needsUpdateConstraints = true
            invalidateIntrinsicContentSize()
        }
    }

    /// The safe area regions that this view controller adds to its view.
    ///
    /// The default value is ``SafeAreaRegions.all``.
    public var safeAreaRegions: SafeAreaRegions = .all {
        didSet {
            guard safeAreaRegions != oldValue else { return }
            needsUpdateConstraints = true
            invalidateIntrinsicContentSize()
        }
    }

    /// The options for which aspects of the window will be managed by this
    /// hosting view.
    ///
    /// `NSHostingView` will populate certain aspects of its associated
    /// window, depending on which options are specified.
    ///
    /// For example, a hosting view can manage its window's toolbar by including
    /// the `.toolbars` option:
    ///
    ///     struct RootView: View {
    ///         var body: some View {
    ///             ContentView()
    ///                 .toolbar {
    ///                     MyToolbarContent()
    ///                 }
    ///         }
    ///     }
    ///
    ///     let view = NSHostingView(rootView: RootView())
    ///     view.sceneBridgingOptions = [.toolbars]
    ///
    /// When this hosting view is set as the `contentView` for a window, the
    /// default value for this property will be `.all`, which includes the
    /// options for `.toolbars` and `.title`. Otherwise, the default value is
    /// `[]`.
    public var sceneBridgingOptions: NSHostingSceneBridgingOptions = [] {
        didSet {
            // TODO
        }
    }

    private var _rootView: Content

    package final let viewGraph: ViewGraph

    package let eventBindingManager = EventBindingManager()

    var focusBridge = FocusBridge()

    var focusedValues = FocusedValues() {
        didSet {
            invalidateProperties(.focusedValues)
        }
    }

    // TODO: Forward changes to AccessibilityViewGraph when that feature is available.
    var currentAccessibilityFocusStore = AccessibilityFocusStore()

    private var keyEventTracker = KeyEvent.Tracker()

    private var isOfferingKeyEventToFirstResponder = false

    private var eventsInProgress: Set<EventID> = []

    private var eventsPendingReset: Set<EventID> = []

    private var hitTestEventMonitor: Any?

    private var geometryChangeRegistrationPhase: HostingViewGeometryRegistrationPhase = .unregistered

    private var geometryChangeObserver: Any?

    private lazy var eventBindingSource = BindingSource(hostingView: self)

    private lazy var eventBridge = AppKitEventBindingBridge(
        hostingViewBindingSource: eventBindingSource,
        eventBindingManager: eventBindingManager
    )

    private final class BindingSource: EventBindingSource {
        weak var hostingView: NSHostingView?

        init(hostingView: NSHostingView) {
            self.hostingView = hostingView
        }

        func attach(to eventBridge: EventBindingBridge) {
            preconditionFailure("Event bridge is already attached.")
        }

        func didBind(to newBinding: EventBinding, id: EventID, in eventBridge: EventBindingBridge) {
            guard GestureRecognizerBasedEvents.isEnabled, eventBridge === self else {
                return
            }
            hostingView?.didBind(to: newBinding)
        }

        func didRequestHoverUpdate(in eventBridge: EventBindingBridge) {
            guard GestureRecognizerBasedEvents.isEnabled, eventBridge === self else {
                return
            }
            hostingView?.didRequestHoverUpdate()
        }
    }

    private func didBind(to newBinding: EventBinding) {
        // TODO: FocusBridge
        _openSwiftUIUnimplementedWarning()
    }

    private func didRequestHoverUpdate() {
        // TODO: hover
        _openSwiftUIUnimplementedWarning()
    }

    package final let renderer = DisplayList.ViewRenderer(platform: .init(definition: NSViewPlatformViewDefinition.self))

    package var currentTimestamp: Time = .zero

    package var propertiesNeedingUpdate: ViewRendererHostProperties = .all

    package var renderingPhase: ViewRenderingPhase = .none

    package var isHiddenForReuse: Bool = false {
        didSet {
            updateRemovedState()
        }
    }

    private var cachedIntrinsicContentSize = CGSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)

    private var displayLink: DisplayLink?

    package var externalUpdateCount: Int = .zero

    private var canAdvanceTimeAutomatically = true

    private var needsDeferredUpdate = false

    package var updateTimer: Timer?

    package var lastUpdateTime: Time = .zero

    package var nextTimerTime: Time?

    private var isPerformingLayout: Bool {
        if renderingPhase == .rendering {
            return true
        }
        return externalUpdateCount > 0
    }

    final override public var isFlipped: Bool { true }

    open override class var requiresConstraintBasedLayout: Bool { true }

    open override var layerContentsRedrawPolicy: NSView.LayerContentsRedrawPolicy {
        set { }
        get { .duringViewResize }
    }

    open override var intrinsicContentSize: NSSize {
        guard sizingOptions.contains(.intrinsicContentSize),
              !checkForReentrantLayout()
        else {
            return cachedIntrinsicContentSize
        }

        var size = idealSize()
        let pixelLength = convertFromBacking(CGSize(width: 1, height: 1))
        size.width = size.width.rounded(.up, toMultipleOf: pixelLength.width)
        size.height = size.height.rounded(.up, toMultipleOf: pixelLength.height)

        if size.width == 0 || size.height == 0 {
            let minSize = self.minSize()
            let maxSize = self.maxSize()
            if maxSize.width >= 2777777.0 && minSize.width == 0 && size.width == 0 {
                size.width = NSView.noIntrinsicMetric
            }
            if maxSize.height >= 2777777.0 && minSize.height == 0 && size.height == 0 {
                size.height = NSView.noIntrinsicMetric
            }
        }

        cachedIntrinsicContentSize = size
        return cachedIntrinsicContentSize
    }

    private func _layoutSizeThatFits(_ size: CGSize, fixedAxes: UInt) -> CGSize {
        guard sizingOptions.contains(.intrinsicContentSize),
              !checkForReentrantLayout()
        else {
            return cachedIntrinsicContentSize
        }

        let maxValue = 2777777.0
        let fittingSize = sizeThatFits(.init(
            width: size.width >= maxValue ? nil : size.width,
            height: size.height >= maxValue ? nil : size.height
        ))

        let pixelLength = convertFromBacking(CGSize(width: 1, height: 1))
        let result = fittingSize.rounded(.up, toMultipleOf: pixelLength.width)

        cachedIntrinsicContentSize = result
        return result
    }

    private var _axesForDerivingIntrinsicContentSizeFromLayoutSize: UInt {
        sizingOptions.contains(.intrinsicContentSize) ? 3 : 0
    }

    /// Creates a hosting view object that wraps the specified OpenSwiftUI view.
    ///
    /// - Parameter rootView: The root view of the OpenSwiftUI view hierarchy that
    ///   you want to manage using this hosting view.
    public required init(rootView: Content) {
        self._rootView = rootView
        // TODO
        Update.begin()
        self.viewGraph = ViewGraph(
            rootViewType: ModifiedContent<Content, HitTestBindingModifier>.self
        )
        // TODO
        super.init(frame: .zero)
        eventBindingManager.addForwardedEventDispatcher(KeyEventDispatcher())
        appendViewGraphFeatures()
        initializeViewGraph()
        // TODO
        clipsToBounds = false
        // TODO
        wantsLayer = true
        // TODO
        renderer.host = self
        eventBindingManager.host = self
        if GestureRecognizerBasedEvents.isEnabled {
            eventBindingManager.delegate = eventBridge
        } else {
            eventBindingManager.delegate = self
        }
        focusBridge._host = self
        viewGraph.addPreference(FocusedValueList.Key.self)
        viewGraph.addPreference(FocusStoreList.Key.self)
        viewGraph.addPreference(AccessibilityFocusStoreList.Key.self)
        viewGraph.addPreference(KeyViewLoopSeedKey.self)
        if GestureRecognizerBasedEvents.isEnabled {
            addGestureRecognizer(eventBridge.recognizer)
        }
        HostingViewRegistry.shared.add(self)
        if _eventDebugTriggers.contains(.hitTest) {
            hitTestEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
                guard let self, event.window === self.window else {
                    return event
                }
                guard sequence(first: self as NSView, next: { $0.superview })
                    .dropFirst().first(ofType: HostingViewProtocol.self) == nil else {
                    return event
                }
                let point = self.convert(event.locationInWindow, from: nil)
                self.printHitTest(point)
                return event
            }
        }
        Update.end()
        // TODO
        setNeedsUpdate()
    }

    /// Creates a hosting view object from the contents of the specified
    /// archive.
    ///
    /// The default implementation of this method throws an exception. Use the
    /// ``NSHostingView/init(rootView:)`` method to create your hosting view
    /// instead.
    ///
    /// - Parameter coder: The decoder to use during initialization.
    @available(*, unavailable)
    public dynamic required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    deinit {
        updateRemovedState()
        // TODO
        HostingViewRegistry.shared.remove(self)
        if let hitTestEventMonitor {
            NSEvent.removeMonitor(hitTestEventMonitor)
        }
    }

    func appendViewGraphFeatures() {
        viewGraph.append(feature: FocusViewGraph(graph: viewGraph))
        // TODO
    }

    /// The renderer configuration of the hosting view.
    public final var _rendererConfiguration: _RendererConfiguration {
        get {
            Update.locked { renderer.configuration }
        }
        set {
            Update.locked { renderer.configuration = newValue }
        }
    }

    /// An optional object representing the current renderer.
    public final var _rendererObject: AnyObject? {
        Update.locked {
            renderer.exportedObject(rootView: self)
        }
    }

    private var isUpdating = false

    private var isUpdatingConstraints = false

    private var isCreatingEnvironment = false

    private static var _presentationTime: Double {
        if let value = CATransaction.value(forKey: "NSHostingViewPresentationTime") as? Double {
            return value
        }
        let time = CACurrentMediaTime()
        CATransaction.setValue(NSNumber(value: time), forKey: "NSHostingViewPresentationTime")
        return time
    }

    @objc
    func _willUpdateConstraintsForSubtree() {
        isUpdatingConstraints = true
        defer { isUpdatingConstraints = false }

        guard needsUpdateConstraints,
              !checkForReentrantLayout() else {
            return
        }

        Update.locked {
            cancelAsyncRendering()
        }

        if canAdvanceTimeAutomatically {
            let time = Time(seconds: Self._presentationTime)
            advanceTime(with: time)
        }

        if translatesAutoresizingMaskIntoConstraints {
            sizeConstraints?.deactivate()
            sizeConstraints = nil
        } else {
            if sizeConstraints == nil {
                sizeConstraints = SizeConstraints()
            }
            sizeConstraints?.update(from: self)
        }
    }

    open override func updateConstraints() {
        _willUpdateConstraintsForSubtree()
        updateWindowContentSizeExtremaIfNecessary()
        // TODO: notify delegate (hostingViewDidUpdateConstraints)
        super.updateConstraints()
    }

    open override func setFrameSize(_ newSize: NSSize) {
        let oldSize = frame.size
        super.setFrameSize(newSize)
        if oldSize != newSize {
            invalidateProperties([.size, .containerSize], mayDeferUpdate: false)
        }
    }

    open override func viewWillMove(toWindow newWindow: NSWindow?) {
        let oldWindow = self.window
        let center = NotificationCenter.default
        
        if let oldWindow {
            center.removeObserver(self, name: NSWindow.didBecomeMainNotification, object: oldWindow)
            center.removeObserver(self, name: NSWindow.didResignMainNotification, object: oldWindow)
            center.removeObserver(self, name: NSWindow.didBecomeKeyNotification, object: oldWindow)
            center.removeObserver(self, name: NSWindow.didResignKeyNotification, object: oldWindow)
            // TODO: NSWindowDidOrderOnScreenNotification / NSWindowDidOrderOffScreenNotification (private API)
            center.removeObserver(self, name: NSWindow.willBeginSheetNotification, object: oldWindow)
            center.removeObserver(self, name: NSWindow.didEndSheetNotification, object: oldWindow)
            center.removeObserver(self, name: NSWindow.didChangeScreenNotification, object: oldWindow)
            // TODO: removeObserver for KVO on "showsWindowSharingTitlebarButton"
            removeWindowContentSizeExtremaIfNecessary()
        }
        
        if let newWindow {
            center.addObserver(self, selector: #selector(windowDidChangeMain), name: NSWindow.didBecomeMainNotification, object: newWindow)
            center.addObserver(self, selector: #selector(windowDidChangeMain), name: NSWindow.didResignMainNotification, object: newWindow)
            center.addObserver(self, selector: #selector(windowDidChangeKey), name: NSWindow.didBecomeKeyNotification, object: newWindow)
            center.addObserver(self, selector: #selector(windowDidChangeKey), name: NSWindow.didResignKeyNotification, object: newWindow)
            // TODO: NSWindowDidOrderOnScreenNotification / NSWindowDidOrderOffScreenNotification → windowDidChangeVisibility
            center.addObserver(self, selector: #selector(windowWillBeginSheet), name: NSWindow.willBeginSheetNotification, object: newWindow)
            center.addObserver(self, selector: #selector(windowDidEndSheet), name: NSWindow.didEndSheetNotification, object: newWindow)
            center.addObserver(self, selector: #selector(windowDidChangeScreen), name: NSWindow.didChangeScreenNotification, object: newWindow)
            newWindow.observeFirstResponderChanges()
            // TODO: KVO on "showsWindowSharingTitlebarButton"
        }
        invalidateProperties(.environment)
        super.viewWillMove(toWindow: newWindow)
    }

    open override func viewDidChangeBackingProperties() {
        // TODO
        invalidateProperties(.environment)
        needsUpdateConstraints = true
        invalidateIntrinsicContentSize()
    }

    open override func viewDidChangeEffectiveAppearance() {
        if !isCreatingEnvironment {
            invalidateProperties(.environment)
        }
    }

    open override func viewDidMoveToWindow() {
        Update.begin()
        // TODO: delegate handling
        if window != nil {
            invalidateProperties(.transform)
        } else {
            Update.locked {
                cancelAsyncRendering()
            }
            if GestureRecognizerBasedEvents.isEnabled {
                eventBridge.reset(eventSource: eventBindingSource, resetForwardedEventDispatchers: true)
            } else {
                eventBindingManager.reset(resetForwardedEventDispatchers: true)
            }
        }
        updateRemovedState()
        // TODO: initialInheritedEnvironment / inferredGraphTraits
        super.viewDidMoveToWindow()
        focusBridge.hostHierarchyDidChange()
        Update.end()
    }

    open override func prepareForReuse() {
        // TODO: Clear the hover-active flag when hover tracking is implemented.
        if GestureRecognizerBasedEvents.isEnabled {
            eventBridge.reset(eventSource: eventBindingSource, resetForwardedEventDispatchers: true)
        } else {
            eventBindingManager.reset(resetForwardedEventDispatchers: true)
        }
    }

    open override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        if key == "safeAreaInsets" {
            invalidateSafeAreaInsets()
        }
    }

    // MARK: - Key events [TBA]

    open override var acceptsFirstResponder: Bool {
        focusBridge.hostAcceptsFirstResponder
    }

    open override func _recursiveSetDefaultKeyViewLoop() -> NSView? {
        focusBridge.updateDefaultKeyViewLoop()
    }

    open override func designatedFocusRing() -> NSView? {
        focusBridge.designatedFocusRingView
    }

    open override func _recursiveGatherAllKeyViewCandidates(in array: NSMutableArray) {
        guard let candidates = focusBridge.sortedCandidateKeyViews else { return }
        for view in candidates where view !== self {
            if view.canBecomeKeyView {
                array.add(view)
            }
            view._recursiveGatherAllKeyViewCandidates(in: array)
        }
    }

    open override func _firstResponder(for event: NSEvent) -> NSResponder? {
        hasFilter(for: event) ? self : super._firstResponder(for: event)
    }

    private func hasFilter(for event: NSEvent) -> Bool {
        guard lastInterceptedKeyEvent !== event,
              event.type == .keyDown || event.type == .keyUp,
              let keyEvent = event.resolve(phase: .active),
              eventBindingManager.binds(keyEvent)
        else {
            return false
        }
        lastInterceptedKeyEvent = event
        return true
    }

    open override func keyDown(with event: NSEvent) {
        guard !isOfferingKeyEventToFirstResponder,
              lastInterceptedKeyEvent === event
        else {
            // TODO: Interpret responder commands before forwarding.
            super.keyDown(with: event)
            return
        }
        guard !sendKeyEvent(event, phase: .began) else {
            return
        }
        if lastInterceptedKeyEvent === event, let firstResponder = window?.firstResponder {
            isOfferingKeyEventToFirstResponder = true
            firstResponder.keyDown(with: event)
            isOfferingKeyEventToFirstResponder = false
        } else {
            // TODO: Interpret responder commands before forwarding.
            super.keyDown(with: event)
        }
    }

    open override func keyUp(with event: NSEvent) {
        guard !isOfferingKeyEventToFirstResponder else {
            super.keyUp(with: event)
            return
        }
        guard !sendKeyEvent(event, phase: .ended) else {
            return
        }
        if lastInterceptedKeyEvent === event, let firstResponder = window?.firstResponder {
            isOfferingKeyEventToFirstResponder = true
            firstResponder.keyUp(with: event)
            isOfferingKeyEventToFirstResponder = false
        } else {
            super.keyUp(with: event)
        }
    }

    private func sendKeyEvent(_ event: NSEvent, phase: EventPhase) -> Bool {
        guard let keyEvent = event.resolve(phase: phase) else {
            return false
        }
        return sendEvent(keyEvent, serial: keyEventTracker.serial(for: keyEvent), track: true)
    }

    package func sendEvent<E>(_ event: E, serial: Int, track: Bool) -> Bool where E: EventType {
        let id = EventID(type: E.self, serial: serial)
        return sendEvents([id: event], track: track) == [id]
    }

    package func sendEvents(_ events: [EventID: any EventType], track: Bool) -> Set<EventID> {
        if GestureRecognizerBasedEvents.isEnabled {
            return eventBridge.send(events, source: eventBindingSource)
        }
        guard track else {
            return eventBindingManager.send(events)
        }
        if _TestApp.host != nil,
           let event = events.first?.value,
           HoverEvent(event) != nil || KeyEvent(event) != nil {
            return eventBindingManager.send(events)
        }
        var downstreamEvents: [EventID: any EventType] = [:]
        for (id, event) in events {
            if !event.phase.isTerminal {
                eventsInProgress.insert(id)
            }
            if !eventsPendingReset.contains(id) {
                downstreamEvents[id] = event
            }
        }
        let handledEvents = downstreamEvents.isEmpty ? [] : eventBindingManager.send(downstreamEvents)
        for (id, event) in events where event.phase.isTerminal {
            eventsInProgress.remove(id)
            eventsPendingReset.remove(id)
        }
        return handledEvents
    }

    package func resetEventState() {
        guard !GestureRecognizerBasedEvents.isEnabled else {
            return
        }
        eventsPendingReset.formUnion(eventsInProgress)
        eventsInProgress = []
        eventBindingManager.reset()
    }

    private func geometryInWindowDidChange() {
        switch geometryChangeRegistrationPhase {
        case .unregistered:
            Log.internalError("Received geometry change with no registration for \(self).")
        case .registering:
            break
        case .registered:
            invalidateProperties(.transform, mayDeferUpdate: false)
        }
    }

    open override func layout() {
        guard canAdvanceTimeAutomatically else {
            return
        }
        guard !checkForReentrantLayout() else {
            needsDeferredUpdate = true
            return
        }
        // TODO
        Update.locked {
            cancelAsyncRendering()
        }
        // TODO
        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = false
            var iteration = 0
            repeat {
                needsDeferredUpdate = false
                isUpdating = true
                render(targetTimestamp: nil)
                isUpdating = false
                if needsDeferredUpdate,
                   !viewGraph.updateRequiredMainThread,
                   isLinkedOnOrAfter(.v3),
                   !viewGraph.mayDeferUpdate {
                    if startAsyncRendering() {
                        needsDeferredUpdate = false
                    }
                }
                iteration += 1
            } while needsDeferredUpdate && iteration < 8
        }
    }

    func setRootView(_ view: Content, transaction: Transaction) {
        _rootView = view
        viewGraph.asyncTransaction(transaction) { [weak self] in
            guard let self else { return }
            updateRootView()
        }
    }

    /// The root view of the OpenSwiftUI view hierarchy managed by this view
    /// controller.
    public var rootView: Content {
        get { _rootView }
        set {
            _rootView = newValue
            invalidateProperties(.rootView)
        }
    }

    var initialInheritedEnvironment: EnvironmentValues? = nil

    var inheritedEnvironment: EnvironmentValues? = nil {
        didSet {
            invalidateProperties(.environment)
        }
    }

    package var environmentOverride: EnvironmentValues? = nil {
        didSet {
            invalidateProperties(.environment)
        }
    }

    private lazy var foreignSubviews: NSHashTable<NSView> = NSHashTable.weakObjects()

    private var isInsertingRenderedSubview: Bool = false

    // Audited for 6.5.4
    override dynamic open func didAddSubview(_ subview: NSView) {
        super.didAddSubview(subview)
        guard !isInsertingRenderedSubview else { return }
        foreignSubviews.add(subview)
        if isLinkedOnOrAfter(.v7) {
            let hostName = if viewController == nil {
                "NSHostingView"
            } else {
                "NSHostingController.view"
            }
            Log.runtimeIssues(
                "Adding '%s' as a subview of %s is not supported and may result in a broken view hierarchy. Add your view above %s in a common superview or insert it into your OpenSwiftUI content in a NSViewRepresentable instead.",
                [
                    "\(type(of: subview))",
                    hostName,
                    hostName,
                ]
            )
        }
    }

    // Audited for 6.5.4
    override dynamic open func willRemoveSubview(_ subview: NSView) {
        super.willRemoveSubview(subview)
        foreignSubviews.remove(subview)
    }

    private var sizeConstraints: SizeConstraints?

    private struct SizeConstraints {
        var minSizeConstraints: (width: NSLayoutConstraint, height: NSLayoutConstraint)?
        var maxSizeConstraints: (width: NSLayoutConstraint, height: NSLayoutConstraint)?
        var idealHeightConstraint: NSLayoutConstraint?
        var huggingIdealHeightConstraint: NSLayoutConstraint?

        mutating func deactivate() {
            if let min = minSizeConstraints {
                min.width.isActive = false
                min.height.isActive = false
            }
            if let max = maxSizeConstraints {
                max.width.isActive = false
                max.height.isActive = false
            }
            idealHeightConstraint?.isActive = false
            huggingIdealHeightConstraint?.isActive = false
        }

        mutating func update(from hostingView: NSHostingView) {
            let options = hostingView.sizingOptions

            if options.contains(.minSize) {
                let size = hostingView.minSize()
                if let existing = minSizeConstraints {
                    existing.width.constant = size.width
                    existing.width.isActive = true
                    existing.height.constant = size.height
                    existing.height.isActive = true
                } else {
                    let w = hostingView.widthAnchor.constraint(greaterThanOrEqualToConstant: size.width)
                    w.identifier = "NSHostingView.minWidth"
                    w.priority = .init(999)
                    w.isActive = true
                    let h = hostingView.heightAnchor.constraint(greaterThanOrEqualToConstant: size.height)
                    h.identifier = "NSHostingView.minHeight"
                    h.priority = .init(999)
                    h.isActive = true
                    minSizeConstraints = (w, h)
                }
            } else if let existing = minSizeConstraints {
                existing.width.isActive = false
                existing.height.isActive = false
                minSizeConstraints = nil
            }

            if options.contains(.maxSize) {
                let size = hostingView.maxSize()
                let widthFinite = size.width < 2777777.0 && !size.width.isInfinite
                let heightFinite = size.height < 2777777.0 && !size.height.isInfinite
                if let existing = maxSizeConstraints {
                    if widthFinite {
                        existing.width.constant = size.width
                    }
                    existing.width.isActive = widthFinite
                    if heightFinite {
                        existing.height.constant = size.height
                    }
                    existing.height.isActive = heightFinite
                } else {
                    let w = hostingView.widthAnchor.constraint(lessThanOrEqualToConstant: widthFinite ? size.width : 0)
                    w.identifier = "NSHostingView.maxWidth"
                    w.priority = .init(999)
                    w.isActive = widthFinite
                    let h = hostingView.heightAnchor.constraint(lessThanOrEqualToConstant: heightFinite ? size.height : 0)
                    h.identifier = "NSHostingView.maxHeight"
                    h.priority = .init(999)
                    h.isActive = heightFinite
                    maxSizeConstraints = (w, h)
                }
            } else if let existing = maxSizeConstraints {
                existing.width.isActive = false
                existing.height.isActive = false
                maxSizeConstraints = nil
            }
            // TODO
        }
    }

    weak var viewController: NSHostingController<Content>?

    var colorScheme: ColorScheme? = nil {
        didSet {}
    }

    public final func _viewDebugData() -> [_ViewDebug.Data] { [] }

    private func checkForReentrantLayout() -> Bool {
        if isPerformingLayout {
            Log.externalWarning("NSHostingView is being laid out reentrantly")
            return true
        }
        return false
    }

    private func updateWindowContentSizeExtremaIfNecessary() {
        guard let window, window.contentView === self else { return }

        var contentMinWidth: CGFloat = 0
        var contentMinHeight: CGFloat = 0
        if sizingOptions.contains(.minSize) {
            let size = minSize()
            let pixelLength = convertFromBacking(CGSize(width: 1, height: 1))
            contentMinWidth = size.width.rounded(.up, toMultipleOf: pixelLength.width)
            contentMinHeight = size.height.rounded(.up, toMultipleOf: pixelLength.height)
        }

        var contentMaxWidth: CGFloat = .greatestFiniteMagnitude
        var contentMaxHeight: CGFloat = .greatestFiniteMagnitude
        if sizingOptions.contains(.maxSize) {
            let size = maxSize()
            let pixelLength = convertFromBacking(CGSize(width: 1, height: 1))
            contentMaxWidth = size.width.rounded(.up, toMultipleOf: pixelLength.width)
            contentMaxHeight = size.height.rounded(.up, toMultipleOf: pixelLength.height)
        }

        contentMaxWidth.formMax(contentMinWidth)
        contentMaxHeight.formMax(contentMinHeight)

        let currentMin = window.contentMinSize
        let currentMax = window.contentMaxSize

        var changed = false
        if contentMinWidth != currentMin.width || contentMinHeight != currentMin.height {
            window.contentMinSize = CGSize(width: contentMinWidth, height: contentMinHeight)
            changed = true
        }
        if contentMaxWidth != currentMax.width || contentMaxHeight != currentMax.height {
            window.contentMaxSize = CGSize(width: contentMaxWidth, height: contentMaxHeight)
            changed = true
        }

        if changed {
            let contentRect = window.contentRect(forFrameRect: window.frame)
            var width = contentRect.width
            var height = contentRect.height

            width.formMin(window.contentMaxSize.width)
            width.formMax(window.contentMinSize.width)
            height.formMin(window.contentMaxSize.height)
            height.formMax(window.contentMinSize.height)

            if width != contentRect.width || height != contentRect.height {
                window.setContentSize(CGSize(width: width, height: height))
            }
        }
    }

    private func removeWindowContentSizeExtremaIfNecessary() {
        guard let window, window.contentView === self else { return }
        window.contentMinSize = .zero
        window.contentMaxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
    }

    private func invalidateSafeAreaInsets() {
        invalidateProperties(.safeArea)
    }

    private func minSize() -> CGSize {
        sizeForProposal(.zero)
    }

    private func maxSize() -> CGSize {
        sizeForProposal(.infinity)
    }

    private func sizeForProposal(_ proposal: _ProposedSize) -> CGSize {
        var size = sizeThatFits(proposal)
        let pixelLength = convertFromBacking(CGSize(width: 1, height: 1))
        size.width = size.width.rounded(.up, toMultipleOf: pixelLength.width)
        size.height = size.height.rounded(.up, toMultipleOf: pixelLength.height)
        return size
    }

    func clearUpdateTimer() {
        guard Thread.isMainThread else {
            return
        }
        updateTimer?.invalidate()
        updateTimer = nil
        nextTimerTime = nil
    }

    private func startAsyncRendering() -> Bool {
        if let displayLink {
            DisplayLinkSetNextTime(displayLink, .zero)
            return true
        }
        
        // TODO: screen.displayID
        let displayID = CGMainDisplayID()
         
        let link = DisplayLinkCreate(displayID) { [weak self] link, seconds in
            guard let self else { return }
            Update.locked {
                guard let displayLink = self.displayLink, displayLink == link else {
                    return
                }
                let targetTimestamp = Time(seconds: seconds)
                self.advanceTime(with: targetTimestamp)
                let nextRenderTime = self.renderAsync(targetTimestamp: nil)
                if let nextRenderTime {
                    if nextRenderTime.seconds.isFinite && !self.viewGraph.updateRequiredMainThread {
                        let interval = max(nextRenderTime - self.currentTimestamp, 1e-6)
                        DisplayLinkSetNextTime(link, interval + seconds)
                    } else {
                        DisplayLinkDestroy(link)
                        self.displayLink = nil

                        let targetTime: Time
                        if nextRenderTime.seconds.isFinite {
                            targetTime = Time(seconds: max(nextRenderTime - self.currentTimestamp, 1e-6))
                        } else {
                            targetTime = .zero
                        }
                        onNextMainRunLoop { [weak self] in
                            guard let self else { return }
                            requestUpdate(after: targetTime.seconds)
                        }
                    }
                    CATransaction.flush()
                } else {
                    DisplayLinkDestroy(link)
                    self.displayLink = nil
                    onNextMainRunLoop { [weak self] in
                        guard let self else { return }
                        requestUpdate(after: .zero)
                    }
                }
            }
        }
        displayLink = link
        if let displayLink {
            DisplayLinkSetNextTime(displayLink, .zero)
        }
        return displayLink != nil
    }

    func cancelAsyncRendering() {
        if let displayLink {
            DisplayLinkDestroy(displayLink)
            self.displayLink = nil
            setNeedsUpdate()
        }
    }

    package func advanceTime(with time: Time) {
        if lastUpdateTime.seconds == 0.0 || time < lastUpdateTime {
            lastUpdateTime = time
            return
        }

        let timeDelta = time.seconds - lastUpdateTime.seconds

        var timeScaleFactor = 1.0

        if NSEvent.modifierFlags.contains(.shift) {
            if UserDefaults.standard.bool(forKey: "NSAnimationSlowMotionOnShift") {
                timeScaleFactor = 10.0
            }
        }

        let scaledDelta = timeDelta / timeScaleFactor

        currentTimestamp = Time(seconds: currentTimestamp.seconds + scaledDelta)

        lastUpdateTime = time
    }

    package func makeViewDebugData() -> Data? {
        Update.ensure {
            _ViewDebug.serializedData(viewGraph.viewDebugData())
        }
    }

    func setUpdateTimer(delay: Double) {
        let delay = max(delay, 0.1)
        cancelAsyncRendering()
        let updateTime = currentTimestamp + delay
        guard updateTime < (nextTimerTime ?? .infinity) else {
            return
        }
        updateTimer?.invalidate()
        nextTimerTime = updateTime
        updateTimer = withDelay(delay) { [weak self] in
            guard let self else { return }
            updateTimer = nil
            nextTimerTime = nil
            setNeedsUpdate()
        }
    }

    static func defaultViewGraphOutputs() -> ViewGraph.Outputs { .defaults }

    func setNeedsUpdate() {
        if isUpdating {
            needsDeferredUpdate = true
        } else {
            needsUpdateConstraints = true
            needsLayout = true
        }
    }

    // MARK: - Window Notification Handlers

    @objc
    func windowDidChangeMain() {
        // TODO: update main window state
    }

    @objc
    func windowDidChangeKey() {
        // TODO: update key window state
        invalidateProperties(.environment)
    }

    @objc
    func windowDidChangeVisibility() {
        // TODO: update window visibility state
    }

    @objc
    func windowWillBeginSheet() {
        // TODO: handle sheet presentation
    }

    @objc
    func windowDidEndSheet() {
        // TODO: handle sheet dismissal
    }

    @objc
    func windowDidChangeScreen() {
        // TODO: handle screen change
    }

    #if OPENSWIFTUI_SWIFTUI_RENDERER
    @_implementationOnly
    override public func swiftui_addRenderedSubview(
        _ subview: Any,
        positioned place: Int,
        relativeTo otherView: Any?
    ) {
        openswiftui_addRenderedSubview(
            subview,
            positioned: place,
            relativeTo: otherView
        )
    }
    #endif

    @_implementationOnly
    override public func openswiftui_addRenderedSubview(
        _ subview: Any,
        positioned place: Int,
        relativeTo otherView: Any?
    ) {
        let view = subview as! NSView
        let place = NSWindow.OrderingMode(rawValue: place)!
        let otherView = otherView as! NSView?
        isInsertingRenderedSubview = true
        addSubview(view, positioned: place, relativeTo: otherView)
        isInsertingRenderedSubview = false
    }
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSHostingView {
    public func _renderForTest(interval: Double) {
        // FIXME: Copy from iOS version
        _openSwiftUIUnimplementedWarning()

        func shouldContinue() -> Bool {
            if propertiesNeedingUpdate == [], !CoreTesting.needsRender {
                false
            } else {
                times >= 0
            }
        }
        advanceTimeForTest(interval: interval)
        canAdvanceTimeAutomatically = false
        var times = 16
        repeat {
            times -= 1
            CoreTesting.needsRender = false
            updateGraph { host in
                host.flushTransactions()
            }
            RunLoop.flushObservers()
            render(targetTimestamp: nil)
            CATransaction.flush()
        } while shouldContinue()
        CoreTesting.needsRender = false
        canAdvanceTimeAutomatically = true
    }

    public func _renderAsyncForTest(interval: Double) -> Bool {
        advanceTimeForTest(interval: interval)
        canAdvanceTimeAutomatically = false
        var result = true
        repeat {
            RunLoop.flushObservers()
            let didRender = Update.locked {
                renderAsync(targetTimestamp: nil) != nil
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
        canAdvanceTimeAutomatically = true
        return result
    }
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSHostingView {
    func makeRootView() -> ModifiedContent<Content, HitTestBindingModifier> {
        NSHostingView.makeRootView(rootView)
    }

    func updateRemovedState() {
        var removedState: GraphHost.RemovedState = []
        if window == nil {
            removedState.insert(.unattached)
        }
        if isHiddenForReuse {
            removedState.insert(.hiddenForReuse)
            Update.locked {
                cancelAsyncRendering()
            }
        }
        Update.ensure {
            viewGraph.removedState = removedState
        }
    }
}

// MARK: - NSHostingView + HitTestingLeafPlatformView [6.5.4]

extension NSHostingView: HitTestingLeafPlatformView {
    var usesResponderForHitTesting: Bool {
        ResponderBasedHitTesting.isEnabled || !UnifiedHitTestingFeature.isEnabled
    }

    var foreignSubviewsForHitTesting: [PlatformView] {
        foreignSubviews.allObjects
    }

    var isTransparentForHitTesting: Bool {
        !UnifiedHitTestingFeature.isEnabled
    }

    func hitTest(_ point: PlatformPoint, cacheKey: UInt32?) -> PlatformView? {
        let result = defaultHitTest(point, radius: 1, cacheKey: cacheKey) {
            super.hitTest(point)
        }
        if !UnifiedHitTestingFeature.isEnabled, result === self, ignoreHitTest {
            return nil
        }
        return result
    }
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSHostingView: ViewRendererHost {
    // FIXME
    package func updateEnvironment() {
        var environment: EnvironmentValues
        if let inheritedEnvironment {
            environment = inheritedEnvironment
        } else if let initialInheritedEnvironment {
            environment = initialInheritedEnvironment
        } else {
            environment = EnvironmentValues()
            environment.configureForRoot()
        }
        if let environmentOverride {
            environment.plist.override(with: environmentOverride.plist)
        }
        focusBridge.updateEnvironment(&environment)
        viewGraph.setEnvironment(environment)
    }

    package func updateTransform() {
        if !viewGraph.invalidateTransform(), geometryChangeRegistrationPhase != .unregistered {
            geometryChangeObserver = nil
            geometryChangeRegistrationPhase = .unregistered
        }
    }

    package func updateSize() {
        viewGraph.setProposedSize(bounds.size)
    }

    package func updateSafeArea() {
        // TODO
    }

    package func updateContainerSize() {
        viewGraph.setContainerSize(ViewSize.fixed(bounds.size))
    }

    package func updateRootView() {
        let rootView = makeRootView()
        viewGraph.setRootView(rootView)
    }

    package func updateFocusedItem() {
        guard viewGraph.requestedOutputs.contains(.focus) else { return }
        viewGraph.setFocusedItem(focusedItem)
    }

    package func updateFocusedValues() {
        guard viewGraph.requestedOutputs.contains(.focus) else { return }
        viewGraph.setFocusedValues(focusedValues)
    }

    package func updateFocusStore() {
        guard viewGraph.requestedOutputs.contains(.focus) else { return }
        viewGraph.setFocusStore(focusBridge.focusStore)
    }

    @_spi(ForOpenSwiftUIOnly)
    public func preferencesDidChange() {
        focusBridge.preferencesDidChange(viewGraph.preferenceValues())
        // TODO: Notify the remaining preference bridges.
    }

    package func `as`<T>(_ type: T.Type) -> T? {
        if ViewGraphRenderDelegate.self == T.self {
            return unsafeBitCast(self as any ViewGraphRenderDelegate, to: T.self)
        } else if DisplayList.ViewRenderer.self == T.self {
            return unsafeBitCast(renderer, to: T.self)
        } else if EventGraphHost.self == T.self {
            return unsafeBitCast(self as any EventGraphHost, to: T.self)
        } else if RootTransformProvider.self == T.self {
            return unsafeBitCast(self as any RootTransformProvider, to: T.self)
        } else if (any FocusHost).self == T.self {
            return unsafeBitCast(self as any FocusHost, to: T.self)
        } else {
            return nil
        }
    }

    package func requestUpdate(after delay: Double) {
        if Thread.isMainThread {
            Update.locked {
                cancelAsyncRendering()
            }

            var adjustedDelay = delay

            if NSEvent.modifierFlags.contains(.shift),
               UserDefaults.standard.bool(forKey: "NSAnimationSlowMotionOnShift") {
                adjustedDelay *= 10.0
            }

            if adjustedDelay >= 0.25 {
                setUpdateTimer(delay: adjustedDelay)
            } else if adjustedDelay == 0 || !isUpdating {
                setNeedsUpdate()
            } else {
                onNextMainRunLoop { [weak self] in
                    guard let self else { return }
                    setNeedsUpdate()
                }
            }

            // TODO: Notify delegate
        } else {
            onNextMainRunLoop { [weak self] in
                guard let self else { return }
                requestUpdate(after: delay)
            }
        }
    }
}

// MARK: - NSHostingView + RootTransformProvider [6.5.4]

extension NSHostingView: RootTransformProvider {
    package func rootTransform() -> ViewTransform {
        if geometryChangeRegistrationPhase == .unregistered {
            geometryChangeRegistrationPhase = .registering
            geometryChangeObserver = _observerForChangesInGeometry { view in
                (view as! Self).geometryInWindowDidChange()
            }
            geometryChangeRegistrationPhase = .registered
        }
        guard window != nil else {
            return ViewTransform()
        }

        var buffer = ViewTransform.UnsafeBuffer()
        let usesRootGeometry = _SemanticFeature_v6.isEnabled
        if !usesRootGeometry {
            buffer.appendCoordinateSpace(id: hostingViewCoordinateSpace)
        }
        var origin = convert(CGPoint.zero, to: nil)
        if _SemanticFeature_v3.isEnabled {
            if _SemanticFeature_v3.isEnabled {
                origin.y = (window?.frame.height ?? 0) - origin.y
            }
            buffer.appendTranslation(CGSize(width: -origin.x, height: -origin.y))
        } else {
            buffer.appendAffineTransform(
                CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: -origin.x, ty: origin.y),
                inverse: false
            )
        }
        if usesRootGeometry {
            buffer.appendScrollGeometry(
                .rootViewTransform(contentOffset: .zero, containerSize: convert(bounds, to: nil).size),
                isClipped: true
            )
            buffer.appendScrollGeometry(
                .rootViewTransform(contentOffset: .zero, containerSize: bounds.size),
                isClipped: clipsToBounds
            )
            buffer.appendCoordinateSpace(id: hostingViewCoordinateSpace)
        } else {
            _ = clipsToBounds
        }
        var transform = ViewTransform()
        transform.append(movingContentsOf: &buffer)
        return transform
    }
}

private enum HostingViewGeometryRegistrationPhase: Hashable {
    case unregistered
    case registering
    case registered
}

private weak var lastInterceptedKeyEvent: NSEvent?

@_spi(Private)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSHostingView: HostingViewProtocol {
    public func convertAnchor<Value>(_ anchor: Anchor<Value>) -> Value {
        anchor.convert(to: viewGraph.transform)
    }
}

extension NSHostingView/*: TestHost*/ {
    final package func forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {
        let tree = preferenceValue(_IdentifiedViewsKey.self)
        let adjustment = { [weak self](rect: inout CGRect) in
            guard let self else { return }
            rect = convert(rect, from: nil)
        }
        tree.forEach { proxy in
            var proxy = proxy
            proxy.adjustment = adjustment
            body(proxy)
        }
    }
}

// MARK: - NSHostingView + EventGraphHost [TBA]

extension NSHostingView: EventGraphHost {
    package var focusedResponder: ResponderNode? {
        focusBridge.focusedItem?.responder
    }
}

// MARK: - NSHostingView + FocusHost [TBA]

extension NSHostingView: FocusHost, FocusBridgeProvider {
    var focusedItem: FocusItem? {
        focusBridge.focusedItem
    }

    func focus(item: FocusItem) {
        focusBridge.moveFocus(to: item, designatedPlatformResponder: nil)
    }

    func focusDidChange() {
        guard let firstResponder = window?.firstResponder else { return }
        focusBridge.firstResponderDidChange(to: firstResponder, rootResponder: responderNode)
    }
}

// MARK: - NSHostingView + EventBindingManagerDelegate [TBA]

extension NSHostingView: EventBindingManagerDelegate {
    package func didBind(to newBinding: EventBinding, id: EventID) {
        guard !GestureRecognizerBasedEvents.isEnabled else { return }
        didBind(to: newBinding)
    }

    package func didUpdate(phase: GesturePhase<Void>, in eventBindingManager: EventBindingManager) {
        guard !GestureRecognizerBasedEvents.isEnabled else { return }
        switch phase {
        case .ended, .failed:
            // TODO: Reset the legacy mouse and hover event state.
            _openSwiftUIUnimplementedWarning()
        default:
            break
        }
    }

    package func requestHoverUpdate(in eventBindingManager: EventBindingManager) {
        guard !GestureRecognizerBasedEvents.isEnabled else { return }
        didRequestHoverUpdate()
    }
}

// FIXME
extension NSHostingView: ViewGraphRenderDelegate {
    package var renderingRootView: AnyObject {
        self
    }
    
    package func updateRenderContext(_ context: inout ViewGraphRenderContext) {
        context.contentsScale = window?.backingScaleFactor ?? 1.0
    }
    
    package func withMainThreadRender(wasAsync: Bool, _ body: () -> Time) -> Time {
        // TODO
        return body()
    }
}

#endif
