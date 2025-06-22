//
//  ViewRendererHost.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 76C8A4B3FC8EE0F99045B3425CD62255

package import Foundation
import OpenGraphShims

// MARK: - ViewRendererHostProperties

package struct ViewRendererHostProperties: OptionSet {
    package let rawValue: UInt16
    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    package static let rootView: ViewRendererHostProperties = .init(rawValue: 1 << 0)
    package static let environment: ViewRendererHostProperties = .init(rawValue: 1 << 1)
    package static let focusedValues: ViewRendererHostProperties = .init(rawValue: 1 << 2)
    package static let transform: ViewRendererHostProperties = .init(rawValue: 1 << 3)
    package static let size: ViewRendererHostProperties = .init(rawValue: 1 << 4)
    package static let safeArea: ViewRendererHostProperties = .init(rawValue: 1 << 5)
    package static let scrollableContainerSize: ViewRendererHostProperties = .init(rawValue: 1 << 6)
    package static let focusStore: ViewRendererHostProperties = .init(rawValue: 1 << 7)
    package static let accessibilityFocusStore: ViewRendererHostProperties = .init(rawValue: 1 << 8)
    package static let focusedItem: ViewRendererHostProperties = .init(rawValue: 1 << 9)
    package static let accessibilityFocus: ViewRendererHostProperties = .init(rawValue: 1 << 10)
    package static let all: ViewRendererHostProperties  = [.rootView, .environment, .focusedValues, .transform, .size, .safeArea, .scrollableContainerSize, .focusStore, .accessibilityFocusStore, .focusedItem, .accessibilityFocus]
}

// MARK: - ViewRenderingPhase

package enum ViewRenderingPhase {
    case none
    case rendering
    case renderingAsync
}

@available(*, unavailable)
extension ViewRenderingPhase: Sendable {}

// MARK: - ViewRendererHost

package protocol ViewRendererHost: ViewGraphDelegate {
    var viewGraph: ViewGraph { get }
    var currentTimestamp: Time { get set }
    var propertiesNeedingUpdate: ViewRendererHostProperties { get set }
    var renderingPhase: ViewRenderingPhase { get set }
    var externalUpdateCount: Int { get set }
    func updateRootView()
    func updateEnvironment()
    func updateFocusedItem()
    func updateFocusedValues()
    func updateTransform()
    func updateSize()
    func updateSafeArea()
    func updateScrollableContainerSize()
    func updateFocusStore()
    func updateAccessibilityFocus()
    func updateAccessibilityFocusStore()
    func updateAccessibilityEnvironment()
    func renderDisplayList(_ list: DisplayList, asynchronously: Bool, time: Time, nextTime: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time
    func didRender()
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
        Update.begin()
        defer { Update.end() }
        return Graph.withoutUpdate {
            updateGraph()
            return body(viewGraph)
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
    
    package func didRender() {}
    
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
    
    package func updateTransform() {
        // Blocked by ValueState
        // viewGraph.$rootTransform.valueState
        // preconditionFailure("TODO")
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
        preconditionFailure("TODO")
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
        preconditionFailure("TODO")
    }
    
    package func explicitAlignment(of guide: VerticalAlignment, at size: CGSize) -> CGFloat? {
        preconditionFailure("TODO")
    }
    
    package func alignment(of guide: HorizontalAlignment, at size: CGSize) -> CGFloat {
        preconditionFailure("TODO")
    }
    
    package func alignment(of guide: VerticalAlignment, at size: CGSize) -> CGFloat {
        preconditionFailure("TODO")
    }
    
    package var centersRootView: Bool {
        get { viewGraph.centersRootView }
        set { viewGraph.centersRootView = newValue }
    }
    
//    package var responderNode: ResponderNode? {
//        preconditionFailure("TODO")
//    }
    
    package var isRootHost: Bool {
        guard let bridge = viewGraph.preferenceBridge else {
            return true
        }
        return bridge.viewGraph == nil
    }
    
    private var enclosingHosts: [ViewRendererHost] { preconditionFailure("TODO") }
    package func performExternalUpdate(_ update: () -> Void) { preconditionFailure("TODO") }
    package func updateFocusedItem() {}
    package func updateFocusedValues() {}
    package func updateFocusStore() {}
    package func updateAccessibilityFocus() {}
    package func updateAccessibilityFocusStore() {}
    package func updateAccessibilityEnvironment() {}
}

// MARK: - ViewRendererHost + Gesture [TODO]

package let hostingViewCoordinateSpace: CoordinateSpace.ID = .init()

//extension ViewRendererHost {
//    package var nextGestureUpdateTime: Time {
//        get
//    }
//    package func sendEvents(_ events: [EventID : any EventType], rootNode: ResponderNode, at time: Time) -> GesturePhase<Void>
//    package func resetEvents()
//    package func gestureCategory() -> GestureCategory?
//    package func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase)
//}

extension ViewRendererHost {
    package func sendTestEvents(_ events: [EventID : any EventType]) {
        preconditionFailure("TODO")
    }

    package func resetTestEvents() {
        preconditionFailure("TODO")
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

// MARK: - ViewRendererHost + rootContentPath [TODO]

extension ViewRendererHost {
    package func rootContentPath(kind: ContentShapeKinds) -> Path {
        preconditionFailure("TODO")
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
