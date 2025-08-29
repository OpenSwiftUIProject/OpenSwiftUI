//
//  UIHostingViewBase.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 529B7E967685565FD5A0228999A3F1FE (SwiftUI)

#if os(iOS)
package import QuartzCore
package import UIKit

import COpenSwiftUI
import OpenAttributeGraphShims
import OpenSwiftUI_SPI
@_spi(ForOpenSwiftUIOnly)
package import OpenSwiftUICore

// MARK: - UIHostingViewBase [WIP]

package class UIHostingViewBase {
    package weak var uiView: UIView?
    package weak var host: ViewRendererHost?
    package weak var delegate: UIHostingViewBaseDelegate?

    package struct Options: OptionSet {
        package let rawValue: Int

        package init(rawValue: Int) {
            self.rawValue = rawValue
        }

        package static let displayList: UIHostingViewBase.Options = .init(rawValue: 1 << 0)

        package static let platformItemList: UIHostingViewBase.Options = .init(rawValue: 1 << 1)

        package static let viewResponders: UIHostingViewBase.Options = .init(rawValue: 1 << 2)

        package static let layout: UIHostingViewBase.Options = .init(rawValue: 1 << 3)

        package static let focus: UIHostingViewBase.Options = .init(rawValue: 1 << 4)

        package static let registeredForGeometryChanges: UIHostingViewBase.Options = .init(rawValue: 1 << 5)
    }

    package let options: UIHostingViewBase.Options

    package let viewGraph: ViewGraph

    package let renderer: DisplayList.ViewRenderer = .init(
        platform: .init(
            definition: UIViewPlatformViewDefinition.self
        )
    )

    package let eventBindingManager: EventBindingManager = .init()

    package var currentTimestamp: Time = .zero

    package var propertiesNeedingUpdate: ViewRendererHostProperties = .all

    package var renderingPhase: ViewRenderingPhase = .none

    package var externalUpdateCount: Int = .zero

    package var parentPhase: _GraphInputs.Phase?

    package var initialInheritedEnvironment: EnvironmentValues?

    package var inheritedEnvironment: EnvironmentValues?

    package var environmentOverride: EnvironmentValues?

    package var traitCollectionOverride: UITraitCollection? {
        didSet {
            guard traitCollectionOverride != oldValue, let host else {
                return
            }
            host.invalidateProperties(.environment)
        }
    }

    package var displayLink: DisplayLink?

    package var lastRenderTime: Time = .zero

    package var nextTimerTime: Time?

    package var updateTimer: Timer?

    package var canAdvanceTimeAutomatically: Bool = true

    package var pendingPreferencesUpdate: Bool = false

    package var pendingPostDisappearPreferencesUpdate: Bool = false

    package var allowUIKitAnimationsForNextUpdate: Bool = false

    package var isHiddenForReuse: Bool = false {
        didSet { updateRemovedState(uiView: nil) }
    }

    package var isEnteringForeground: Bool = false

    package var isExitingForeground: Bool = false

    package var isCapturingSnapshots: Bool = false

    package var isRotatingWindow: Bool = false

    package var isInSizeTransition: Bool = false

    private var _sceneActivationState: UIScene.ActivationState?

    @inline(__always)
    package var sceneActivationState: UIScene.ActivationState? {
        get {
            let selector = Selector(("_windowHostingScene"))
            guard let uiView,
                  let window = uiView.window,
                  window.responds(to: selector),
                  (window.perform(selector).takeUnretainedValue() as? UIWindowScene) != nil
            else {
                return nil
            }
            return _sceneActivationState
        }
        set {
            _sceneActivationState = newValue
        }
    }

    package var registeredForGeometryChanges: Bool = false

    package weak var observedWindow: UIWindow?

    package weak var observedScene: UIWindowScene? {
        didSet {
            updateSceneActivationState()
        }
    }

    package init<V>(rootViewType: V.Type, options: Options) where V: View {
        self.options = options
        self.viewGraph = ViewGraph(
            rootViewType: rootViewType,
            requestedOutputs: .init(options)
        )
    }

    package func tearDown(uiView: UIView, host: ViewRendererHost) {
        NotificationCenter.default.removeObserver(self)
        updateRemovedState(uiView: uiView)
        host.invalidate()
        Update.ensure {
            viewGraph.preferenceBridge = nil
            viewGraph.invalidate()
        }
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

    func _layoutSizeThatFits(
        _ size: CGSize
        // fixedAxes: _UILayoutAxes
    ) -> CGSize {
        guard let host else {
            return .zero
        }
        let maxValue = 2777780.0
        let fittingSize = host.sizeThatFits(.init(
            width: size.width >= maxValue ? nil : size.width,
            height: size.height >= maxValue ? nil : size.height
        ))
        let pixelLength = host.viewGraph.environment.pixelLength
        return fittingSize.rounded(.up, toMultipleOf: pixelLength)
    }

    //    func _baselineOffsets(at: CGSize) -> _UIBaselineOffsetPair

    // MARK: - Update

    package func startUpdateEnvironment() -> EnvironmentValues {
        guard let uiView else {
            return EnvironmentValues()
        }
        let traitCollection = traitCollectionOverride ?? uiView.traitCollection
        var environment: EnvironmentValues
        if traitCollection._environmentWrapper != nil {
            if let inheritedEnvironment {
                environment = inheritedEnvironment
            } else {
                environment = traitCollection.environment
            }
        } else {
            if let inheritedEnvironment {
                environment = inheritedEnvironment
            } else if let initialInheritedEnvironment {
                environment = initialInheritedEnvironment
            } else {
                environment = traitCollection.environment
            }
        }
        if let environmentOverride {
            environment.plist.override(with: environmentOverride.plist)
        }
        var result = traitCollection.resolvedEnvironment(base: EnvironmentValues(environment.plist))
        result.configureForPlatform(traitCollection: traitCollection)
        return environment
    }

    package func endUpdateEnvironment(_ environment: EnvironmentValues) {
        guard let uiView, let host else {
            return
        }
        let traitCollection = traitCollectionOverride ?? uiView.traitCollection
        viewGraph.setEnvironment(environment)
        updateGraphPhaseIfNeeded(newParentPhase: traitCollection.viewPhase)
        viewGraph.updatePreferenceBridge(environment: environment) { [weak host] in
            guard let host else {
                return
            }
            host.updateEnvironment()
        }
    }

    package func updateTransformWithoutGeometryObservation() {
        _openSwiftUIUnimplementedFailure()
    }

    package func updateContainerSize() {
        _openSwiftUIUnimplementedFailure()
    }

    package var updatesAtFullFidelity: Bool {
        guard uiView != nil, let sceneActivationState, !isHiddenForReuse else {
            return false
        }
        return sceneActivationState == .foregroundActive ||
            sceneActivationState == .foregroundInactive ||
            isEnteringForeground ||
            isCapturingSnapshots
    }

    package func requestImmediateUpdate() {
        guard let view = uiView else {
            return
        }
        cancelAsyncRendering()
        guard updatesAtFullFidelity else {
            guard pendingPreferencesUpdate else {
                return
            }
            pendingPreferencesUpdate = true
            DispatchQueue.main.async { [self] in
                guard uiView != nil else {
                    return
                }
                pendingPreferencesUpdate = false
                guard let host else {
                    return
                }
                guard canAdvanceTimeAutomatically else {
                    return
                }
                let interval = renderInterval(timestamp: .systemUptime) / Double(UIAnimationDragCoefficient())
                host.render(interval: interval, updateDisplayList: false, targetTimestamp: nil)
            }
            return
        }
        view.setNeedsLayout()
        CoreTesting.needsRender = true
    }

    package func requestUpdate(after delay: Double) {
        Update.lock()
        if delay != .zero || (viewGraph.mayDeferUpdate && displayLink?.willRender == true) {
            let delay = Double(UIAnimationDragCoefficient()) * delay
            if delay >= 0.25 {
                startUpdateTimer(delay: delay)
            } else {
                startDisplayLink(delay: delay)
            }
        } else {
            if Thread.isMainThread {
                requestImmediateUpdate()
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    requestImmediateUpdate()
                }
            }
        }
        Update.unlock()
    }

    package func updateRemovedState(uiView: UIView?) {
        guard let uiView = uiView ?? self.uiView else {
            return
        }
        var removedState: GraphHost.RemovedState = []
        if uiView.window == nil {
            removedState.insert(.unattached)
        }
        if isHiddenForReuse {
            removedState.insert(.hiddenForReuse)
            cancelAsyncRendering()
            clearDisplayLink()
        }
        Update.ensure {
            viewGraph.removedState = removedState
        }
    }

    package func updateSceneActivationState() {
        _sceneActivationState = observedScene?.activationState
        delegate?.sceneActivationStateDidChange()
    }

    package func requestUpdateForFidelity() {
        guard let uiView else {
            return
        }
        guard updatesAtFullFidelity else {
            cancelAsyncRendering()
            clearDisplayLink()
            clearUpdateTimer()
            if uiView.layer.needsLayout() {
                requestImmediateUpdate()
            }
            return
        }
        uiView.setNeedsLayout()
        requestUpdate(after: .zero)
    }

    package func renderInterval(timestamp: Time) -> Double {
        if lastRenderTime == Time() || lastRenderTime > timestamp {
            lastRenderTime = timestamp - 1e-6
        }
        let interval = timestamp - lastRenderTime
        lastRenderTime = timestamp
        return interval
    }

    package func updateGraphPhaseIfNeeded(newParentPhase: ViewPhase) {
        guard let parentPhase else {
            viewGraph.setPhase(newParentPhase)
            parentPhase = newParentPhase
            return
        }
        if parentPhase.resetSeed != newParentPhase.resetSeed {
            viewGraph.incrementPhase()
        }
        if parentPhase.isBeingRemoved != newParentPhase.isBeingRemoved {
            viewGraph.data.phase.isBeingRemoved = newParentPhase.isBeingRemoved
        }
        self.parentPhase = newParentPhase
    }

    package func cancelAsyncRendering() {
        _ = Update.locked {
            displayLink?.cancelAsyncRendering()
            return displayLink == nil ? nil : ()
        }
    }

    // MARK: - DisplayLink and Timer

    package func startDisplayLink(delay: Double) {
        guard let uiView else { return }
        if displayLink == nil, updatesAtFullFidelity, let window = uiView.window {
            displayLink = DisplayLink(host: self, window: window)
        }
        guard let displayLink else {
            startUpdateTimer(delay: delay)
            return
        }
        displayLink.setNextUpdate(
            delay: delay,
            interval: viewGraph.nextUpdate.views.interval,
            reasons: viewGraph.nextUpdate.gestures.reasons
        )
        clearUpdateTimer()
    }

    package func startUpdateTimer(delay: Double) {
        guard Thread.isMainThread else {
            displayLink?.cancelAsyncRendering()
            Update.syncMain {
                startUpdateTimer(delay: delay)
            }
            return
        }
        let delay = max(delay, 0.1)
        cancelAsyncRendering()
        let updateTime = currentTimestamp + delay
        guard updateTime < (nextTimerTime ?? .infinity) else {
            return
        }
        updateTimer?.invalidate()
        nextTimerTime = updateTime
        updateTimer = withDelay(delay) { [self] in
            guard uiView != nil else {
                return
            }
            updateTimer = nil
            nextTimerTime = nil
            requestImmediateUpdate()
        }
    }

    package func clearUpdateTimer() {
        guard Thread.isMainThread else {
            return
        }
        updateTimer?.invalidate()
        updateTimer = nil
        nextTimerTime = nil
    }

    package func displayLinkTimer(
        timestamp: Time,
        targetTimestamp: Time,
        isAsyncThread: Bool
    ) {
        guard let host else {
            return
        }
        clearUpdateTimer()
        let interval = renderInterval(timestamp: timestamp) / Double(UIAnimationDragCoefficient())
        let targetTimestamp: Time? = targetTimestamp
        if isAsyncThread {
            let renderedTime = host.renderAsync(interval: interval, targetTimestamp: targetTimestamp)
            if let renderedTime {
                if renderedTime.seconds.isFinite {
                    let delay = max(renderedTime - currentTimestamp, 1e-6)
                    requestUpdate(after: delay)
                }
                if viewGraph.updateRequiredMainThread {
                    displayLink?.cancelAsyncRendering()
                }
            } else {
                displayLink?.cancelAsyncRendering()
                requestUpdate(after: .zero)
            }
        } else {
            host.render(interval: interval, targetTimestamp: targetTimestamp)
            if let displayLink,
               displayLink.willRender,
               !viewGraph.updateRequiredMainThread,
               isLinkedOnOrAfter(.v3)
            {
                displayLink.enableAsyncRendering()
            }
        }
    }

    package func clearDisplayLink() {
        Update.locked {
            displayLink?.invalidate()
        }
        displayLink = nil
    }

    // MARK: - UIView related

    package func frameDidChange(oldValue: CGRect) {
        guard let uiView, let host, uiView.bounds.size != .zero else {
            return
        }
        var props: ViewRendererHostProperties = [.size, .containerSize]
        props.insert(.safeArea)
        host.invalidateProperties(props, mayDeferUpdate: false)
    }

    package func _geometryChanged(_: UnsafeRawPointer, forAncestor: UIView?) {
        _openSwiftUIUnimplementedFailure()
    }

    package func layoutSubviews() {
        guard let host,
              let uiView,
              uiView.window != nil,
              canAdvanceTimeAutomatically
        else {
            return
        }
        Update.lock()
        cancelAsyncRendering()
        let interval = if let displayLink, displayLink.willRender {
            0.0
        } else {
            renderInterval(timestamp: .systemUptime) / Double(UIAnimationDragCoefficient())
        }
        host.render(interval: interval, targetTimestamp: nil)
        Update.unlock()
    }

    package func didMoveToWindow() {
        guard let uiView, let host else {
            return
        }
        let window = uiView.window
        if window != nil {
            traitCollectionOverride = nil
            initialInheritedEnvironment = nil
            host.invalidateProperties(.transform)
        }
        if !pendingPostDisappearPreferencesUpdate, isLinkedOnOrAfter(.v6) {
            // TODO: UIKitUpdateCycle.addPreCommitObserver
        }
        if window != nil {
            updateRemovedState(uiView: nil)
        } else {
            UIApplication.shared._performBlockAfterCATransactionCommits { [weak self] in
                guard let self else { return }
                updateRemovedState(uiView: nil)
            }
        }
        updateSceneNotifications()
        updateWindowNotifications()
        requestUpdateForFidelity()
        if window == nil {
            isRotatingWindow = false
        }
        host.invalidateProperties(.environment)
    }

    // MARK: - Notification

    package func setupNotifications() {
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(willBeginSnapshotSession),
            name: .init("_UIApplicationWillBeginSnapshotSessionNotification"),
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(didEndSnapshotSession),
            name: .init("_UIApplicationDidEndSnapshotSessionNotification"),
            object: nil
        )
        var names: [NSNotification.Name] = [
            NSLocale.currentLocaleDidChangeNotification,
            .NSSystemTimeZoneDidChange,
        ]
        names.append(
            UIScene.systemProtectionDidChangeNotification
        )
        for name in names {
            center.addObserver(
                self,
                selector: #selector(externalEnvironmentDidChange),
                name: name,
                object: nil
            )
        }
    }

    private func updateWindowNotifications() {
        guard let uiView else {
            return
        }
        let newWindow = uiView.window
        guard newWindow != observedWindow else {
            return
        }
        let center = NotificationCenter.default
        let windowWillRotateNotification = NSNotification.Name("UIWindowWillRotateNotification")
        let windowDidRotateNotification = NSNotification.Name("UIWindowDidRotateNotification")
        let windowDidMoveToSceneNotification = NSNotification.Name("_UIWindowDidMoveToSceneNotification")
        if let observedWindow {
            center.removeObserver(self, name: windowWillRotateNotification, object: observedWindow)
            center.removeObserver(self, name: windowDidRotateNotification, object: observedWindow)
            center.removeObserver(self, name: windowDidMoveToSceneNotification, object: observedWindow)
        }
        if let newWindow {
            center.addObserver(self, selector: #selector(windowWillRotate), name: windowWillRotateNotification, object: newWindow)
            center.addObserver(self, selector: #selector(windowDidRotate), name: windowDidRotateNotification, object: newWindow)
            center.addObserver(self, selector: #selector(windowDidMoveToScene), name: windowDidMoveToSceneNotification, object: newWindow)
        }
    }

    private func updateSceneNotifications() {
        guard let uiView else {
            return
        }
        let newScene = uiView.window?.windowScene
        guard newScene != observedScene else {
            return
        }
        let center = NotificationCenter.default
        let sceneWillDeactivateNotification = UIScene.willDeactivateNotification
        let sceneDidActivateNotification = UIScene.didActivateNotification
        let sceneDidEnterBackgroundNotification = UIScene.didEnterBackgroundNotification
        let sceneWillEnterForegroundNotification = UIScene.willEnterForegroundNotification
        if let observedScene {
            center.removeObserver(self, name: sceneWillDeactivateNotification, object: observedScene)
            center.removeObserver(self, name: sceneDidActivateNotification, object: observedScene)
            center.removeObserver(self, name: sceneDidEnterBackgroundNotification, object: observedScene)
            center.removeObserver(self, name: sceneWillEnterForegroundNotification, object: observedScene)
        }
        if let newScene {
            center.addObserver(self, selector: #selector(sceneWillDeactivate), name: sceneWillDeactivateNotification, object: newScene)
            center.addObserver(self, selector: #selector(sceneDidActivate), name: sceneDidActivateNotification, object: newScene)
            center.addObserver(self, selector: #selector(sceneDidEnterBackground), name: sceneDidEnterBackgroundNotification, object: newScene)
            center.addObserver(self, selector: #selector(sceneWillEnterForeground), name: sceneWillEnterForegroundNotification, object: newScene)
        }
        observedScene = newScene
        updateSceneActivationState()
    }

    // MARK: - ObjC API

    @objc
    package func windowDidRotate(with notification: Notification) {
        isRotatingWindow = false
    }

    @objc
    package func windowWillRotate(with notification: Notification) {
        isRotatingWindow = true
    }

    @objc
    package func windowDidMoveToScene(with notification: Notification) {
        updateSceneNotifications()
    }

    @objc
    package func sceneWillEnterForeground() {
        updateSceneActivationState()
        isEnteringForeground = true
        onNextMainRunLoop { [self] in
            isEnteringForeground = false
            updateSceneActivationState()
        }
        isExitingForeground = false
        requestUpdateForFidelity()
    }

    @objc
    package func sceneDidEnterBackground() {
        sceneDidActivate()
    }

    @objc
    package func sceneWillDeactivate() {
        updateSceneActivationState()
        isExitingForeground = true
    }

    @objc
    package func sceneDidActivate() {
        updateSceneActivationState()
        isExitingForeground = false
        requestUpdateForFidelity()
    }

    @objc
    package func sceneDidUpdateSystemUserInterfaceStyle() {
        externalEnvironmentDidChange()
    }

    @objc
    package func willBeginSnapshotSession() {
        isCapturingSnapshots = true
    }

    @objc
    package func didEndSnapshotSession() {
        isCapturingSnapshots = false
    }

    @objc
    package func externalEnvironmentDidChange() {
        host?.invalidateProperties(.environment)
    }
}

// MARK: - UIHostingViewBase + ViewGraphRenderDelegate

extension UIHostingViewBase: ViewGraphRenderDelegate {
    package var renderingRootView: AnyObject {
        uiView ?? .init()
    }

    package func updateRenderContext(_ context: inout ViewGraphRenderContext) {
        guard let uiView else {
            return
        }
        context.contentsScale = uiView.window?.screen.scale ?? 1.0
    }

    package func withMainThreadRender(wasAsync: Bool, _ body: () -> Time) -> Time {
        let shouldDisableUIKitAnimations = delegate?.shouldDisableUIKitAnimations ?? false
        guard UIView.areAnimationsEnabled, shouldDisableUIKitAnimations else {
            let time = body()
            if !wasAsync {
                allowUIKitAnimationsForNextUpdate = false
            }
            return time
        }
        guard !wasAsync else {
            return body()
        }
        var time = Time.infinity
        UIView.performWithoutAnimation {
            time = body()
        }
        allowUIKitAnimationsForNextUpdate = false
        return time
    }
}

// MARK: - UIHostingViewBaseDelegate

package protocol UIHostingViewBaseDelegate: AnyObject {
    var shouldDisableUIKitAnimations: Bool { get }
    func sceneActivationStateDidChange()
}

// MARK: ViewGraph.Outputs + UIHostingViewBase.Options

extension ViewGraph.Outputs {
    package init(_ options: UIHostingViewBase.Options) {
        var outputs: ViewGraph.Outputs = []
        if options.contains(.displayList) {
            outputs.formUnion(.displayList)
        }
        if options.contains(.platformItemList) {
            outputs.formUnion(.platformItemList)
        }
        if options.contains(.viewResponders) {
            outputs.formUnion(.viewResponders)
        }
        if options.contains(.layout) {
            outputs.formUnion(.layout)
        }
        if options.contains(.focus) {
            outputs.formUnion(.focus)
        }
        self = outputs
    }

    @inline(__always)
    package var options: UIHostingViewBase.Options {
        var options: UIHostingViewBase.Options = []
        if contains(.displayList) {
            options.formUnion(.displayList)
        }
        if contains(.platformItemList) {
            options.formUnion(.platformItemList)
        }
        if contains(.viewResponders) {
            options.formUnion(.viewResponders)
        }
        if contains(.layout) {
            options.formUnion(.layout)
        }
        if contains(.focus) {
            options.formUnion(.focus)
        }
        return options
    }
}

// MARK: - DisplayLink

@objc
final package class DisplayLink: NSObject {
    private static var asyncThread: Thread? = nil
    private static var asyncRunloop: RunLoop? = nil
    private static var asyncPending: Bool = false

    private weak var host: UIHostingViewBase? = nil
    private var link: CADisplayLink? = nil
    private var nextUpdate: Time = .infinity
    private var currentUpdate: Time? = nil
    private var interval: Double = .zero
    private var reasons: Set<UInt32> = []

    package enum ThreadName: Hashable {
        case main
        case async
    }

    private var currentThread: ThreadName = .main
    private var nextThread: ThreadName = .main

    package init(host: UIHostingViewBase, window: UIWindow) {
        super.init()
        self.host = host
        link = window.screen.displayLink(
            withTarget: self,
            selector: #selector(displayLinkTimer(_:))
        )
        link?.add(to: .main, forMode: .common)
    }

    package func setNextUpdate(delay: Double, interval: Double, reasons: Set<UInt32>) {
        let newNextUpdate: Time
        if delay >= 0.01 {
            newNextUpdate = (currentUpdate ?? .systemUptime) + interval
        } else {
            newNextUpdate = .zero
        }

        if newNextUpdate < nextUpdate {
            nextUpdate = newNextUpdate
            link?.isPaused = false
        }
        setFrameInterval(interval, reasons: reasons)
    }

    private func setFrameInterval(_ interval: Double, reasons: Set<UInt32>) {
        if self.interval != interval {
            self.interval = interval
            link?.preferredFrameRateRange = CAFrameRateRange(interval: interval)
        }
        if self.reasons != reasons {
            self.reasons = reasons
            let count = reasons.count
            withUnsafeTuple(of: TupleType(UInt32.self), count: count) { tuple in
                let pointer = tuple.address(as: UInt32.self)
                for (index, reason) in reasons.enumerated() {
                    pointer[index] = reason
                }
                link?.setHighFrameRateReasons(pointer, count: count)
            }
        }
    }

    package func invalidate() {
        Update.locked {
            if let link, link.isPaused {
                link.invalidate()
            }
            link = nil
        }
    }

    // MARK: - ObjC API

    #if canImport(ObjectiveC)
    @objc(asyncThreadWithArg:)
    #endif
    private static func asyncThread(with arg: Any?) {
        Update.lock()
        asyncRunloop = RunLoop.current
        Update.broadcast()
        while asyncPending {
            asyncPending = false
            Update.unlock()
            asyncRunloop!.schedule(
                after: RunLoop.SchedulerTimeType(Date(timeIntervalSinceNow: 1.0)),
                tolerance: RunLoop.SchedulerTimeType.Stride(0.1),
                options: nil
            ) {
                _openSwiftUIEmptyStub()
            }
            asyncRunloop!.run()
            Update.lock()
        }
        asyncRunloop = nil
        asyncThread = nil
        Update.broadcast()
        Update.unlock()
    }

    #if canImport(ObjectiveC)
    @objc(displayLinkTimer:)
    #endif
    private func displayLinkTimer(_ link: CADisplayLink) {
        Update.lock()
        if currentThread == nextThread, self.link != nil {
            let linkTime = Time(seconds: link.timestamp)
            let linkTargetTime = Time(seconds: link.targetTimestamp)
            if linkTime > nextUpdate - 1.0 / 240.0 {
                currentUpdate = linkTime
                nextUpdate = .infinity
                host?.displayLinkTimer(
                    timestamp: linkTime,
                    targetTimestamp: linkTargetTime,
                    isAsyncThread: currentThread == .async
                )
                currentUpdate = nil
                if nextUpdate == .infinity {
                    if nextThread == .async {
                        cancelAsyncRendering()
                        nextUpdate = linkTime
                    }
                }
            }
        }
        if nextThread != currentThread, let oldLink = self.link {
            if nextThread == .async {
                Self.asyncPending = true
                if Self.asyncRunloop == nil {
                    let threadName = "org.OpenSwiftUIProject.OpenSwiftUI.AsyncRenderer"
                    while true {
                        if Self.asyncThread == nil { // FIXME:
                            let thread = Thread(
                                target: DisplayLink.self,
                                selector: #selector(DisplayLink.asyncThread(with:)),
                                object: nil
                            )
                            thread.qualityOfService = .userInteractive
                            thread.name = threadName
                            guard _NSThreadStart(thread) else {
                                cancelAsyncRendering()
                                break
                            }
                            Self.asyncThread = thread
                        }
                        Update.wait()
                        guard Self.asyncRunloop == nil else {
                            break
                        }
                    }
                }
            }
            if nextThread != currentThread {
                let runloop: RunLoop
                let isAsync: Bool
                switch nextThread {
                case .main:
                    runloop = RunLoop.main
                    isAsync = false
                case .async:
                    runloop = Self.asyncRunloop!
                    isAsync = true
                }
                oldLink.remove(from: .current, forMode: .common)
                let newLink = CADisplayLink(display: oldLink.display, target: self, selector: #selector(displayLinkTimer(_:)))
                newLink.add(to: runloop, forMode: .common)
                self.link = newLink
                let oldInterval = interval
                let oldReasons = reasons
                interval = .zero
                reasons = []
                setFrameInterval(oldInterval, reasons: oldReasons)
                currentThread = isAsync ? .async : .main
            }
        }
        if self.link != nil {
            if nextUpdate == .infinity, nextThread == currentThread {
                link.isPaused = true
            }
        } else {
            link.invalidate()
        }
        Update.unlock()
    }

    @inline(__always)
    package var willRender: Bool {
        nextUpdate < .infinity
    }

    @inline(__always)
    package func cancelAsyncRendering() {
        nextThread = .main
    }

    @inline(__always)
    package func enableAsyncRendering() {
        nextThread = .async
    }
}
#endif
