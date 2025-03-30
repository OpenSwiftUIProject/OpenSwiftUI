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

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
open class NSHostingView<Content>: NSView, XcodeViewDebugDataProvider where Content: View {
    public var sizingOptions: NSHostingSizingOptions = .standardBounds {
        didSet {
            guard sizingOptions != oldValue else { return }
            needsUpdateConstraints = true
            invalidateIntrinsicContentSize()
        }
    }

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

    var canAdvanceTimeAutomatically = true

    var needsDeferredUpdate = false

    var isPerformingLayout: Bool {
        if renderingPhase == .rendering {
            return true
        }
        return externalUpdateCount > 0
    }

    public required init(rootView: Content) {
        self._rootView = rootView
        // TODO:
        Update.begin()
        self.viewGraph = ViewGraph(
            rootViewType: ModifiedContent<Content, HitTestBindingModifier>.self
        )
        // TODO:
        super.init(frame: .zero)
        initializeViewGraph()
        // TODO:
        clipsToBounds = false
        // TODO:
        wantsLayer = true
        // TODO:
        HostingViewRegistry.shared.add(self)
        // TODO:
        Update.end()
    }

    @available(*, unavailable)
    public dynamic required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
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
            render()
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

    /// TODO:
    func clearUpdateTimer() {}

    /// TODO:
    func cancelAsyncRendering() {}

    /// FIXME:
    func _forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {
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
    public func _renderForTest(interval: Double) {}

    public func _renderAsyncForTest(interval: Double) -> Bool {
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
    package func updateEnvironment() {}

    package func updateSize() {}

    package func updateSafeArea() {}

    package func updateScrollableContainerSize() {}

    package func renderDisplayList(_ list: DisplayList, asynchronously: Bool, time: Time, nextTime: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time {
        .infinity
    }

    package func updateRootView() {
        let rootView = makeRootView()
        viewGraph.setRootView(rootView)
    }

    package func requestUpdate(after: Double) {}
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
#endif
