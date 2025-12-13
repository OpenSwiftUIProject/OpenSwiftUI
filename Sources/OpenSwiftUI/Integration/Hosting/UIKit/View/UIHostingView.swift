//
//  UIHostingView.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: WIP
//  ID: FAF0B683EB49BE9BABC9009857940A1E (SwiftUI)

#if os(iOS) || os(visionOS)
public import UIKit
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
public import OpenSwiftUICore
import OpenSwiftUISymbolDualTestsSupport
import COpenSwiftUI

/// A UIView which hosts an OpenSwiftUI View hierarchy.
@available(macOS, unavailable)
open class _UIHostingView<Content>: UIView, XcodeViewDebugDataProvider where Content: View {
    override dynamic open class var layerClass: AnyClass {
        UIHostingViewDebugLayer.self
    }
    
    private var _rootView: Content

    private let _base: UIHostingViewBase

    var base: UIHostingViewBase {
        let base = _base
        if base.uiView == nil {
            base.uiView = self
        }
        if base.host == nil {
            base.host = self
        }
        if base.delegate == nil {
            base.delegate = self
        }
        if base.renderer.host == nil {
            base.renderer.host = self
        }
        return base
    }

    final package var viewGraph: ViewGraph { _base.viewGraph }

    final package let renderer = DisplayList.ViewRenderer(platform: .init(definition: UIViewPlatformViewDefinition.self))

    // final package let eventBindingManager: EventBindingManager
    
    package var currentTimestamp: Time = .zero

    package var propertiesNeedingUpdate: ViewRendererHostProperties = .all

    var allowUIKitAnimations: Int32 = .zero

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
    
    package var isHiddenForReuse: Bool {
        get { _base.isHiddenForReuse }
        set { _base.isHiddenForReuse = true }
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
    
    weak var viewController: UIHostingController<Content>? = nil {
        didSet {
            updateBackgroundColor()
        }
    }
    
    var currentEvent: UIEvent? = nil
    
    // var eventBridge: UIKitEventBindingBridge

    var colorScheme: ColorScheme? = nil {
        didSet {
            didChangeColorScheme(from: oldValue)
        }
    }

    // TODO

    let feedbackCache: UIKitSensoryFeedbackCache<Content> = .init()

    // TODO
    
    // var currentAccessibilityFocusStore: AccessibilityFocusStore = .init()
    
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

    // private weak var delegate: UIHostingViewDelegate?

    required public init(rootView: Content) {
        _rootView = rootView
        Update.begin()
        var options = Self.defaultViewGraphOutputs().options
        if Self.requiresExplicitGeometryChangedRegistration {
            options.formUnion(.registeredForGeometryChanges)
        }
        _base = UIHostingViewBase(
            rootViewType: ModifiedContent<
                ModifiedContent<
                    Content,
                    EditModeScopeModifier
                >,
                HitTestBindingModifier
            >.self,
            options: options
        )
        // TODO
        if _UIUpdateAdaptiveRateNeeded() {
            _base.viewGraph.append(feature: EnableVFDFeature())
        }
        // TODO
        super.init(frame: .zero)
        _base.viewGraph.append(feature: HostViewGraph(host: self))
        // TODO
        let base = base
        if let host = base.host {
            host.initializeViewGraph()
            base.setupNotifications()
        }
        // RepresentableContextValues.current =
        feedbackCache.host = self
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
        _base.tearDown(uiView: self, host: self)
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
        // TODO:
        // updateKeyboardAvoidance()
        // eventBridge.hostingView(self, didMoveToWindow: window)
        if let viewController {
            // viewController._didMoveToWindow()
        }
        // TODO
        base.didMoveToWindow()
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
            base.frameDidChange(oldValue: oldValue)
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
            base.frameDidChange(oldValue: oldValue)
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

    override dynamic open func sizeThatFits(_ size: CGSize) -> CGSize {
        base._layoutSizeThatFits(size)
    }

    // FIXME
    final public func _viewDebugData() -> [_ViewDebug.Data] {
        // TODO
        []
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
    
    package class func defaultViewGraphOutputs() -> ViewGraph.Outputs {
        .defaults
    }

    package class var ignoresPresentations: Bool {
        false
    }

    package class var createsUIInteractions: Bool {
        true
    }

    package class var requiresExplicitGeometryChangedRegistration: Bool {
        true
    }

    package var focusedValues: FocusedValues = .init() {
        didSet {
            invalidateProperties(.focusedValues)
        }
    }

    // Audited for 6.5.4
    private struct EnableVFDFeature: ViewGraphFeature {
        func modifyViewInputs(inputs: inout _ViewInputs, graph: ViewGraph) {
            inputs.base.options.insert(.supportsVariableFrameDuration)
        }
    }

    @objc(swiftui_insertRenderedSubview:atIndex:) // FIXME: ViewUpdater -> CoreViewAddSubview
    private func openswiftui_insertRenderedSubview(_ view: UIView, at index: Int) {
        isInsertingRenderedSubview = true
        insertSubview(view, at: index)
        isInsertingRenderedSubview = false
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
            #if !os(visionOS)
            let convertedKeyboardFrame = convert(keyboardFrame, from: window.screen.coordinateSpace)
            bottomInset = convertedKeyboardFrame.minY - bounds.maxY
            #else
            // FIXME
            bottomInset = .zero
            #endif
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
    
    func safeAreaRegionsDidChange(from oldSafeAreaRegions: SafeAreaRegions) {
        guard safeAreaRegions != oldSafeAreaRegions else {
            return
        }
        invalidateProperties([.safeArea, .containerSize])
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

    package var isInSizeTransition: Bool {
        _base.isInSizeTransition
    }

    package var isRotatingWindow: Bool {
        _base.isRotatingWindow
    }

    package var sceneActivationState: UIScene.ActivationState? {
        _base.sceneActivationState
    }

    package var isResizingSheet: Bool {
        // TODO
        return false
    }

    package var isTabSidebarMorphing: Bool {
        // TODO
        return false
    }
}

extension _UIHostingView: ViewRendererHost {
    package func `as`<T>(_ type: T.Type) -> T? {
        guard let value = base.as(type) else {
            // FocusHost
            if UIViewControllerProvider.self == type {
                return unsafeBitCast(self as any UIViewControllerProvider, to: T.self)
            } else { // TODO
                return nil
            }
        }
        return value
    }

    package var renderingPhase: ViewRenderingPhase {
        get { base.renderingPhase }
        set { base.renderingPhase = newValue }
    }
    
    package var externalUpdateCount: Int {
        get { base.externalUpdateCount }
        set { base.externalUpdateCount = newValue }
    }
    
    package func updateEnvironment() {
        // FIXME
        var environment = EnvironmentValues()
        environment.displayScale = traitCollection.displayScale
        if let displayGamut = DisplayGamut(rawValue: traitCollection.displayGamut.rawValue) {
            environment.displayGamut = displayGamut
        }
        // TODO
        environment.feedbackCache = feedbackCache
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

    package func updateContainerSize() {
        // _openSwiftUIUnimplementedFailure()
    }
    
    package func updateRootView() {
        let rootView = makeRootView()
        viewGraph.setRootView(rootView)
    }

    package func outputsDidChange(outputs: ViewGraph.Outputs) {
        _openSwiftUIUnimplementedWarning()
    }
    
    package func focusDidChange() {
        _openSwiftUIUnimplementedWarning()
    }

    package func requestUpdate(after delay: Double) {
        base.requestUpdate(after: delay)
    }

    public func preferencesDidChange() {
        _openSwiftUIUnimplementedWarning()
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
        _base.canAdvanceTimeAutomatically = false
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
        _base.canAdvanceTimeAutomatically = true
    }
}

extension UIDevice {
    package var screenSize: CGSize {
        #if !os(visionOS) || OPENSWIFTUI_INTERNAL_XR_SDK
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
        #else
        return .zero
        #endif
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

// MARK: - _UIHostingView + UIHostingViewBaseDelegate [6.5.4]

extension _UIHostingView: UIHostingViewBaseDelegate {
    package var shouldDisableUIKitAnimations: Bool {
        guard allowUIKitAnimations == 0,
              !base.allowUIKitAnimationsForNextUpdate,
              !isInSizeTransition,
              !isResizingSheet,
              !isRotatingWindow,
              !isTabSidebarMorphing
        else {
            return false
        }
        return true
    }

    package func sceneActivationStateDidChange() {
        _openSwiftUIUnimplementedWarning()
    }
}

// MARK: - _UIHostingView + UIViewControllerProvider [6.5.4]

extension _UIHostingView: UIViewControllerProvider {
    var uiViewController: UIViewController? {
        viewController
    }
}

// MARK: _UIHostingView.HostViewGraph [6.5.4] [Blocked by Gesture System]

extension _UIHostingView {
    private struct HostViewGraph: ViewGraphFeature {
        weak var host: _UIHostingView?

        func modifyViewInputs(inputs: inout _ViewInputs, graph: ViewGraph) {
            guard let host else {
                return
            }
            // inputs.eventBindingBridgeFactory = UIKitResponderEventBindingBridge.Factory.self
            // inputs.gestureContainerFactory = UIKitGestureContainerFactory.self
            // host.delegate?.xx
            var idiom = inputs[InterfaceIdiomInput.self]
            if idiom == nil {
                Update.syncMain {
                    idiom = host.traitCollection.userInterfaceIdiom.idiom ?? UIDevice.current.userInterfaceIdiom.idiom
                }
            }
            idiom.map { inputs[InterfaceIdiomInput.self] = $0 }
            let box: WeakBox<UIView> = WeakBox(host)
            let boxAttr = Attribute(value: box)
            // inputs[UIKitHostContainerFocusItemInput.self] = boxAttr
            inputs.textAlwaysOnProvider = OpenSwiftUITextAlwaysOnProvider.self
            // navigationBridge?.updateViewInputs(&inputs)
        }
    }
}

#endif
