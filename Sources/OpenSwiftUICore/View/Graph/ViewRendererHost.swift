//
//  ViewRendererHost.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 76C8A4B3FC8EE0F99045B3425CD62255 (SwiftUICore)

package import Foundation
import OpenGraphShims

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
            "",
            [
                viewGraph.graph.counter(for: ._4), // FIXME: UInt
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
            "",
            [
                viewGraph.graph.counter(for: ._4), // FIXME: UInt
                UInt(bitPattern: Unmanaged.passUnretained(self).toOpaque()),
            ]
        )
        #endif
    }
    
    package static func makeRootView<V>(_ view: V) -> ModifiedContent<V, HitTestBindingModifier> where V: View {
        view.modifier(HitTestBindingModifier())
    }
    
    @_spi(ForOpenSwiftUIOnly)
    public func updateViewGraph<T>(body: (ViewGraph) -> T) -> T {
        Update.perform {
            Graph.withoutUpdate {
                updateGraph()
                return body(viewGraph)
            }
        }
    }
    
    @_spi(ForOpenSwiftUIOnly)
    public func graphDidChange() {
        Update.locked {
            if !isRendering {
                requestUpdate(after: .zero)
            }
        }
    }

    @_spi(ForOpenSwiftUIOnly)
    public func preferencesDidChange() {}
    
    package func invalidateProperties(_ props: ViewRendererHostProperties, mayDeferUpdate: Bool = true) {
        Update.locked {
            guard !propertiesNeedingUpdate.contains(props) else {
                return
            }
            propertiesNeedingUpdate.insert(props)
            viewGraph.setNeedsUpdate(mayDeferUpdate: mayDeferUpdate)
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
                propertiesNeedingUpdate.remove(.rootView)
                updateEnvironment()
            }
            if properties.contains(.focusedValues) {
                propertiesNeedingUpdate.remove(.focusedValues)
                updateFocusedValues()
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
            if properties.contains(.scrollableContainerSize) {
                propertiesNeedingUpdate.remove(.scrollableContainerSize)
                updateScrollableContainerSize()
            }
            if properties.contains(.focusStore) {
                propertiesNeedingUpdate.remove(.focusStore)
                updateFocusStore()
            }
            if properties.contains(.accessibilityFocusStore) {
                propertiesNeedingUpdate.remove(.accessibilityFocusStore)
                updateAccessibilityFocusStore()
            }
            if properties.contains(.focusedItem) {
                propertiesNeedingUpdate.remove(.focusedItem)
                updateFocusedItem()
            }
            if properties.contains(.accessibilityFocus) {
                propertiesNeedingUpdate.remove(.accessibilityFocus)
                updateAccessibilityFocus()
            }
        }
    }
    

    
    package func render(interval: Double = 0, updateDisplayList: Bool = true, targetTimestamp: Time? = nil) {
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
            
            var displayList: DisplayList = .init()
            var version: DisplayList.Version = .init()
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
                        shouldContinue = shouldContinue && viewGraph.globalSubgraph.isDirty(1)
                    }
                    guard shouldContinue else {
                        break
                    }
                } while true
            }
            var nextTime = viewGraph.nextUpdate.views.time
            if updateDisplayList {
                let maxVersion = DisplayList.Version(forUpdate: ())
                nextTime = renderDisplayList(
                    displayList,
                    asynchronously:false,
                    time: time,
                    nextTime: nextTime,
                    targetTimestamp: targetTimestamp,
                    version: version,
                    maxVersion: maxVersion
                )
            }
            renderingPhase = .none
            if nextTime.seconds.isFinite {
                let delay = max(nextTime.seconds, time.seconds) - time.seconds
                requestUpdate(after: max(delay, 1e-6))
            }
        }
    }
    
    package func renderAsync(interval: Double = 0, targetTimestamp: Time?) -> Time? {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func advanceTimeForTest(interval: Double) {
        guard interval >= 0 else {
            preconditionFailure("Test render timestamps must monotonically increase.")
        }
        let advancedTime = currentTimestamp + interval
        currentTimestamp = advancedTime == currentTimestamp ? Time(seconds: nextafter(advancedTime.seconds, Double.infinity)) : advancedTime
    }
    
    @_spi(Private)
    public func preferenceValue<K>(_ key: K.Type) -> K.Value where K: HostPreferenceKey {
        updateViewGraph { graph in
            graph.preferenceValue(key)
        }
    }
    
    package func idealSize() -> CGSize {
        sizeThatFits(.unspecified)
    }
    
    package func sizeThatFits(_ proposal: _ProposedSize) -> CGSize {
        updateViewGraph { graph in
            // FIXME:
            // graph.sizeThatFits(proposal, layoutComputer: layoutComputer, insets: rootViewInsets)
            CGSize.zero
        }
    }
    package func explicitAlignment(of guide: HorizontalAlignment, at size: CGSize) -> CGFloat? {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func explicitAlignment(of guide: VerticalAlignment, at size: CGSize) -> CGFloat? {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func alignment(of guide: HorizontalAlignment, at size: CGSize) -> CGFloat {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func alignment(of guide: VerticalAlignment, at size: CGSize) -> CGFloat {
        _openSwiftUIUnimplementedFailure()
    }
    
    package var centersRootView: Bool {
        get { viewGraph.centersRootView }
        set { viewGraph.centersRootView = newValue }
    }

    package var responderNode: ResponderNode? {
        updateViewGraph { viewGraph in
            viewGraph.rootResponders?.first
        }
    }

    package func updateTransform() {
        // Blocked by ValueState
        // viewGraph.$rootTransform.valueState
        _openSwiftUIUnimplementedWarning()
    }
    
    package var isRootHost: Bool {
        guard let bridge = viewGraph.preferenceBridge else {
            return true
        }
        return bridge.viewGraph == nil
    }
    
    private var enclosingHosts: [ViewRendererHost] {
        _openSwiftUIUnimplementedFailure()
    }

    package func performExternalUpdate(_ update: () -> Void) {
        Update.assertIsLocked()
        for host in enclosingHosts {
            host.externalUpdateCount += 1
        }
        update()
        for host in enclosingHosts {
            guard host.externalUpdateCount >= 1 else {
                preconditionFailure("Unbalanced will/did update functions.")
            }
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

// MARK: - ViewGraph + viewRendererHost [6.5.4]

extension ViewGraph {
    package static var viewRendererHost: (any ViewRendererHost)? {
        ViewGraph.current.delegate as? ViewRendererHost
    }
}

// MARK: - EnvironmentValues + PreferenceBridge [6.5.4]

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

// MARK: - ViewRendererHost + rootContentPath [6.5.4]

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

// MARK: - ViewRendererHost + Graph [TODO]

extension ViewRendererHost {
    package func startProfiling() {
        Graph.startProfiling(viewGraph.graph)
    }
    
    package func stopProfiling() {
        Graph.stopProfiling(viewGraph.graph)
    }
    
    package func resetProfile() {
        // Graph.resetProfile(viewGraph.graph)
    }
    
    package func archiveJSON(name: String? = nil) {
        // viewGraph.graph.archiveJSON(name: name)
    }
}
