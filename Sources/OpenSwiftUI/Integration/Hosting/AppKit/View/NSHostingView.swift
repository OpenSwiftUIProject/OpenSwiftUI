//
//  NSHostingView.swift
//  OpenSwiftUI
//
//  Audited for macOS 15.0
//  Status: WIP

#if os(macOS)
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
public import OpenSwiftUICore
public import AppKit
import OpenSwiftUI_SPI

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

    package var externalUpdateCount: Int = .zero

    private var canAdvanceTimeAutomatically = true

    private var needsDeferredUpdate = false

    private var isPerformingLayout: Bool {
        if renderingPhase == .rendering {
            return true
        }
        return externalUpdateCount > 0
    }

    open override var isFlipped: Bool { true }
    
    open override var layerContentsRedrawPolicy: NSView.LayerContentsRedrawPolicy {
        set { }
        get { .duringViewResize }
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

    open override func layout() {
        super.layout()
        guard canAdvanceTimeAutomatically else {
            return
        }
        guard !isPerformingLayout else {
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
            render(targetTimestamp: Time())
            // TODO
            isUpdating = false
            // TODO
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

    weak var viewController: NSHostingController<Content>?

    var colorScheme: ColorScheme? = nil {
        didSet {}
    }

    public final func _viewDebugData() -> [_ViewDebug.Data] { [] }

    func clearUpdateTimer() {
        // TODO
    }

    func cancelAsyncRendering() {
        // TODO    
    }

    package func makeViewDebugData() -> Data? {
        Update.ensure {
            _ViewDebug.serializedData(viewGraph.viewDebugData())
        }
    }

    static func defaultViewGraphOutputs() -> ViewGraph.Outputs { .defaults }

    func setNeedsUpdate() {
        needsUpdateConstraints = true
        needsLayout = true
    }
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSHostingView {
    public func _renderForTest(interval: Double) {
        // TODO
    }

    public func _renderAsyncForTest(interval: Double) -> Bool {
        // TODO
        false
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
        // TODO
    }

    package func updateSize() {
        viewGraph.setProposedSize(bounds.size)
    }

    package func updateSafeArea() {
        // TODO
    }

    package func updateContainerSize() {
        // TODO
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

    package func requestUpdate(after: Double) {
        // TODO
        setNeedsUpdate()
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
    func forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {
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
