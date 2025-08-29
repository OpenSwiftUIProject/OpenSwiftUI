//
//  GestureViewModifier.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 9DF46B4E935FF03A55FF3DDFB0B1FF2B (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - GestureViewModifier [6.5.4]

package protocol GestureViewModifier: MultiViewModifier, PrimitiveViewModifier {
    associatedtype ContentGesture: Gesture
    
    associatedtype Combiner: GestureCombiner = DefaultGestureCombiner
    
    var gesture: ContentGesture { get }
    
    var name: String? { get }
    
    var gestureMask: GestureMask { get }
}

// MARK: - GestureResponderExclusionPolicy [6.5.4]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public enum GestureResponderExclusionPolicy {
    case `default`
    
    case highPriority
    
    case simultaneous
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension GestureResponderExclusionPolicy: Sendable {}

// MARK: - GestureCombiner [6.5.4]

package protocol GestureCombiner {
    associatedtype Result: Gesture where Result.Value == ()

    static func combine(
        _ gesture1: AnyGesture<Void>,
        _ gesture2: AnyGesture<Void>
    ) -> Result

    static var exclusionPolicy: GestureResponderExclusionPolicy { get }
}

// MARK: - GestureViewModifier + Default Implementation [6.5.4]

extension GestureViewModifier {
    package var name: String? { nil }
    
    package var gestureMask: GestureMask { .all }
    
    package static func makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresViewResponders {
            let filter = GestureFilter(
                children: outputs.viewResponders(),
                modifier: modifier.value,
                inputs: inputs,
                viewSubgraph: .current!
            )
            outputs.preferences.viewResponders = Attribute(filter)
        }
        let provider = inputs.gestureAccessibilityProvider
        provider.makeGesture(
            mask: modifier.value[keyPath: \.gestureMask],
            inputs: inputs,
            outputs: &outputs
        )
        return outputs
    }
    
    package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeView(modifier: modifier, inputs: inputs, body: body)
    }
}

// MARK: - AddGestureModifier [6.5.4]

package struct AddGestureModifier<T>: GestureViewModifier where T: Gesture {
    package var gesture: T
    package var name: String?
    package var gestureMask: GestureMask
    
    package init(
        _ gesture: T,
        name: String? = nil,
        gestureMask: GestureMask = .all
    ) {
        self.gesture = gesture
        self.name = name
        self.gestureMask = gestureMask
    }
    
    package typealias Combiner = DefaultGestureCombiner

    package typealias ContentGesture = T
}

// MARK: - DefaultGestureCombiner [6.5.4]

package struct DefaultGestureCombiner: GestureCombiner {
    package typealias Base = ExclusiveGesture<AnyGesture<Void>, AnyGesture<Void>>

    package typealias Result = _MapGesture<DefaultGestureCombiner.Base, Void>

    package static var exclusionPolicy: GestureResponderExclusionPolicy { .default }

    package static func combine(
        _ first: AnyGesture<Void>,
        _ second: AnyGesture<Void>
    ) -> DefaultGestureCombiner.Result {
        first.exclusively(before: second).map { _ in }
    }
}

// MARK: - AnyGestureContainingResponder [6.5.4]

package protocol AnyGestureContainingResponder: ViewResponder {
    var viewSubgraph: Subgraph { get }

    var eventSources: [any EventBindingSource] { get }

    var gestureType: any Any.Type { get }

    var isValid: Bool { get }

    func detachContainer()
}

// MARK: - AnyGestureResponder [6.5.4]

package protocol AnyGestureResponder: AnyGestureContainingResponder {
    var inputs: _ViewInputs { get }

    var childSubgraph: Subgraph? { get set }

    var childViewSubgraph: Subgraph? { get set }

    var exclusionPolicy: GestureResponderExclusionPolicy { get }

    var label: String? { get }

    var gestureGraph: GestureGraph { get }

    var relatedAttribute: AnyAttribute { get }

    func makeSubviewsGesture(inputs: _GestureInputs) -> _GestureOutputs<Void>
}

extension AnyGestureResponder {
    package var exclusionPolicy: GestureResponderExclusionPolicy { .default }

    package func makeSubviewsGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
        _GestureOutputs(phase: inputs.failedPhase)
    }
    
    package func makeWrappedGesture(
        inputs: _GestureInputs,
        makeChild: (_GestureInputs) -> _GestureOutputs<Void>
    ) -> _GestureOutputs<Void> {
        let inputs = inputs
        let outputs: _GestureOutputs<Void> = inputs.makeDefaultOutputs()
        guard viewSubgraph.isValid else {
            return outputs
        }
        let currentSubgraph = Subgraph.current!
        let needGestureGraph = inputs.options.contains(.gestureGraph)
        childSubgraph = Subgraph(graph: (needGestureGraph ? currentSubgraph : viewSubgraph).graph)
        viewSubgraph.addChild(childSubgraph!, tag: 1)
        currentSubgraph.addChild(childSubgraph!)
        if needGestureGraph {
            childViewSubgraph = Subgraph(graph: viewSubgraph.graph)
            childSubgraph!.addChild(childViewSubgraph!, tag: 1)
        }
        childSubgraph!.apply {
            let subgraph = (childViewSubgraph ?? childSubgraph)!
            var childInputs = inputs
            childInputs.viewInputs = self.inputs
            childInputs.copyCaches()
            childInputs.viewSubgraph = subgraph
            let childOutputs = makeChild(childInputs)
            outputs.overrideDefaultValues(childOutputs)
        }
        return outputs
    }
    
    package var label: String? { nil }

    package var isCancellable: Bool {
        gestureGraph.isCancellable
    }
    
    package var requiredTapCount: Int? {
        gestureGraph.requiredTapCount
    }
    
    package func canPrevent(
        _ other: ViewResponder,
        otherExclusionPolicy: GestureResponderExclusionPolicy
    ) -> Bool {
        guard isPrioritized(over: other, otherExclusionPolicy: otherExclusionPolicy) else {
            return false
        }
        guard let other = other as? any AnyGestureResponder else {
            return true
        }
        return other.dependency == .none
    }
    
    package func shouldRequireFailure(of other: any AnyGestureResponder) -> Bool {
        guard exclusionPolicy != .simultaneous,
              other.exclusionPolicy != .simultaneous,
              let requiredTapCount,
              let otherRequiredTapCount = other.requiredTapCount,
              otherRequiredTapCount != requiredTapCount
        else {
            return other.isPrioritized(over: self, otherExclusionPolicy: exclusionPolicy) && dependency != .none
        }
        return requiredTapCount < otherRequiredTapCount
    }

    private func isPrioritized(over other: ViewResponder, otherExclusionPolicy: GestureResponderExclusionPolicy) -> Bool {
        switch (exclusionPolicy, otherExclusionPolicy) {
        case (.default, .default):
            var resonder: ResponderNode = other
            while true {
                guard resonder !== self else {
                    return false
                }
                guard let nextResponder = resonder.nextResponder else {
                    return true
                }
                resonder = nextResponder
            }
        case (.highPriority, .highPriority):
            var resonder: ResponderNode = other
            while true {
                guard resonder !== self else {
                    return true
                }
                guard let nextResponder = resonder.nextResponder else {
                    return false
                }
                resonder = nextResponder
            }
        case (.highPriority, .default):
            return true
        default:
            return false
        }
    }

    private var dependency: GestureDependency {
        gestureGraph.gestureDependency
    }
}

// MARK: - GestureResponder [6.5.4] [WIP]

private class GestureResponder<Modifier>: DefaultLayoutViewResponder, AnyGestureResponder where Modifier: GestureViewModifier {
    let modifier: Attribute<Modifier>

    var childSubgraph: Subgraph?

    var childViewSubgraph: Subgraph?

    lazy var gestureGraph: GestureGraph = {
        GestureGraph(rootResponder: self)
    }()

    lazy var bindingBridge: EventBindingBridge & GestureGraphDelegate = {
        let bridge = inputs.makeEventBindingBridge(bindingManager: gestureGraph.eventBindingManager, responder: self)
        gestureGraph.delegate = bridge
        return bridge
    }()

    var _gestureContainer: AnyObject?

    init(modifier: Attribute<Modifier>, inputs: _ViewInputs) {
        self.modifier = modifier
        super.init(inputs: inputs)
    }

    var gestureType: any Any.Type {
        Modifier.ContentGesture.self
    }

    var relatedAttribute: AnyAttribute {
        modifier.identifier
    }

    var eventSources: [any EventBindingSource] {
        bindingBridge.eventSources
    }

    var exclusionPolicy: GestureResponderExclusionPolicy {
        Modifier.Combiner.exclusionPolicy
    }

    var label: String? {
        guard viewSubgraph.isValid else { return nil }
        return Graph.withoutUpdate {
            viewSubgraph.apply {
                modifier.name.value
            }
        } ?? gestureGraph.gestureLabel
    }

    var isValid: Bool {
        _gestureContainer != nil && viewSubgraph.isValid
    }

    func detachContainer() {
        _gestureContainer = nil
    }

    func makeSubviewsGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
        makeGesture(inputs: inputs)
    }

    override var gestureContainer: AnyObject? {
        guard let gestureContainer = _gestureContainer else {
            guard viewSubgraph.isValid else {
                return nil
            }
            _gestureContainer = inputs.makeGestureContainer(responder: self)
            return _gestureContainer!
        }
        return gestureContainer
    }

    override func containsGlobalPoints(
        _ points: [PlatformPoint],
        cacheKey: UInt32?,
        options: ViewResponder.ContainsPointsOptions
    ) -> ViewResponder.ContainsPointsResult {
        _openSwiftUIUnimplementedFailure()
    }

    override func bindEvent(_ event: any EventType) -> ResponderNode? {
        guard GestureContainerFeature.isEnabled else {
            return super.bindEvent(event)
        }
        guard let hitTestableEvent = HitTestableEvent(event) else {
            return nil
        }
        return hitTest(
            globalPoint: hitTestableEvent.hitTestLocation,
            radius: hitTestableEvent.hitTestRadius
        )
    }

    override func makeGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
        makeWrappedGesture(inputs: inputs) { childInputs in
//            let childViewInputs = childInputs.viewInputs
//            let closure: () -> _GestureOutputs<Void> = { [self] in
//                if inputs.options.contains(.skipCombiners) {
//                    let childGesture = Attribute(GestureViewChild(
//                        modifier: modifier,
//                        isEnabled: childViewInputs.isEnabled,
//                        viewPhase: childViewInputs.viewPhase
//                    ))
//                    return AnyGesture<Void>.makeDebuggableGesture(gesture: _GraphValue(childGesture), inputs: childInputs)
//                } else {
//                    let childGesture = Attribute(CombiningGestureViewChild(
//                        modifier: modifier,
//                        isEnabled: childViewInputs.isEnabled,
//                        viewPhase: childViewInputs.viewPhase,
//                        node: self
//                    ))
//                    return Modifier.Combiner.Result.makeDebuggableGesture(gesture: _GraphValue(childGesture), inputs: childInputs)
//                }
//            }
//            guard inputs.options.contains(.includeDebugOutput) else {
//                return closure()
//            }
//            // TODO: GestureViewDebug
//            return closure()
            _openSwiftUIUnimplementedFailure()
        }
    }

    override func resetGesture() {
        childSubgraph = nil
        childViewSubgraph = nil
        super.resetGesture()
    }

    override func extendPrintTree(string: inout String) {
        string.append("\(Modifier.ContentGesture.self)")
    }
}

// MARK: - GestureFilter [6.5.4]

private struct GestureFilter<Modifier>: StatefulRule where Modifier: GestureViewModifier {
    typealias Value = [ViewResponder]

    @Attribute var children: [ViewResponder]

    @Attribute var modifier: Modifier

    var inputs: _ViewInputs

    var viewSubgraph: Subgraph

    lazy var responder: GestureResponder<Modifier> = {
        viewSubgraph.apply {
            GestureResponder(
                modifier: $modifier,
                inputs: inputs
            )
        }
    }()

    mutating func updateValue() {
        let responder = responder
        let (children, childrenChanged) = $children.changedValue()
        if childrenChanged {
            responder.children = children
        }
        if !hasValue {
            value = [self.responder]
        }
    }
}

// MARK: - GestureAccessibilityProvider [6.5.4]

package protocol GestureAccessibilityProvider {
    nonisolated static func makeGesture(
        mask: @autoclosure () -> Attribute<GestureMask>,
        inputs: _ViewInputs,
        outputs: inout _ViewOutputs
    )
}

struct EmptyGestureAccessibilityProvider: GestureAccessibilityProvider {
    nonisolated static func makeGesture(
        mask: @autoclosure () -> Attribute<GestureMask>,
        inputs: _ViewInputs,
        outputs: inout _ViewOutputs
    ) {
    }
}

extension _GraphInputs {
    private struct GestureAccessibilityProviderKey: GraphInput {
        static let defaultValue: (any GestureAccessibilityProvider.Type) = EmptyGestureAccessibilityProvider.self
    }

    package var gestureAccessibilityProvider: (any GestureAccessibilityProvider.Type) {
        get { self[GestureAccessibilityProviderKey.self] }
        set { self[GestureAccessibilityProviderKey.self] = newValue }
    }
}

extension _ViewInputs {
    package var gestureAccessibilityProvider: (any GestureAccessibilityProvider.Type) {
        get { base.gestureAccessibilityProvider }
        set { base.gestureAccessibilityProvider = newValue }
    }
}

// MARK: - GestureViewChild [6.5.4]

private struct GestureViewChild<Modifier>: Rule where Modifier: GestureViewModifier {
    @Attribute var modifier: Modifier
    @Attribute var isEnabled: Bool
    @Attribute var viewPhase: _GraphInputs.Phase

    typealias Value = AnyGesture<Void>

    var value: Value {
        let shouldReceiveEvents = modifier.gestureMask.contains(.gesture) && isEnabled
        guard shouldReceiveEvents else {
            return AnyGesture(EmptyGesture())
        }
        return AnyGesture(modifier.gesture.map { _ in })
    }
}

// MARK: - CombiningGestureViewChild [6.5.4]

private struct CombiningGestureViewChild<Modifier>: Rule where Modifier: GestureViewModifier {
    @Attribute var modifier: Modifier
    @Attribute var isEnabled: Bool
    @Attribute var viewPhase: _GraphInputs.Phase

    let node: any AnyGestureResponder

    typealias Value = Modifier.Combiner.Result

    @inline(__always)
    private var shouldReceiveEvents: Bool {
        modifier.gestureMask.contains(.gesture) && isEnabled
    }

    @inline(__always)
    private var shouldReceiveSubviewEvents: Bool {
        modifier.gestureMask.contains(.subviews)
    }

    @inline(__always)
    private var subviewsGesture: AnyGesture<Void> {
        if modifier.gestureMask.contains(.subviews) {
            return AnyGesture(SubviewsGesture(node: node))
        } else {
            return AnyGesture(EmptyGesture())
        }
    }

    @inline(__always)
    private var contentGesture: AnyGesture<Void> {
        if shouldReceiveEvents {
            AnyGesture(modifier.gesture
                .modifier(ContentGesture<Modifier.ContentGesture.Value>())
            )
        } else {
            AnyGesture(EmptyGesture())
        }
    }

    var value: Value {
        Modifier.Combiner.combine(subviewsGesture, contentGesture)
    }
}

// MARK: - GestureViewDebug [6.5.4] [WIP]

private struct GestureViewDebug<Modifier> where Modifier: GestureViewModifier {
}

// MARK: - SubviewsGesture [6.5.4]

private struct SubviewsGesture: PrimitiveGesture, PrimitiveDebuggableGesture {
    typealias Value = ()

    typealias Body = Never

    let node: AnyGestureResponder

    static func _makeGesture(gesture: _GraphValue<Self>, inputs: _GestureInputs) -> _GestureOutputs<Void> {
        let outputs: _GestureOutputs<Void> = inputs.makeIndirectOutputs()
        let currentSubgraph = Subgraph.current!
        let subviewValue = Attribute(SubviewsPhase(
            gesture: gesture.value,
            resetSeed: inputs.resetSeed,
            inputs: inputs,
            outputs: outputs,
            parentSubgraph: currentSubgraph,
            oldNode: nil,
            oldSeed: 0,
            childSubgraph: nil,
            childPhase: .init(),
            childDebugData: .init()
        ))
        outputs.setIndirectDependency(subviewValue.identifier)
        return outputs
    }
}

// MARK: - SimultaneousGestureCombiner [6.5.4] [WIP]

struct SimultaneousGestureCombiner {}

// MARK: - HighPriorityGestureCombiner [6.5.4] [WIP]

struct HighPriorityGestureCombiner {}

// MARK: - SubviewsPhase [6.5.4] [WIP]

private struct SubviewsPhase: StatefulRule, ObservedAttribute {
    struct Value {
        var phase: GesturePhase<Void>
        var debugData: GestureDebug.Data
    }

    @Attribute var gesture: SubviewsGesture
    @Attribute var resetSeed: UInt32
    let inputs: _GestureInputs
    let outputs: _GestureOutputs<Void>
    let parentSubgraph: Subgraph
    var oldNode: AnyGestureResponder?
    var oldSeed: UInt32
    var childSubgraph: Subgraph?
    @OptionalAttribute var childPhase: GesturePhase<Void>?
    @OptionalAttribute var childDebugData: GestureDebug.Data?

    mutating func updateValue() {
        _openSwiftUIUnimplementedFailure()
    }

    func destroy() {
        oldNode?.resetGesture()
    }
}

// MARK: - ContentGesture [6.5.4]

private struct ContentGesture<V>: GestureModifier {
    typealias Value = Void

    typealias BodyValue = V

    nonisolated static func _makeGesture(
        modifier: _GraphValue<ContentGesture<V>>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<V>
    ) -> _GestureOutputs<Void> {
        let outputs = body(inputs)
        let phase = Attribute(ContentPhase(
            phase: outputs.phase,
            resetSeed: inputs.resetSeed,
            lastResetSeed: 0
        ))
        return outputs.withPhase(phase)
    }
}

// MARK: - ContentPhase [6.5.4]

private struct ContentPhase<Value>: ResettableGestureRule {
    @Attribute var phase: GesturePhase<Value>
    @Attribute var resetSeed: UInt32
    var lastResetSeed: UInt32

    typealias Value = GesturePhase<Void>

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        value = phase.withValue(())
    }
}

// MARK: - Optional: Gesture [WIP]

extension Optional: Gesture where Wrapped: Gesture {
    public typealias Value = Wrapped.Value
    
    nonisolated public static func _makeGesture(
        gesture: _GraphValue<Optional<Wrapped>>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Wrapped.Value> {
        _openSwiftUIUnimplementedFailure()
    }

    public typealias Body = Never
}

extension Optional: PrimitiveGesture where Wrapped: Gesture {}
