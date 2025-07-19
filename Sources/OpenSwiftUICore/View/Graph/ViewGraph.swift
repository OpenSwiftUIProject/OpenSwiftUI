//
//  ViewGraph.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: D63C4EB7F2B205694B6515509E76E98B (SwiftUI)
//  ID: 7D9EDEF832940A362646A6E979F296C8 (SwiftUICore)

package import OpenGraphShims
#if canImport(Darwin)
import Foundation
#else
package import Foundation
#endif
import OpenSwiftUI_SPI

package final class ViewGraph: GraphHost {
    package struct Outputs: OptionSet {
        package let rawValue: UInt8
        
        package init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        package static let displayList: ViewGraph.Outputs = .init(rawValue: 1 << 0)
        package static let platformItemList: ViewGraph.Outputs = .init(rawValue: 1 << 1)
        package static let viewResponders: ViewGraph.Outputs = .init(rawValue: 1 << 2)
        package static let layout: ViewGraph.Outputs = .init(rawValue: 1 << 4)
        package static let focus: ViewGraph.Outputs = .init(rawValue: 1 << 5)
        package static let all: ViewGraph.Outputs = .init(rawValue: 0xFF)
        package static let defaults: ViewGraph.Outputs = [.displayList, .viewResponders, .layout, .focus]
        
        @inline(__always)
        fileprivate func addRequestedPreferences(to inputs: inout _ViewInputs) {
            inputs.preferences.add(HostPreferencesKey.self)
            if contains(.displayList) {
                inputs.preferences.requiresDisplayList = true
            }
            if contains(.viewResponders) {
                inputs.preferences.requiresViewResponders = true
            }
        }
    }
    
    let rootViewType: Any.Type
    let makeRootView: (AnyAttribute, _ViewInputs) -> _ViewOutputs
    
    package weak var delegate: (any ViewGraphDelegate)? = nil
    
    private var features: ViewGraphFeatureBuffer = .init(contents: .init())
    
    package var centersRootView: Bool = true
    
    package let rootView: AnyAttribute
    
    @Attribute var rootTransform: ViewTransform
    @Attribute package var transform: ViewTransform
    @Attribute package var zeroPoint: ViewOrigin
    @Attribute package var proposedSize: ViewSize
    @Attribute package var safeAreaInsets: _SafeAreaInsetsModifier
    
    @Attribute var rootGeometry: ViewGeometry
    @Attribute var position: ViewOrigin
    @Attribute var dimensions: ViewSize
    
    @OptionalAttribute var scrollableContainerSize: ViewSize?
    
    @Attribute var gestureTime: Time
    // @Attribute var gestureEvents: [EventID : EventType]
    // @Attribute var inheritedPhase: _GestureInputs.InheritedPhase
    @Attribute var gestureResetSeed: UInt32
    // @OptionalAttribute var rootPhase: GesturePhase<Void>?
    // @OptionalAttribute package var gestureDebug: GestureDebug.Data?
    // @OptionalAttribute package var gestureCategory: GestureCategory?
    @Attribute package var gesturePreferenceKeys: PreferenceKeys
    var eventSubgraph: Subgraph?
    
    @Attribute package var defaultLayoutComputer: LayoutComputer
    @WeakAttribute var rootResponders: [ViewResponder]?
    @WeakAttribute var rootLayoutComputer: LayoutComputer?
    @WeakAttribute var rootDisplayList: (DisplayList, DisplayList.Version)?
    
    // package var sizeThatFitsObservers: ViewGraphGeometryObservers<SizeThatFitsMeasurer> = .init()
    
    package var accessibilityEnabled: Bool = false
    
    package var requestedOutputs: Outputs
    var disabledOutputs: Outputs = []
    
    private var mainUpdates: Int = 0
    
    // MARK: - ViewGraph + NextUpdate
    
    package struct NextUpdate {
        package private(set) var time: Time = .infinity
        private var _interval: Double = .infinity
        package var interval: Double {
            _interval.isFinite ? .zero : _interval
        }
        package private(set) var reasons: Set<UInt32> = []
        
        package mutating func at(_ next: Time) {
            time = next < time ? next : time
        }
        
        package mutating func maxVelocity(_ velocity: CGFloat) {
            guard velocity >= 160 else {
                return
            }
            let interval = velocity < 320 ? 1 / 80.0 : 1 / 120.0
            let highFrameRateReason: UInt32 = _HighFrameRateReasonMake(0)
            _interval = min(interval, _interval)
            reasons.insert(highFrameRateReason)
        }
        
        package mutating func interval(_ interval: Double, reason: UInt32? = nil) {
            if interval == .zero {
                if _interval > 1 / 60 {
                    _interval = .infinity
                }
            } else {
                _interval = min(interval, _interval)
            }
            if let reason {
                reasons.insert(reason)
            }
        }
    }
    
    package var nextUpdate: (views: NextUpdate, gestures: NextUpdate) = (NextUpdate(), NextUpdate())
    
    private weak var _preferenceBridge: PreferenceBridge?
    
    package var preferenceBridge: PreferenceBridge? {
        get { _preferenceBridge }
        set { setPreferenceBridge(to: newValue) }
    }

    var bridgedPreferences: [(any PreferenceKey.Type, AnyAttribute)] = []

    package static var current: ViewGraph { GraphHost.currentHost as! ViewGraph }
    
    package init<Root>(rootViewType: Root.Type = Root.self, requestedOutputs: ViewGraph.Outputs = Outputs.defaults) where Root: View {
        self.rootViewType = rootViewType
        self.requestedOutputs = requestedOutputs
        let data = GraphHost.Data()
        Subgraph.current = data.globalSubgraph
        rootView = Attribute(type: Root.self).identifier
        _rootTransform = Attribute(RootTransform())
        _transform = _rootTransform
        _zeroPoint = Attribute(value: ViewOrigin())
        _proposedSize = Attribute(value: .zero)
        _scrollableContainerSize = requestedOutputs.contains(.layout) ? OptionalAttribute(Attribute(value: .zero)) : OptionalAttribute()
        _safeAreaInsets = Attribute(value: _SafeAreaInsetsModifier(elements: [.init(regions: .container, insets: .zero)]))
        _defaultLayoutComputer = Attribute(value: .defaultValue)
        _gestureTime = Attribute(value: .zero)
        // _gestureEvents
        // _inheritedPhase
        _gestureResetSeed = Attribute(value: .zero)
        _gesturePreferenceKeys = Attribute(value: .init())
        _rootGeometry = Attribute(RootGeometry(
            proposedSize: _proposedSize,
            safeAreaInsets: OptionalAttribute(_safeAreaInsets)
        ))
        _position = _rootGeometry.origin()
        _dimensions = _rootGeometry.size()
        makeRootView = { [_zeroPoint, _proposedSize, _safeAreaInsets] view, inputs in
            var zeroInputs = inputs
            zeroInputs.position = _zeroPoint
            zeroInputs.containerPosition = _zeroPoint
            zeroInputs.size = _proposedSize
            return _SafeAreaInsetsModifier.makeDebuggableView(
                modifier: _GraphValue(_safeAreaInsets),
                inputs: zeroInputs
            ) { _, insetsInputs in
                var modifiedInputs = insetsInputs
                modifiedInputs.position = inputs.position
                modifiedInputs.containerPosition = inputs.containerPosition
                modifiedInputs.size = inputs.size
                return Root.makeDebuggableView(
                    view: _GraphValue(Attribute(identifier: view)),
                    inputs: modifiedInputs
                )
            }
        }
        super.init(data: data)
        Subgraph.current = nil
    }
    
    deinit {
        // FIXME
        removePreferenceOutlets(isInvalidating: true)
        features.contents.destroy()
    }
        
    override package var graphDelegate: GraphDelegate? { delegate }
    
    override package var parentHost: GraphHost? { preferenceBridge?.viewGraph }
    
    package func append<T>(feature: T) where T: ViewGraphFeature {
        features.append(feature)
    }
    
    package subscript<T>(feature: T.Type) -> UnsafeMutablePointer<T>? where T: ViewGraphFeature {
        features[feature]
    }

    override package func instantiateOutputs() {
        let outputs = globalSubgraph.apply {
            // Audited for 6.5.4
            var inputs = _ViewInputs(
                graphInputs,
                position: $position,
                size: $dimensions,
                transform: $transform,
                containerPosition: $zeroPoint,
                hostPreferenceKeys: data.$hostPreferenceKeys
            )
            if requestedOutputs.contains(.layout) {
                inputs.base.options.formUnion([.viewRequestsLayoutComputer, .viewNeedsGeometry])
                inputs.scrollableContainerSize = _scrollableContainerSize
            }
            requestedOutputs.addRequestedPreferences(to: &inputs)
            if let preferenceBridge {
                preferenceBridge.wrapInputs(&inputs)
            }
            _ViewDebug.initialize(inputs: &inputs)
            if inputs.needsGeometry {
                // inputs.makeRootMatchedGeometryScope()
            }
            inputs.base.pushStableType(rootViewType)
            $rootGeometry.mutateBody(
                as: RootGeometry.self,
                invalidating: true
            ) { rootGeometry in
                rootGeometry.$layoutDirection = inputs.layoutDirection
            }
            for feature in features {
                feature.modifyViewInputs(inputs: &inputs, graph: self)
            }
            var outputs = makeRootView(rootView, inputs)
            for feature in features {
                feature.modifyViewOutputs(outputs: &outputs, inputs: inputs, graph: self)
            }
            return outputs
        }
        $rootGeometry.mutateBody(
            as: RootGeometry.self,
            invalidating: true
        ) { rootGeometry in
            rootGeometry.$childLayoutComputer = outputs.layoutComputer
        }
        if requestedOutputs.contains(.displayList) {
            if let displayList = outputs.preferences.displayList {
                _rootDisplayList = WeakAttribute(rootSubgraph.apply {
                    Attribute(RootDisplayList(content: displayList, time: data.$time))
                })
            }
        }
        if requestedOutputs.contains(.viewResponders) {
            _rootResponders = WeakAttribute(outputs.preferences.viewResponders)
        }
        if requestedOutputs.contains(.layout) {
            _rootLayoutComputer = WeakAttribute(outputs.layoutComputer)
        }
        hostPreferenceValues = WeakAttribute(outputs.preferences[HostPreferencesKey.self])
        makePreferenceOutlets(outputs: outputs)
    }
    
    override package func uninstantiateOutputs() {
        removePreferenceOutlets(isInvalidating: false)
        for feature in features {
            feature.uninstantiate(graph: self)
        }
        $rootGeometry.mutateBody(
            as: RootGeometry.self,
            invalidating: true
        ) { rootGeometry in
            rootGeometry.$childLayoutComputer = nil
            rootGeometry.$layoutDirection = nil
        }
        $rootLayoutComputer = nil
        $rootResponders = nil
        $rootDisplayList = nil
        hostPreferenceValues = WeakAttribute()
    }
    
    override package func timeDidChange() {
        nextUpdate.views = NextUpdate()
    }
    
    override package func isHiddenForReuseDidChange() {
        _openSwiftUIUnimplementedFailure()
    }
    
    private func makePreferenceOutlets(outputs: _ViewOutputs) {
        // TODO
    }
    
    @inline(__always)
    private func removePreferenceOutlets(isInvalidating: Bool) {
        // TODO
    }

    // FIXME
    package func updatePreferenceBridge(
        environment: EnvironmentValues,
        deferredUpdate: () -> Void
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ViewGraph {
    package func setRootView<Root>(_ view: Root) where Root: View {
        @Attribute(identifier: rootView)
        var rootView: Root
        rootView = view
    }
    
    package func setSize(_ size: ViewSize) {
        let hasChange = $proposedSize.setValue(size)
        if hasChange {
            delegate?.graphDidChange()
        }
    }
    
    package func setProposedSize(_ size: CGSize) {
        let hasChange = $proposedSize.setValue(ViewSize.fixed(size))
        if hasChange {
            delegate?.graphDidChange()
        }
    }
    
    package var size: ViewSize {
        proposedSize
    }
    
    @discardableResult
    package func setSafeAreaInsets(_ insets: EdgeInsets) -> Bool {
        setSafeAreaInsets([.init(regions: .container, insets: insets)])
    }
    
    @discardableResult
    package func setSafeAreaInsets(_ elts: [SafeAreaInsets.Element]) -> Bool {
        let hasChange = $safeAreaInsets.setValue(.init(elements: elts))
        if hasChange {
            delegate?.graphDidChange()
        }
        return hasChange
    }
    
    package func setScrollableContainerSize(_ size: ViewSize) {
        guard let $scrollableContainerSize else {
            return
        }
        let hasChange = $scrollableContainerSize.setValue(size)
        if hasChange {
            delegate?.graphDidChange()
        }
    }
    
    @discardableResult
    package func invalidateTransform() -> Bool {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ViewGraph {
    package var updateRequiredMainThread: Bool {
        graph.mainUpdates != mainUpdates
    }
    
    package func updateOutputs(at time: Time) {
        beginNextUpdate(at: time)
        updateOutputs(async: false)
    }
    
    package func updateOutputsAsync(at time: Time) -> (list: DisplayList, version: DisplayList.Version)? {
        beginNextUpdate(at: time)
        _openSwiftUIUnimplementedFailure()
    }
    
    package func displayList() -> (DisplayList, DisplayList.Version) {
        _openSwiftUIUnimplementedFailure()
    }
    
    private func beginNextUpdate(at time: Time) {
        setTime(time)
        data.updateSeed &+= 1
        mainUpdates = graph.mainUpdates
    }
    
    // FIXME
    private func updateOutputs(async: Bool) {
        instantiateIfNeeded()
        
        // let oldCachedSizeThatFits = cachedSizeThatFits
        
        var preferencesChanged = false
        var observedSizeThatFitsChanged = false
        var updatedOutputs: Outputs = []
        
        var counter1 = 0
        repeat {
            counter1 &+= 1
            inTransaction = true
            var counter2 = 0
            repeat {
                let conts = continuations
                continuations = []
                for continuation in conts {
                    continuation()
                }
                counter2 &+= 1
                data.globalSubgraph.update(flags: .active)
            } while (continuations.count != 0 && counter2 != 8)
            inTransaction = false
            preferencesChanged = preferencesChanged || updatePreferences()
            observedSizeThatFitsChanged = observedSizeThatFitsChanged || updateObservedSizeThatFits()
            updatedOutputs.formUnion(updateRequestedOutputs())
        } while (data.globalSubgraph.isDirty(1) && counter1 != 8)
        
//        guard preferencesChanged || observedSizeThatFitsChanged || !updatedOutputs.isEmpty || needsFocusUpdate else {
//            return
//        }
//        if Thread.isMainThread {
//            if preferencesChanged {
//                delegate?.preferencesDidChange()
//            }
//            if observedSizeThatFitsChanged {
//                sizeThatFitsObserver?.callback(oldCachedSizeThatFits, self.cachedSizeThatFits)
//            }
//            if !requestedOutputs.isEmpty {
////                delegate?.outputsDidChange(outputs: updatedOutputs)
//            }
//            if needsFocusUpdate {
//                needsFocusUpdate = false
////                delegate?.focusDidChange()
//            }
//        } else {
//            _openSwiftUIUnimplementedFailure()
//        }
//        mainUpdates &-= 1
    }
    
    private func updateObservedSizeThatFits() -> Bool {
        // TODO
        return false
    }
    
    private func updateRequestedOutputs() -> Outputs {
        // TODO
        return []
    }
}

//package struct SizeThatFitsMeasurer: ViewGraphGeometryMeasurer {
//    package static func measure(given proposal: _ProposedSize, in graph: ViewGraph) -> CGSize
//    package static let invalidValue: CGSize
//    package typealias Proposal = _ProposedSize
//    package typealias Size = CGSize
//}

//package typealias SizeThatFitsObservers = ViewGraphGeometryObservers<SizeThatFitsMeasurer>
extension ViewGraph {
    package func sizeThatFits(_ proposal: _ProposedSize) -> CGSize {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func explicitAlignment(of guide: VerticalAlignment, at size: CGSize) -> CGFloat? {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func explicitAlignment(of guide: HorizontalAlignment, at size: CGSize) -> CGFloat? {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func alignment(of guide: VerticalAlignment, at size: CGSize) -> CGFloat {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func alignment(of guide: HorizontalAlignment, at size: CGSize) -> CGFloat {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func viewDebugData() -> [_ViewDebug.Data] {
        _ViewDebug.makeDebugData(subgraph: rootSubgraph)
    }
}

extension ViewGraph {
    package func invalidatePreferenceBridge() {
        setPreferenceBridge(to: nil, isInvalidating: true)
    }
    
    @inline(__always)
    private func setPreferenceBridge(to preferenceBridge: PreferenceBridge?, isInvalidating: Bool = false) {
        guard _preferenceBridge !== preferenceBridge else { return }
        if let preferenceBridge = _preferenceBridge {
            for (src, key) in bridgedPreferences {
                preferenceBridge.removeValue(key, for: src, isInvalidating: isInvalidating)
            }
            bridgedPreferences = []
            preferenceBridge.removeHostValues(for: data.$hostPreferenceKeys, isInvalidating: isInvalidating)
            preferenceBridge.removeChild(self)
        }
        _preferenceBridge = nil
        if isInstantiated {
            uninstantiate(immediately: isInvalidating)
        }
        _preferenceBridge = preferenceBridge
        if let preferenceBridge = _preferenceBridge {
            preferenceBridge.addChild(self)
        }
        updateRemovedState()
    }
}



// MARK: - RootGeometry

/// Calculates the geometry of the root view within the proposed size.
///
/// `RootGeometry` is responsible for:
/// - Computing the size that fits the content based on layout preferences
/// - Determining the origin of the content, applying centering if needed
/// - Handling right-to-left layout direction adjustments
/// - Applying safe area insets to the available space
///
/// The diagram below illustrates how the geometry is calculated:
///
/// ```
/// |←--------------------------proposedSize.value.width--------------------------→|  (0, 0)
/// ┌──────────────────────────────────────────────────────────────────────────────┐  ┌─────────> x
/// │     (x: insets.leading, y: insets.top)                                       |  │
/// │     ↓                                                                        |  |
/// |     |←--------------------------proposal.width--------------------------→|   |  |
/// │     ┌────────────┬───────────────────────────────────────────────────────┐   |  |
/// │     |████████████|                                                       |   │  ↓ y
/// │     |████████████|                                                       |   │  
/// │     ├────────────┘                                                       │   |  
/// |     |←----------→|                                                       |   |  
/// │     |fittingSize.width                                                   |   |  
/// │     |                                                                    |   │  
/// |     |                                                                    |   |  
/// |     |                                                                    |   |  
/// |     |                                                                    |   |  
/// │     |        centersRootView == true:                                    │   |  
/// │     |        origin = insets + (proposal - fittingSize) * 0.5            │   |  
/// │     |                                                                    |   │  
/// │     |        centersRootView == false:                                   |   │  
/// │     |        origin = (insets.leading, insets.top)                       |   │  
/// │     |                                                                    |   │  
/// │     |        If layoutDirection == .rightToLeft:                         |   │  
/// │     |        origin.x is flipped to keep visual order consistent         |   │  
/// │     |                                                                    |   │  
/// │     └────────────────────────────────────────────────────────────────────┘   |  
/// |                                                                              |  
/// └──────────────────────────────────────────────────────────────────────────────┘  
/// ```
package struct RootGeometry: Rule, AsyncAttribute {
    /// The layout direction to apply to the root view.
    ///
    /// When set to `.rightToLeft`, the x-coordinate will be adjusted to maintain
    /// proper visual alignment from the right edge.
    @OptionalAttribute
    package var layoutDirection: LayoutDirection?

    /// The proposed size for the entire view, including any insets.
    @Attribute
    package var proposedSize: ViewSize

    /// Safe area insets to apply to the view.
    ///
    /// These insets define padding from the edges of the proposed size.
    @OptionalAttribute
    package var safeAreaInsets: _SafeAreaInsetsModifier?

    /// The layout computer used to determine the size of the child view.
    @OptionalAttribute
    package var childLayoutComputer: LayoutComputer?

    /// Creates a new root geometry with the specified attributes.
    ///
    /// - Parameters:
    ///   - layoutDirection: The layout direction to apply.
    ///   - proposedSize: The proposed size for the entire view.
    ///   - safeAreaInsets: Safe area insets to apply to the view.
    ///   - childLayoutComputer: The layout computer for determining the child view size.
    package init(
        layoutDirection: OptionalAttribute<LayoutDirection> = .init(),
        proposedSize: Attribute<ViewSize>,
        safeAreaInsets: OptionalAttribute<_SafeAreaInsetsModifier> = .init(),
        childLayoutComputer: OptionalAttribute<LayoutComputer> = .init()
    ) {
        _layoutDirection = layoutDirection
        _proposedSize = proposedSize
        _safeAreaInsets = safeAreaInsets
        _childLayoutComputer = childLayoutComputer
    }

    package var value: ViewGeometry {
        let layoutComputer = childLayoutComputer ?? .defaultValue
        let insets: EdgeInsets
        if let safeAreaInsets {
            var safeAreaInsets = safeAreaInsets.elements.reduce(.zero, { $0 + $1.insets })
            // Apply flipping if needed to convert left/right insets to leading/trailing
            if let layoutDirection {
                safeAreaInsets.xFlipIfRightToLeft { layoutDirection }
            }
            insets = safeAreaInsets
        } else {
            insets = .zero
        }
        let proposal = proposedSize.value.inset(by: insets)
        let fittingSize = layoutComputer.sizeThatFits(.init(proposal))
        // Start with origin at the safe area offset
        var origin = CGPoint(x: insets.leading, y: insets.top)

        // Apply centering if needed
        if ViewGraph.current.centersRootView {
            origin += (proposal-fittingSize) * 0.5
        }

        var geometry = ViewGeometry(
            origin: ViewOrigin(origin),
            dimensions: ViewDimensions(
                guideComputer: layoutComputer,
                size: fittingSize,
                proposal: .init(proposal)
            )
        )
        if let layoutDirection {
            geometry.finalizeLayoutDirection(layoutDirection, parentSize: proposedSize.value)
        }
        return geometry
    }
}

// MARK: - Graph + ViewGraph

extension Graph {
    package func viewGraph() -> ViewGraph {
        unsafeBitCast(context, to: ViewGraph.self)
    }
}

// MARK: - RootTransformProvider

protocol RootTransformProvider {
    func rootTransform() -> ViewTransform
}

// MARK: - RootDisplayList

private struct RootDisplayList: Rule, AsyncAttribute {
    @Attribute var content: DisplayList
    @Attribute var time: Time

    var value: (DisplayList, DisplayList.Version) {
        var displayList = content
        let version = DisplayList.Version(forUpdate: ())
        displayList.applyViewGraphTransform(time: $time, version: version)
        return (content, version)
    }
}

// MARK: - RootTransform [6.5.4]

private struct RootTransform: Rule {
    var value: ViewTransform {
        guard let delegate = ViewGraph.current.delegate,
              let provider = delegate.as(RootTransformProvider.self)
        else {
            return ViewTransform()
        }
        return provider.rootTransform()
    }
}
