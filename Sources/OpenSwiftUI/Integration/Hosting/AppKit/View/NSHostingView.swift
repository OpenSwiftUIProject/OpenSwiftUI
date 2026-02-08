//
//  NSHostingView.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: WIP

#if os(macOS)
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
public import OpenSwiftUICore
public import AppKit
import OpenSwiftUI_SPI
import COpenSwiftUI

/// An AppKit view that hosts a SwiftUI view hierarchy.
///
/// You use `NSHostingView` objects to integrate SwiftUI views into your
/// AppKit view hierarchies. A hosting view is an
/// [NSView](https://developer.apple.com/documentation/AppKit/NSView) object that manages a single
/// SwiftUI view, which may itself contain other SwiftUI views. Because it is an
/// [NSView](https://developer.apple.com/documentation/AppKit/NSView) object, you can integrate it
/// into your existing AppKit view hierarchies to implement portions of your UI.
/// For example, you can use a hosting view to implement a custom control.
///
/// A hosting view acts as a bridge between your SwiftUI views and your AppKit
/// interface. During layout, the hosting view reports the content size
/// preferences of your SwiftUI views back to the AppKit layout system so that
/// it can size the view appropriately. The hosting view also coordinates event
/// delivery.
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
open class NSHostingView<Content>: NSView, XcodeViewDebugDataProvider where Content: View {
    /// The options for how the hosting view creates and updates constraints
    /// based on the size of its SwiftUI content.
    ///
    /// NSHostingView can create minimum, maximum, and ideal (content size)
    /// constraints that are derived from its SwiftUI view content. These
    /// constraints are only created when Auto Layout constraints are otherwise
    /// being used in the containing window.
    ///
    /// If the NSHostingView is set as the `contentView` of an `NSWindow`, it
    /// will also update the window's `contentMinSize` and `contentMaxSize`
    /// based on the minimum and maximum size of its SwiftUI content.
    ///
    /// `sizingOptions` defaults to `.standardBounds` (which includes
    /// `minSize`, `intrinsicContentSize`, and `maxSize`), but can be set to an
    /// explicit value to control this behavior. For instance, setting a value
    /// of `.minSize` will only create the constraints necessary to maintain the
    /// minimum size of the SwiftUI content, or setting a value of `[]` will
    /// create no constraints at all.
    ///
    /// If a use case can make assumptions about the size of the `NSHostingView`
    /// relative to its displayed content, such as the always being displayed in
    /// a fixed frame, setting this to a value with fewer options can improve
    /// performance as it reduces the amount of layout measurements that need to
    /// be performed. If an `NSHostingView` has a `frame` that is smaller or
    /// larger than that required to display its SwiftUI content, the content
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

    /// Creates a hosting view object that wraps the specified SwiftUI view.
    ///
    /// - Parameter rootView: The root view of the SwiftUI view hierarchy that
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
        initializeViewGraph()
        // TODO
        clipsToBounds = false
        // TODO
        wantsLayer = true
        // TODO
        renderer.host = self
        HostingViewRegistry.shared.add(self)
        // TODO
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
            // TODO: FirstResponderObserver KVO setup
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
        }
        updateRemovedState()
        // TODO: initialInheritedEnvironment / inferredGraphTraits
        super.viewDidMoveToWindow()
        Update.end()
    }

    open override func prepareForReuse() {
        // TODO
    }

    open override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        if key == "safeAreaInsets" {
            invalidateSafeAreaInsets()
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
            isUpdating = true
            // TODO
            render(targetTimestamp: nil)
            // TODO
            isUpdating = false
            // TODO
            if needsDeferredUpdate {
                if !viewGraph.updateRequiredMainThread {
                    if isLinkedOnOrAfter(.v3) {
                        if startAsyncRendering() {
                            needsDeferredUpdate = false
                        }
                    }
                }
            }
            if needsDeferredUpdate {
                onNextMainRunLoop { [weak self] in
                    guard let self else { return }
                    setNeedsUpdate()
                }
                needsDeferredUpdate = false
            }
        }
    }

    func setRootView(_ view: Content, transaction: Transaction) {
        _rootView = view
        viewGraph.asyncTransaction(transaction) { [weak self] in
            guard let self else { return }
            updateRootView()
        }
    }

    /// The root view of the SwiftUI view hierarchy managed by this view
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

    private lazy var foreignSubviews: NSHashTable<NSView>? = NSHashTable.weakObjects()

    private var isInsertingRenderedSubview: Bool = false

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

        contentMaxWidth = Swift.max(contentMaxWidth, contentMinWidth)
        contentMaxHeight = Swift.max(contentMaxHeight, contentMinHeight)

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

            width = Swift.min(width, window.contentMaxSize.width)
            width = Swift.max(width, window.contentMinSize.width)
            height = Swift.min(height, window.contentMaxSize.height)
            height = Swift.max(height, window.contentMinSize.height)

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
        needsUpdateConstraints = true
        needsLayout = true
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

    @objc(swiftui_addRenderedSubview:positioned:relativeTo:) // FIXME: ViewUpdater -> AppKitAddSubview
    private func openswiftui_addRenderedSubview(_ view: NSView, positioned place: NSWindow.OrderingMode, relativeTo otherView: NSView?) {
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
        _openSwiftUIUnimplementedWarning()
        return false
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

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSHostingView: ViewRendererHost {
    package func updateEnvironment() {
        var environment: EnvironmentValues
        if let inheritedEnvironment {
            environment = inheritedEnvironment
        } else if let initialInheritedEnvironment {
            environment = initialInheritedEnvironment
        } else {
            environment = EnvironmentValues()
        }
        if let environmentOverride {
            environment.plist.override(with: environmentOverride.plist)
        }
        viewGraph.setEnvironment(environment)
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

    package func `as`<T>(_ type: T.Type) -> T? {
        if ViewGraphRenderDelegate.self == T.self {
            return unsafeBitCast(self as any ViewGraphRenderDelegate, to: T.self)
        } else if DisplayList.ViewRenderer.self == T.self {
            return unsafeBitCast(renderer, to: T.self)
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
            } else if isUpdating {
                needsDeferredUpdate = true
            } else {
                setNeedsUpdate()
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
