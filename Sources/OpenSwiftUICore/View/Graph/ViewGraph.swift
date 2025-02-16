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
            if contains(.platformItemList) {
                inputs.preferences.add(DisplayList.Key.self)
            }
            if contains(.viewResponders) {
                inputs.preferences.add(ViewRespondersKey.self)
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

    var bridgedPreferences: [(AnyPreferenceKey.Type, AnyAttribute)] = []

    package static var current: ViewGraph { GraphHost.currentHost as! ViewGraph }
    
    package init<Root>(rootViewType: Root.Type = Root.self, requestedOutputs: ViewGraph.Outputs = Outputs.defaults) where Root: View {
        self.rootViewType = rootViewType
        self.requestedOutputs = requestedOutputs
        let data = GraphHost.Data()
        OGSubgraph.current = data.globalSubgraph
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
        _rootGeometry = Attribute(RootGeometry(proposedSize: _proposedSize, safeAreaInsets: OptionalAttribute(_safeAreaInsets)))
        _position = _rootGeometry.origin()
        _dimensions = _rootGeometry.size()
        makeRootView = { [_zeroPoint, _proposedSize, _safeAreaInsets] view, inputs in
            // FIXME
            _ = _zeroPoint
            _ = _proposedSize
            return _SafeAreaInsetsModifier.makeDebuggableView(modifier: _GraphValue(_safeAreaInsets), inputs: inputs) { _, inputs in
                let rootView = _GraphValue<Root>(view.unsafeCast(to: Root.self))
                return Root.makeDebuggableView(view: rootView, inputs: inputs)
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
            if _VariableFrameDurationIsSupported() {
                if !inputs.base.options.contains(.supportsVariableFrameDuration) {
                    inputs.base.options.formUnion(.supportsVariableFrameDuration)
                }
            }
            if let delegate {
                delegate.modifyViewInputs(&inputs)
            }
            if inputs.base.options.contains(.viewNeedsGeometry) {
                // inputs.makeRootMatchedGeometryScope()
            }
            inputs.base.pushStableType(rootViewType)
            $rootGeometry.mutateBody(
                as: RootGeometry.self,
                invalidating: true
            ) { rootGeometry in
                rootGeometry.$layoutDirection = inputs.mapEnvironment(\.layoutDirection)
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
            if let displayList = outputs.preferences[DisplayList.Key.self] {
                _rootDisplayList = WeakAttribute(rootSubgraph.apply {
                    Attribute(RootDisplayList(content: displayList, time: data.$time))
                })
            }
        }
        if requestedOutputs.contains(.viewResponders) {
            _rootResponders = WeakAttribute(outputs.preferences[ViewRespondersKey.self])
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
        preconditionFailure("TODO")
    }
    
    private func makePreferenceOutlets(outputs: _ViewOutputs) {
        // TODO
    }
    
    @inline(__always)
    private func removePreferenceOutlets(isInvalidating: Bool) {
        // TODO
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
        preconditionFailure("TODO")
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
        preconditionFailure("TODO")
    }
    
    package func displayList() -> (DisplayList, DisplayList.Version) {
        preconditionFailure("TODO")
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
//            preconditionFailure("TODO")
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
        preconditionFailure("TODO")
    }
    
    package func explicitAlignment(of guide: VerticalAlignment, at size: CGSize) -> CGFloat? {
        preconditionFailure("TODO")
    }
    
    package func explicitAlignment(of guide: HorizontalAlignment, at size: CGSize) -> CGFloat? {
        preconditionFailure("TODO")
    }
    
    package func alignment(of guide: VerticalAlignment, at size: CGSize) -> CGFloat {
        preconditionFailure("TODO")
    }
    
    package func alignment(of guide: HorizontalAlignment, at size: CGSize) -> CGFloat {
        preconditionFailure("TODO")
    }
    
    package func viewDebugData() -> [_ViewDebug.Data] {
        preconditionFailure("TODO")
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

// MARK: - RootDisplayList

private struct RootDisplayList: Rule, AsyncAttribute {
    @Attribute var content: DisplayList
    @Attribute var time: Time
    
    var value: (DisplayList, DisplayList.Version) {
        preconditionFailure("TODO")
    }
}

// MARK: - RootTransform

private struct RootTransform: Rule {
    var value: ViewTransform {
        guard let delegate = ViewGraph.current.delegate else {
            return ViewTransform()
        }
        return delegate.rootTransform()
    }
}

// MARK: - RootGeometry

package struct RootGeometry: Rule, AsyncAttribute {
    @OptionalAttribute package var layoutDirection: LayoutDirection?
    @Attribute package var proposedSize: ViewSize
    @OptionalAttribute package var safeAreaInsets: _SafeAreaInsetsModifier?
    @OptionalAttribute package var childLayoutComputer: LayoutComputer?
    
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

    
    // |←--------------------------proposedSize.value.width--------------------------→|  (0, 0)
    // ┌──────────────────────────────────────────────────────────────────────────────┐  ┌─────────> x
    // │     (x: insets.leading, y: insets.top)                                       |  │
    // │     ↓                                                                        |  |
    // |     |←--------------------------proposal.width--------------------------→|   |  |
    // │     ┌────────────┬───────────────────────────────────────────────────────┐   |  |
    // │     |████████████|                                                       |   │  ↓ y
    // │     |████████████|                                                       |   │  eg.
    // │     ├────────────┘                                                       │   |  proposedSize = (width: 80, height: 30)
    // |     |←----------→|                                                       |   |  insets = (
    // │     |fittingSize.width                                                   |   |    top: 4,
    // │     |                                                                    |   │    leading: 6,
    // |     | (x: insets.leading + (proposal.width  - fittingSize.width ) * 0.5, |   |    bottom: 2,
    // |     |  y: insets.top     + (proposal.height - fittingSize.height) * 0.5) |   |    trailing: 4
    // |     |                           ↓                                        |   |  )
    // │     |                           ┌────────────┐                           │   |  proposal = (width: 70, height: 24)
    // │     |                           |████████████|                           │   |  fitting = (width: 14, height: 4)
    // │     |                           |████████████|                           |   │
    // │     |                           └────────────┘                           |   │  Result:
    // │     |                                                                    |   │  center: false + left
    // │     |                                                                    |   │  x: insets.leading = 6
    // │     |                                                                    |   │  y: insets.top = 4
    // │     |                                                                    |   │
    // │     |                                                                    |   │  center: false + right
    // │     |                                                                    |   │  x: insets.leading = proposedSize.width-(i.l+f.w)
    // │     |                                                                    |   │  y: insets.top = 4
    // │     |                                                                    |   │
    // │     |                                                                    |   │  center: true + left
    // │     └────────────────────────────────────────────────────────────────────┘   |  x: i.l+(p.width-f.width)*0.5=34
    // |                                                                              |  y: i.t+(p.height-f.height)*0.5=14
    // └──────────────────────────────────────────────────────────────────────────────┘
    package var value: ViewGeometry {
        preconditionFailure("TODO")
//        let layoutComputer = childLayoutComputer ?? .defaultValue
//        let insets = safeAreaInsets?.insets ?? EdgeInsets()
//        let proposal = proposedSize.value.inset(by: insets)
//        let fittingSize = layoutComputer.delegate.sizeThatFits(_ProposedSize(size: proposal))
//        
//        var x = insets.leading
//        var y = insets.top
//        if ViewGraph.current.centersRootView {
//            x += (proposal.width - fittingSize.width) * 0.5
//            y += (proposal.height - fittingSize.height) * 0.5
//        }
//        
//        let layoutDirection = layoutDirection ?? .leftToRight
//        switch layoutDirection {
//        case .leftToRight:
//            break
//        case .rightToLeft:
//            x = proposedSize.value.width - CGRect(origin: CGPoint(x: x, y: y), size: fittingSize).maxX
//        }
//        return ViewGeometry(
//            origin: ViewOrigin(value: CGPoint(x: x, y: y)),
//            dimensions: ViewDimensions(
//                guideComputer: layoutComputer,
//                size: ViewSize(value: fittingSize, _proposal: proposal)
//            )
//        )
    }
}

// MARK: - Graph + ViewGraph

extension Graph {
    package func viewGraph() -> ViewGraph {
        unsafeBitCast(context, to: ViewGraph.self)
    }
}
