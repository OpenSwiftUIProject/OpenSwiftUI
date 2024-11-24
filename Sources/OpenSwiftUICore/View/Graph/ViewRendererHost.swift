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
    func requestUpdate(after delay: Double)
    func renderDisplayList(_ list: DisplayList, asynchronously: Bool, time: Time, nextTime: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time
    func didRender()
}

extension ViewRendererHost {
    package var isRendering: Bool {
        renderingPhase != .none
    }
    
    package func initializeViewGraph() {
        // viewGraph.delegate = self
        // TODO: Signpost related
    }
    
    package func invalidate() {
        // viewGraph.delegate = nil
        // TODO: Signpost.viewHost
        preconditionFailure("TODO")
    }
    
//    package static func makeRootView<V>(_ view: V) -> ModifiedContent<V, HitTestBindingModifier> where V: View
    package static func makeRootView<V: View>(_ view: V) -> some View {
        view/*.modifier(HitTestBindingModifier())*/
    }
    
    @_spi(ForOpenSwiftUIOnly)
    public func updateViewGraph<T>(body: (ViewGraph) -> T) -> T {
        // FIXME
        Update.dispatchImmediately {
            OGGraph.withoutUpdate {
                updateGraph()
                return body(viewGraph)
            }
        }
    }
    
    @_spi(ForOpenSwiftUIOnly)
    public func graphDidChange() {
        preconditionFailure("TODO")
    }
    
    package func didRender() {}
    
    @_spi(ForOpenSwiftUIOnly)
    public func preferencesDidChange() {
        preconditionFailure("TODO")
    }
    
    package func invalidateProperties(_ props: ViewRendererHostProperties, mayDeferUpdate: Bool = true) {
        // FIXME
//        Update.locked {
//            guard !propertiesNeedingUpdate.contains(properties) else {
//                return
//            }
//            propertiesNeedingUpdate.insert(properties)
//            viewGraph.setNeedsUpdate(mayDeferUpdate: mayDeferUpdate)
//            requestUpdate(after: .zero)
//        }
    }
    
    package func updateGraph() {
        // FIXME
        let properties = propertiesNeedingUpdate
        // addImplicitPropertiesNeedingUpdate(to: &properties)
        guard !properties.isEmpty else { return }
        Update.syncMain {
            func update(_ property: ViewRendererHostProperties, body: () -> Void) {
                if properties.contains(property) {
                    propertiesNeedingUpdate.remove(property)
                }
                body()
            }
            update(.rootView) { updateRootView() }
            // TODO:
        }
    }
    
    package func updateTransform() {
        preconditionFailure("TODO")
    }
    
    package func render(interval: Double = 0, updateDisplayList: Bool = true, targetTimestamp: Time? = nil) {
        // FIXME
        Update.dispatchImmediately {
            guard !isRendering else {
                return
            }
            let update = { [self] in
                currentTimestamp += interval
                let time = currentTimestamp
                viewGraph.flushTransactions()
                // Signpost.renderUpdate
                // TODO
                viewGraph.updateOutputs(at: time)
            }
            if Signpost.render.isEnabled {
                // TODO: Signpost related
                update()
            } else {
                update()
            }
        }
    }
    
    package func renderAsync(interval: Double = 0, targetTimestamp: Time?) -> Time? {
        preconditionFailure("TODO")
    }
    
    package func advanceTimeForTest(interval: Double) {
        preconditionFailure("TODO")
    }
    
    @_spi(Private)
    public func preferenceValue<K>(_ key: K.Type) -> K.Value where K: HostPreferenceKey {
        preconditionFailure("TODO")
    }
    
    package func idealSize() -> CGSize { preconditionFailure("TODO") }
    
    package func sizeThatFits(_ proposal: _ProposedSize) -> CGSize {
        preconditionFailure("TODO")
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
        preconditionFailure("TODO")
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

//package let hostingViewCoordinateSpace: CoordinateSpace.ID

//extension ViewRendererHost {
//    package var nextGestureUpdateTime: Time {
//        get
//    }
//    package func sendEvents(_ events: [EventID : any EventType], rootNode: ResponderNode, at time: Time) -> GesturePhase<Void>
//    package func resetEvents()
//    package func gestureCategory() -> GestureCategory?
//    package func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase)
//}

//extension ViewRendererHost {
//    package func sendTestEvents(_ events: [EventID : any EventType])
//    package func resetTestEvents()
//}

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

// MARK: - EmptyViewRendererHost

final package class EmptyViewRendererHost: ViewRendererHost {
    package let viewGraph: ViewGraph
    package var propertiesNeedingUpdate: ViewRendererHostProperties = []
    package var renderingPhase: ViewRenderingPhase = .none
    package var externalUpdateCount: Int = .zero
    package var currentTimestamp: Time = .zero
    package init(environment: EnvironmentValues = EnvironmentValues()) {
        Update.begin()
        viewGraph = ViewGraph(rootViewType: EmptyView.self, requestedOutputs: [])
        viewGraph.setEnvironment(environment)
        initializeViewGraph()
        Update.end()
    }
    package func requestUpdate(after delay: Double) {}
    package func updateRootView() {}
    package func updateEnvironment() {}
    package func updateSize() {}
    package func updateSafeArea() {}
    package func updateScrollableContainerSize() {}
    package func renderDisplayList(_ list: DisplayList, asynchronously: Bool, time: Time, nextTime: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time {
        .infinity
    }
    package func forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {}
}
