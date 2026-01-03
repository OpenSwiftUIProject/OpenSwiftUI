//
//  ViewRendererHost.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by OAGValueState and Trace
//  ID: 76C8A4B3FC8EE0F99045B3425CD62255 (SwiftUICore)

package import Foundation
import OpenAttributeGraphShims

// MARK: - ViewRendererHost [6.5.4]

package protocol ViewRendererHost: ViewGraphDelegate {
    var viewGraph: ViewGraph { get }

    var currentTimestamp: Time { get set }

    var responderNode: ResponderNode? { get }

    var propertiesNeedingUpdate: ViewRendererHostProperties { get set }

    var renderingPhase: ViewRenderingPhase { get set }

    var externalUpdateCount: Int { get set }

    func updateRootView()

    func updateEnvironment()

    func updateTransform()

    func updateSize()

    func updateSafeArea()

    func updateContainerSize()

    func updateFocusStore()

    func updateFocusedItem()

    func updateFocusedValues()

    func updateAccessibilityEnvironment()
}

// MARK: - ViewRendererHost + default implementation [6.5.4]

@available(OpenSwiftUI_v1_0, *)
extension ViewRendererHost {
    package var isRendering: Bool {
        renderingPhase != .none
    }
    
    package func initializeViewGraph() {
        viewGraph.delegate = self
        #if canImport(Darwin)
        Signpost.viewHost.traceEvent(
            type: .event,
            object: self,
            "ViewHost: (%p) initialized PlatformHost [ %p ]",
            [
                viewGraph.graph.graphIdentity(),
                UInt(bitPattern: Unmanaged.passUnretained(self).toOpaque()),
            ]
        )
        #endif
    }
    
    package func invalidate() {
        viewGraph.delegate = nil
        #if canImport(Darwin)
        Signpost.viewHost.traceEvent(
            type: .event,
            object: self,
            "ViewHost: (%p) invalidated PlatformHost [ %p ]",
            [
                viewGraph.graph.graphIdentity(),
                UInt(bitPattern: Unmanaged.passUnretained(self).toOpaque()),
            ]
        )
        #endif
    }
    
    package static func makeRootView<V>(_ view: V) -> ModifiedContent<V, HitTestBindingModifier> where V: View {
        view.modifier(HitTestBindingModifier())
    }
    
    @_spi(ForOpenSwiftUIOnly)
    @available(OpenSwiftUI_v6_0, *)
    public func updateViewGraph<T>(body: (ViewGraph) -> T) -> T {
        Update.perform {
            Graph.withoutUpdate {
                updateGraph()
                return body(viewGraph)
            }
        }
    }
    
    @_spi(ForOpenSwiftUIOnly)
    @available(OpenSwiftUI_v6_0, *)
    public func graphDidChange() {
        Update.locked {
            if !isRendering {
                requestUpdate(after: .zero)
            }
        }
    }

    @_spi(ForOpenSwiftUIOnly)
    @available(OpenSwiftUI_v6_0, *)
    public func preferencesDidChange() {
        _openSwiftUIEmptyStub()
    }
    
    package func invalidateProperties(_ props: ViewRendererHostProperties, mayDeferUpdate: Bool = true) {
        Update.locked {
            guard !propertiesNeedingUpdate.contains(props) else {
                return
            }
            propertiesNeedingUpdate = propertiesNeedingUpdate.union(props)
            viewGraph.setNeedsUpdate(mayDeferUpdate: mayDeferUpdate, values: propertiesNeedingUpdate)
            requestUpdate(after: .zero)
        }
    }
    
    package func updateGraph() {
        let properties = propertiesNeedingUpdate
        guard !properties.isEmpty else { return }
        Update.syncMain {
            if properties.contains(.rootView) {
                propertiesNeedingUpdate.remove(.rootView)
                updateRootView()
            }
            if properties.contains(.environment) {
                propertiesNeedingUpdate.remove(.environment)
                updateEnvironment()
            }
            if properties.contains(.transform) {
                propertiesNeedingUpdate.remove(.transform)
                updateTransform()
            }
            if properties.contains(.size) {
                propertiesNeedingUpdate.remove(.size)
                updateSize()
            }
            if properties.contains(.safeArea) {
                propertiesNeedingUpdate.remove(.safeArea)
                updateSafeArea()
            }
            if properties.contains(.containerSize) {
                propertiesNeedingUpdate.remove(.containerSize)
                updateContainerSize()
            }
            if properties.contains(.focusStore) {
                propertiesNeedingUpdate.remove(.focusStore)
                updateFocusStore()
            }
            if properties.contains(.focusedItem) {
                propertiesNeedingUpdate.remove(.focusedItem)
                updateFocusedItem()
            }
            if properties.contains(.focusedValues) {
                propertiesNeedingUpdate.remove(.focusedValues)
                updateFocusedValues()
            }
        }
    }
    
    package func updateTransform() {
        let viewGraph = viewGraph
        let rootTransform = viewGraph.$rootTransform
        guard !rootTransform.valueState.contains(.dirty) else {
            return
        }
        rootTransform.invalidateValue()
        if let delegate = viewGraph.delegate {
            delegate.graphDidChange()
        }
    }

    package func render(
        interval: Double = 0,
        updateDisplayList: Bool = true,
        targetTimestamp: Time?
    ) {
        Update.begin()
        defer { Update.end() }
        guard !isRendering else {
            return
        }
        Signpost.render.traceInterval(
            object: self,
            nil
        ) {
            let viewGraph = viewGraph
            currentTimestamp += interval
            let time = currentTimestamp
            viewGraph.flushTransactions()
            Graph.withoutUpdate {
                updateGraph()
            }
            renderingPhase = .rendering
            var (displayList, version) = (DisplayList(), DisplayList.Version())
            Signpost.renderUpdate.traceInterval(
                object: self,
                nil
            ) {
                var isFirst = true
                repeat {
                    var shouldContinue = isFirst
                    Update.dispatchActions()
                    viewGraph.updateOutputs(at: time)
                    Update.dispatchActions()
                    viewGraph.flushTransactions()
                    if updateDisplayList {
                        (displayList, version) = viewGraph.rootDisplayList ?? (.init(), .init())
                    }
                    isFirst = false
                    if !Update.canDispatch {
                        shouldContinue = shouldContinue && viewGraph.needsTransaction
                    }
                    guard shouldContinue else {
                        break
                    }
                } while true
            }
            var nextTime = viewGraph.nextUpdate.views.time
            if updateDisplayList {
                nextTime = renderDisplayList(
                    displayList,
                    asynchronously:false,
                    time: time,
                    nextTime: nextTime,
                    targetTimestamp: targetTimestamp,
                    version: version,
                    maxVersion: DisplayList.Version(forUpdate: ())
                )
            }
            renderingPhase = .none
            if nextTime.seconds.isFinite {
                let delay = max(nextTime.seconds, time.seconds) - time.seconds
                requestUpdate(after: max(delay, 1e-6))
            }
        }
    }
    
    package func renderAsync(
        interval: Double = 0,
        targetTimestamp: Time?
    ) -> Time? {
        Update.assertIsLocked()
        guard !isRendering,
              propertiesNeedingUpdate.isEmpty else {
            return nil
        }
        let viewGraph = viewGraph
        guard !viewGraph.hasPendingTransactions else {
            return nil
        }
        return Update.perform {
            currentTimestamp += interval
            let time = currentTimestamp
            renderingPhase = .renderingAsync
            if let (list, version) = viewGraph.updateOutputsAsync(at: time) {
                let renderTime = renderDisplayList(
                    list,
                    asynchronously: true,
                    time: time,
                    nextTime: viewGraph.nextUpdate.views.time,
                    targetTimestamp: targetTimestamp,
                    version: version,
                    maxVersion: .init(forUpdate: ())
                )
                renderingPhase = .none
                return renderTime
            } else {
                renderingPhase = .none
                return nil
            }
        }
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
        guard let delegate = self.as(ViewGraphRenderDelegate.self),
              let renderer = self.as(DisplayList.ViewRenderer.self)
        else { return .infinity }

        func renderOnMainThread() -> Time {
            var context = ViewGraphRenderContext(
                contentsScale: .zero,
                opaqueBackground: false
            )
            delegate.updateRenderContext(&context)
            var environment = DisplayList.ViewRenderer.Environment(
                contentsScale: context.contentsScale
            )
            #if os(macOS)
            if isAppKitBased() {
                environment.opaqueBackground = context.opaqueBackground
            }
            #endif
            let rootView = delegate.renderingRootView
            // TODO: CustomEventTrace
            return delegate.withMainThreadRender(wasAsync: false) {
                #if canImport(SwiftUI, _underlyingVersion: 6.0.87) && _OPENSWIFTUI_SWIFTUI_RENDER
                renderer.swiftUI_render(
                    rootView: self,
                    from: list,
                    time: time,
                    nextTime: nextTime,
                    version: version,
                    maxVersion: maxVersion,
                    environment: environment
                )
                #else
                renderer.render(
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
        }
        if asynchronously {
            // TODO: CustomEventTrace
            #if canImport(SwiftUI, _underlyingVersion: 6.0.87) && _OPENSWIFTUI_SWIFTUI_RENDER
            let renderedTime = renderer.swiftUI_renderAsync(
                to: list,
                time: time,
                nextTime: nextTime,
                targetTimestamp: targetTimestamp,
                version: version,
                maxVersion: maxVersion
            )
            #else
            let renderedTime = renderer.renderAsync(
                to: list,
                time: time,
                nextTime: nextTime,
                targetTimestamp: targetTimestamp,
                version: version,
                maxVersion: maxVersion
            )
            #endif
            if let renderedTime {
                return renderedTime
            } else {
                var renderedTime = nextTime
                Update.syncMain {
                    renderedTime = renderOnMainThread()
                }
                return renderedTime
            }
        } else {
            return renderOnMainThread()
        }
    }

    package func advanceTimeForTest(interval: Double) {
        precondition(
            interval >= 0,
            "Test render timestamps must monotonically increase."
        )
        let advancedTime = currentTimestamp + interval
        currentTimestamp = advancedTime == currentTimestamp ? Time(seconds: nextafter(advancedTime.seconds, Double.infinity)) : advancedTime
    }
    
    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public func preferenceValue<K>(_ key: K.Type) -> K.Value where K: HostPreferenceKey {
        updateViewGraph { graph in
            graph.preferenceValue(key)
        }
    }
    
    package func idealSize() -> CGSize {
        sizeThatFits(.unspecified)
    }
    
    package func sizeThatFits(_ proposal: _ProposedSize) -> CGSize {
        updateViewGraph { $0.sizeThatFits(proposal) }
    }
    package func explicitAlignment(of guide: HorizontalAlignment, at size: CGSize) -> CGFloat? {
        updateViewGraph { $0.explicitAlignment(of: guide, at: size) }
    }
    
    package func explicitAlignment(of guide: VerticalAlignment, at size: CGSize) -> CGFloat? {
        updateViewGraph { $0.explicitAlignment(of: guide, at: size) }
    }
    
    package func alignment(of guide: HorizontalAlignment, at size: CGSize) -> CGFloat {
        updateViewGraph { $0.alignment(of: guide, at: size) }
    }
    
    package func alignment(of guide: VerticalAlignment, at size: CGSize) -> CGFloat {
        updateViewGraph { $0.alignment(of: guide, at: size) }
    }
    
    package var centersRootView: Bool {
        get { viewGraph.centersRootView }
        set { viewGraph.centersRootView = newValue }
    }

    package var responderNode: ResponderNode? {
        updateViewGraph { $0.rootResponders?.first }
    }
    
    package var isRootHost: Bool {
        guard let bridge = viewGraph.preferenceBridge else {
            return true
        }
        return bridge.viewGraph == nil
    }
    
    private var enclosingHosts: [any ViewRendererHost] {
        guard let preferenceBridge = viewGraph.preferenceBridge,
              let parentViewGraph = preferenceBridge.viewGraph,
              let parentHost = parentViewGraph as? ViewRendererHost
        else {
            return [self]
        }
        var hosts = parentHost.enclosingHosts
        hosts.append(self)
        return hosts
    }

    package func performExternalUpdate(_ update: () -> Void) {
        Update.assertIsLocked()
        for host in enclosingHosts {
            host.externalUpdateCount += 1
        }
        update()
        for host in enclosingHosts {
            precondition(
                host.externalUpdateCount >= 1,
                "Unbalanced will/did update functions."
            )
            host.externalUpdateCount -= 1
        }
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

// MARK: - ViewRendererHost + Gesture [6.5.4]

package let hostingViewCoordinateSpace: CoordinateSpace.ID = .init()

extension ViewRendererHost {
    package var nextGestureUpdateTime: Time {
        viewGraph.nextUpdate.gestures.time
    }

    package func sendEvents(
        _ events: [EventID : any EventType],
        rootNode: ResponderNode,
        at time: Time
    ) -> GesturePhase<Void> {
        viewGraph.sendEvents(events, rootNode: rootNode, at: time)
    }

    package func resetEvents() {
        viewGraph.resetEvents()
    }

    package func gestureCategory() -> GestureCategory? {
        viewGraph.gestureCategory
    }

    package func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {
        viewGraph.inheritedPhase = phase
    }
}

extension ViewRendererHost {
    package func sendTestEvents(_ events: [EventID : any EventType]) {
        guard let eventGraphHost = self.as(EventGraphHost.self) else {
            return
        }
        eventGraphHost.eventBindingManager.send(events)
    }

    package func resetTestEvents() {
        guard let eventGraphHost = self.as(EventGraphHost.self) else {
            return
        }
        eventGraphHost.eventBindingManager.reset(resetForwardedEventDispatchers: false)
    }
}

// MARK: - ViewGraph + viewRendererHost

extension ViewGraph {
    package static var viewRendererHost: (any ViewRendererHost)? {
        ViewGraph.current.delegate as? ViewRendererHost
    }
}

// MARK: - EnvironmentValues + PreferenceBridge

extension EnvironmentValues {
    private struct PreferenceBridgeKey: EnvironmentKey {
        struct Value {
            weak var value: PreferenceBridge?
        }
        static let defaultValue: Value = Value()
    }
    
    package var preferenceBridge: PreferenceBridge? {
        get { self[PreferenceBridgeKey.self].value }
        set { self[PreferenceBridgeKey.self].value = newValue }
    }
}

// MARK: - ViewRendererHost + rootContentPath

extension ViewRendererHost {
    package func rootContentPath(kind: ContentShapeKinds) -> Path {
        guard let responderNode,
              let viewResponder = responderNode as? ViewResponder
        else { return Path() }
        var path = Path()
        viewResponder.addContentPath(to: &path, kind: kind, in: .root, observer: nil)
        return path
    }
}

// MARK: - ViewRendererHost + Graph

extension ViewRendererHost {
    package func startProfiling() {
        viewGraph.graph.startProfiling()
    }
    
    package func stopProfiling() {
        viewGraph.graph.stopProfiling()
    }
    
    package func resetProfile() {
        viewGraph.graph.resetProfile()
    }
    
    package func archiveJSON(name: String? = nil) {
        viewGraph.graph.archiveJSON(name: name)
    }
}
