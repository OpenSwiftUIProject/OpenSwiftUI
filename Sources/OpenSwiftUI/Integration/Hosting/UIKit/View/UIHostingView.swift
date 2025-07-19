//
//  UIHostingView.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: FAF0B683EB49BE9BABC9009857940A1E (SwiftUI)

#if os(iOS)
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
public import OpenSwiftUICore
public import UIKit
import OpenSwiftUI_SPI

import OpenSwiftUISymbolDualTestsSupport

/// A UIView which hosts an OpenSwiftUI View hierarchy.
@available(macOS, unavailable)
open class _UIHostingView<Content>: UIView, XcodeViewDebugDataProvider where Content: View {
    override dynamic open class var layerClass: AnyClass {
        UIHostingViewDebugLayer.self
    }
    
    private var _rootView: Content

//    private let _base: UIHostingViewBase

    var base: UIHostingViewBase {
        _openSwiftUIUnimplementedFailure()
    }

    final package let viewGraph: ViewGraph
    
    final package let renderer = DisplayList.ViewRenderer(platform: .init(definition: UIViewPlatformViewDefinition.self))

    // final package let eventBindingManager: EventBindingManager
    
    package var currentTimestamp: Time = .zero

    package var propertiesNeedingUpdate: ViewRendererHostProperties = .all
    
    package var renderingPhase: ViewRenderingPhase = .none
    
    package var externalUpdateCount: Int = .zero
    
    var parentPhase: _GraphInputs.Phase? = nil

    var isRotatingWindow: Bool = false
    
    var allowUIKitAnimations: Int32 = .zero
    
    var allowUIKitAnimationsForNextUpdate: Bool = false
    
    var disabledBackgroundColor: Bool = false
    
    var allowFrameChanges: Bool = true
    
    private var transparentBackgroundReasons: HostingViewTransparentBackgroundReason = [] {
        didSet {
            let oldHadReasons = oldValue != []
            let newHasReasons = transparentBackgroundReasons != []
            if oldHadReasons == newHasReasons {
                updateBackgroundColor()
            }
        }
    }
    
    var explicitSafeAreaInsets: EdgeInsets? = nil {
        didSet {
            safeAreaInsetsDidChange()
        }
    }
    
    var keyboardFrame: CGRect? = nil
    
    var keyboardSeed: UInt32 = .zero
    
    // var keyboardTrackingElement: UIHostingKeyboardTrackingElement? = nil
    
    package var isHiddenForReuse: Bool = false {
        didSet {
            updateRemovedState()
        }
    }
    
    var registeredForGeometryChanges: Bool = false
    
    @_spi(Private)
    public var safeAreaRegions: SafeAreaRegions = .all {
        didSet {
            safeAreaRegionsDidChange(from: oldValue)
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
    
    var traitCollectionOverride: UITraitCollection? = nil {
        didSet {
            guard traitCollectionOverride != oldValue else {
                return
            }
            invalidateProperties(.environment)
        }
    }
    
    weak var viewController: UIHostingController<Content>? = nil {
        didSet {
            updateBackgroundColor()
        }
    }
    
    var currentEvent: UIEvent? = nil
    
    // var eventBridge: UIKitEventBindingBridge
    
    var displayLink: DisplayLink? = nil
    
    var lastRenderTime: Time = .zero

    var canAdvanceTimeAutomatically = true
    
    var pendingPreferencesUpdate: Bool = false
    
    var pendingPostDisappearPreferencesUpdate: Bool = false
    
    var nextTimerTime: Time? = nil

    var updateTimer: Timer? = nil
    
    var colorScheme: ColorScheme? = nil {
        didSet {
            didChangeColorScheme(from: oldValue)
        }
    }
    
    // TODO
    
    var focusedValues: FocusedValues = .init() {
        didSet {
            invalidateProperties(.focusedValues)
        }
    }
    
    // var currentAccessibilityFocusStore: AccessibilityFocusStore = .init()
    
    private weak var observedWindow: UIWindow? = nil
    
    private weak var observedScene: UIWindowScene? = nil
    
    private var _sceneActivationState: UIScene.ActivationState? = nil
    
    var sceneActivationState: UIScene.ActivationState? {
        get {
            let selector = Selector(("_windowHostingScene"))
            guard let window,
                  window.responds(to: selector),
                  (window.perform(selector).takeRetainedValue() as? UIWindowScene) != nil else {
                return nil
            }
            return _sceneActivationState
        }
        set {
            _sceneActivationState = newValue
        }
    }
    
    var isEnteringForeground: Bool = false
    
    var isExitingForeground: Bool = false
    
    var isCapturingSnapshots: Bool = false
    
    var updatesWillBeVisible: Bool {
        guard let sceneActivationState else {
            return false
        }
        guard !isHiddenForReuse else {
            return false
        }
        return switch sceneActivationState {
            case .foregroundActive, .foregroundInactive: true
            default: isEnteringForeground || isCapturingSnapshots
        }
    }
    
    package var accessibilityEnabled: Bool {
        get {
            viewGraph.accessibilityEnabled
        }
        set {
            let oldValue = viewGraph.accessibilityEnabled
            viewGraph.accessibilityEnabled = newValue
            guard oldValue != newValue else {
                return
            }
            invalidateProperties(.environment)
            // AccessibilityFocus.changed(from: nil, to: nil, within: self)
        }
    }
    
    required public init(rootView: Content) {
        _rootView = rootView
        Update.begin()
        viewGraph = ViewGraph(
            rootViewType: ModifiedContent<ModifiedContent<Content, EditModeScopeModifier>, HitTestBindingModifier>.self,
            requestedOutputs: Self.defaultViewGraphOutputs()
        )
        // TODO
        super.init(frame: .zero)
        // TODO

        if _UIUpdateAdaptiveRateNeeded() {
            viewGraph.append(feature: EnableVFDFeature())
        }

        initializeViewGraph()
        // RepresentableContextValues.current =

        renderer.host = self

        // TODO
        HostingViewRegistry.shared.add(self)
        Update.end()
        // TODO
    }
    
    @available(*, unavailable)
    required dynamic public init?(coder _: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    deinit {
        updateRemovedState()
        NotificationCenter.default.removeObserver(self)
        clearDisplayLink()
        clearUpdateTimer()
        invalidate()
        Update.ensure {
            viewGraph.preferenceBridge = nil
            viewGraph.invalidate()
        }
        HostingViewRegistry.shared.remove(self)
    }
    
    /// The renderer configuration of the hosting view.
    final public var _rendererConfiguration: _RendererConfiguration {
        get {
            Update.locked { renderer.configuration }
        }
        set {
            Update.locked { renderer.configuration = newValue }
        }
    }
    
    /// An optional object representing the current renderer.
    final public var _rendererObject: AnyObject? {
        Update.locked {
            renderer.exportedObject(rootView: self)
        }
    }
    
    override dynamic open func didMoveToWindow() {
        Update.begin()
        if window != nil {
            traitCollectionOverride = nil
            initialInheritedEnvironment = nil
            invalidateProperties(.transform)
        }
        // updateKeyboardAvoidance()
        // eventBridge.hostingView(self, didMoveToWindow: window)
        // TODO: rootViewDelegate
        base.didMoveToWindow()
        // TODO
        Update.end()
    }

    override dynamic open func layoutSubviews() {
        super.layoutSubviews()
        base.layoutSubviews()
    }

    override dynamic open var frame: CGRect {
        get {
            super.frame
        }
        set {
            guard allowFrameChanges else {
                return
            }
            let oldValue = super.frame
            super.frame = newValue
            frameDidChange(oldValue: oldValue)
        }
    }

    open override var bounds: CGRect {
        get {
            super.bounds
        }
        set {
            guard allowFrameChanges else {
                return
            }
            let oldValue = super.bounds
            super.bounds = newValue
            frameDidChange(oldValue: oldValue)
        }
    }

    // TODO
    
    func setRootView(_ view: Content, transaction: Transaction) {
        _rootView = view
        viewGraph.asyncTransaction(transaction) { [weak self] in
            guard let self else { return }
            updateRootView()
        }
    }
    
    /// The root View of the view hierarchy to display.
    var rootView: Content {
        get { _rootView }
        set {
            _rootView = newValue
            invalidateProperties(.rootView)
        }
    }
    
    var invalidatesIntrinsicContentSizeOnIdealSizeChange: Bool = false {
        didSet {
            // TODO
        }
    }
    
    private lazy var foreignSubviews: NSHashTable<UIView>? = NSHashTable.weakObjects()

    private var isInsertingRenderedSubview: Bool = false
    
    /// The UIKit notion of the safe area insets.
    open override var safeAreaInsets: UIEdgeInsets {
        guard let explicitSafeAreaInsets else {
            return super.safeAreaInsets
        }
        let layoutDirection = Update.ensure { viewGraph.environment.layoutDirection }
        return if layoutDirection == .rightToLeft {
            UIEdgeInsets(top: explicitSafeAreaInsets.top, left: explicitSafeAreaInsets.trailing, bottom: explicitSafeAreaInsets.bottom, right: explicitSafeAreaInsets.leading)
        } else {
            UIEdgeInsets(top: explicitSafeAreaInsets.top, left: explicitSafeAreaInsets.leading, bottom: explicitSafeAreaInsets.bottom, right: explicitSafeAreaInsets.trailing)
        }
    }
    
    // FIXME
    final public func _viewDebugData() -> [_ViewDebug.Data] {
        // TODO
        []
    }
    
    // FIXME
    func cancelAsyncRendering() {
        Update.locked {
            displayLink?.cancelAsyncRendering()
        }
    }
    
    // FIXME
    private func renderInterval(timestamp: Time) -> Double {
        if lastRenderTime == .zero || lastRenderTime > timestamp {
            lastRenderTime = timestamp - 1e-6
        }
        let interval = timestamp - lastRenderTime
        lastRenderTime = timestamp
        return interval
    }
    
    // TODO
    func clearDisplayLink() {
    }
    
    // TODO
    func clearUpdateTimer() {
    }
    
    @_spi(Private)
    @available(iOS, deprecated, message: "Use UIHostingController/safeAreaRegions or _UIHostingView/safeAreaRegions")
    final public var addsKeyboardToSafeAreaInsets: Bool {
        get { safeAreaRegions.contains(.keyboard) }
        set { safeAreaRegions.setValue(newValue, for: .keyboard) }
    }
    
    package func makeViewDebugData() -> Data? {
        Update.ensure {
            _ViewDebug.serializedData(viewGraph.viewDebugData())
        }
    }
    
    static func defaultViewGraphOutputs() -> ViewGraph.Outputs { .defaults }

    // Audited for 6.5.4
    private struct EnableVFDFeature: ViewGraphFeature {
        func modifyViewInputs(inputs: inout _ViewInputs, graph: ViewGraph) {
            inputs.base.options.insert(.supportsVariableFrameDuration)
        }
    }
}

extension _UIHostingView {
    var hostSafeAreaElements: [SafeAreaInsets.Element] {
        _hostSafeAreaElements
    }

    var _hostSafeAreaElements: [SafeAreaInsets.Element] {
        let pixelLength = viewGraph.environment.pixelLength
        let uiSafeAreaInsets = safeAreaInsets
        var safeAreaEdgeInsets = EdgeInsets(
            top: uiSafeAreaInsets.top,
            leading: uiSafeAreaInsets.left,
            bottom: uiSafeAreaInsets.bottom,
            trailing: uiSafeAreaInsets.right
        )
        safeAreaEdgeInsets.xFlipIfRightToLeft { .leftToRight }
        safeAreaEdgeInsets.round(toMultipleOf: pixelLength)
        var containerElement = SafeAreaInsets.Element(regions: .container, insets: .zero)
        if safeAreaRegions.contains(.container) {
            containerElement.insets = safeAreaEdgeInsets
        }
        let bottomInset: Double
        if safeAreaRegions.contains(.keyboard),
           let keyboardFrame,
           let window,
           keyboardFrame.size.isNonEmpty {
            let convertedKeyboardFrame = convert(keyboardFrame, from: window.screen.coordinateSpace)
            bottomInset = convertedKeyboardFrame.minY - bounds.maxY
        } else {
            bottomInset = 0.0
        }
        var keyboardElement = SafeAreaInsets.Element(regions: .keyboard, insets: .zero)
        if safeAreaRegions.contains(.keyboard) {
            var value = bottomInset - safeAreaEdgeInsets.bottom
            value.round(toMultipleOf: pixelLength)
            keyboardElement.insets = EdgeInsets(value, edges: .bottom)
        }

        if keyboardElement.insets.bottom < 0 {
            containerElement.insets.bottom = -keyboardElement.insets.bottom
            keyboardElement.insets.bottom = bottomInset
            keyboardElement.regions.formUnion(containerElement.regions)
        }

        var elements: [SafeAreaInsets.Element] = []
        if !containerElement.insets.isEmpty {
            elements.append(containerElement)
        }
        if !keyboardElement.insets.isEmpty {
            elements.append(keyboardElement)
        }
        return elements
    }

    func makeRootView() -> ModifiedContent<ModifiedContent<Content, EditModeScopeModifier>, HitTestBindingModifier> {
        _UIHostingView.makeRootView(
            rootView.modifier(EditModeScopeModifier(isActive: viewController != nil))
        )
    }
    
    var wantsTransparentBackground: Bool {
        transparentBackgroundReasons != []
    }
    
    func setWantsTransparentBackground(for reason: HostingViewTransparentBackgroundReason, _ isEnabled: Bool) {
        transparentBackgroundReasons.setValue(isEnabled, for: reason)
    }
    
    func updateRemovedState() {
        var removedState: GraphHost.RemovedState = []
        if window == nil {
            removedState.insert(.unattached)
        }
        if isHiddenForReuse {
            removedState.insert(.hiddenForReuse)
            clearDisplayLink()
        }
        Update.ensure {
            viewGraph.removedState = removedState
        }
    }
    
    func safeAreaRegionsDidChange(from oldSafeAreaRegions: SafeAreaRegions) {
        guard safeAreaRegions != oldSafeAreaRegions else {
            return
        }
        invalidateProperties([.safeArea, .scrollableContainerSize])
    }
    
    func updateBackgroundColor() {
        func setBackground(_ color: UIColor?) {
            guard !disabledBackgroundColor else {
                return
            }
            super.backgroundColor = color
        }
        guard viewController != nil else {
            return
        }
        if wantsTransparentBackground {
            super.backgroundColor = nil
        } else {
            setBackground(.systemBackground)
        }
    }
    
    func didChangeColorScheme(from oldColorScheme: ColorScheme?) {
        // TODO
    }
    
    private func frameDidChange(oldValue: CGRect) {
        // TODO
    }
}

extension _UIHostingView: ViewRendererHost {
    package func updateEnvironment() {

        // FIXME
        var environment = EnvironmentValues()
        environment.displayScale = traitCollection.displayScale
        if let displayGamut = DisplayGamut(rawValue: traitCollection.displayGamut.rawValue) {
            environment.displayGamut = displayGamut
        }
        viewGraph.setEnvironment(environment)
    }
    
    package func updateSize() {
        viewGraph.setProposedSize(bounds.size)
    }
    
    package func updateSafeArea() {
        let changed = viewGraph.setSafeAreaInsets(hostSafeAreaElements)
        if changed {
            invalidateIntrinsicContentSize()
        }
    }

    package func updateScrollableContainerSize() {
        // _openSwiftUIUnimplementedFailure()
    }

    var shouldDisableUIKitAnimations: Bool {
        // FIXME
        false
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
        func render() -> Time {
            let scale = window?.screen.scale ?? 1
            let environment = DisplayList.ViewRenderer.Environment(contentsScale: scale)
            #if canImport(SwiftUI, _underlyingVersion: 6.0.87) && _OPENSWIFTUI_SWIFTUI_RENDER
            return renderer.swiftUI_render(
                rootView: self,
                from: list,
                time: time,
                nextTime: nextTime,
                version: version,
                maxVersion: maxVersion,
                environment: environment
            )
            #else
            return renderer.render(
                rootView: self,
                from: list,
                time: time,
                nextTime: nextTime,
                version: version,
                maxVersion: maxVersion,
                environment: environment
            )
            #endif
        }

        if asynchronously {
            if let renderedTime = renderer.renderAsync(
                to: list,
                time: time,
                nextTime: nextTime,
                targetTimestamp: targetTimestamp,
                version: version,
                maxVersion: maxVersion
            ) {
                return renderedTime
            } else {
                var renderedTime = nextTime
                Update.syncMain {
                    renderedTime = render()
                }
                return renderedTime
            }
        } else {
            if Self.areAnimationsEnabled, shouldDisableUIKitAnimations {
                var renderedTime = nextTime // FIXME
                Self.performWithoutAnimation {
                    renderedTime = render()
                }
                allowUIKitAnimationsForNextUpdate = false
                return renderedTime
            } else {
                let renderedTime = render()
                allowUIKitAnimationsForNextUpdate = false
                return renderedTime
            }
        }
    }
    
    package func updateRootView() {
        let rootView = makeRootView()
        viewGraph.setRootView(rootView)
    }
    
    package func requestUpdate(after: Double) {
        // TODO
        requestImmediateUpdate()
    }

    func requestImmediateUpdate() {
        // FIXME
        setNeedsLayout()
    }

    package func outputsDidChange(outputs: ViewGraph.Outputs) {
        // TODO
    }
    
    package func focusDidChange() {
        // TODO
    }
    
    package func rootTransform() -> ViewTransform {
        _openSwiftUIUnimplementedWarning()
        return ViewTransform()
    }

    public func preferencesDidChange() {
        // TODO
    }
}

@_spi(Private)
extension _UIHostingView: HostingViewProtocol {
    public func convertAnchor<Value>(_ anchor: Anchor<Value>) -> Value {
        anchor.convert(to: viewGraph.transform)
    }
}

// MARK: - _UIHostingView + TestHost [6.4.41]

extension _UIHostingView: TestHost {
    package func setTestSize(_ size: CGSize) {
        let newSize: CGSize
        if size == CGSize.deviceSize {
            let screenSize = UIDevice.current.screenSize
            let idiom = UIDevice.current.userInterfaceIdiom
            if idiom == .pad, screenSize.width < screenSize.height {
                newSize = CGSize(width: screenSize.height, height: screenSize.width)
            } else {
                if idiom == .phone, screenSize.height < screenSize.width {
                    newSize = CGSize(width: screenSize.height, height: screenSize.width)
                } else {
                    newSize = screenSize
                }
            }
        } else {
            newSize = size
        }
        if bounds.size != newSize {
            allowFrameChanges = true
            bounds.size = newSize
            allowFrameChanges = false
        }
    }

    package func setTestSafeAreaInsets(_ insets: EdgeInsets) {
        explicitSafeAreaInsets = insets

    }

    package var testSize: CGSize { bounds.size }

    package var viewCacheIsEmpty: Bool {
        Update.locked {
            renderer.viewCacheIsEmpty
        }
    }

    package func forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {
        let tree = preferenceValue(_IdentifiedViewsKey.self)
        tree.forEach { proxy in
            var proxy = proxy
            proxy.adjustment = { [weak self] rect in
                guard let self else { return }
                rect = convert(rect, from: nil)
            }
            body(proxy)
        }
    }

    package func forEachDescendantHost(body: (any TestHost) -> Void) {
        forEachDescendantHost { (view: UIView) in
            if let testHost = view as? any TestHost {
                body(testHost)
            }
        }
    }

    package func renderForTest(interval: Double) {
        _renderForTest(interval: interval)
    }

    package var attributeCountInfo: AttributeCountTestInfo {
        preferenceValue(AttributeCountInfoKey.self)
    }

    public func _renderForTest(interval: Double) {
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
}

extension UIDevice {
    package var screenSize: CGSize {
        let screenBounds = UIScreen.main.bounds
        let screenWidth = screenBounds.width
        let screenHeight = screenBounds.height
        let orientation = UIDevice.current.orientation
        let finalWidth: CGFloat
        let finalHeight: CGFloat
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            // In landscape, swap dimensions to ensure width > height
            finalWidth = max(screenWidth, screenHeight)
            finalHeight = min(screenWidth, screenHeight)
        case .portrait, .portraitUpsideDown:
            // In portrait, keep original dimensions (height > width)
            finalWidth = screenWidth
            finalHeight = screenHeight
        default:
            // For other orientations, keep original dimensions
            finalWidth = screenWidth
            finalHeight = screenHeight
        }
        return CGSize(width: finalWidth, height: finalHeight)
    }
}

extension UIView {
    func forEachDescendantHost(body: (UIView) -> Void) {
        body(self)
        for view in subviews {
            view.forEachDescendantHost(body: body)
        }
    }
}

#endif
