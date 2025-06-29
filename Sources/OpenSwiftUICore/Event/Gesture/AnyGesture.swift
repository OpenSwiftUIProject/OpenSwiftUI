//
//  AnyGesture.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 9726BF9F3BA5F571B5F201AD7C8C86F0 (SwiftUICore)

import OpenGraphShims

// MARK: - AnyGesture [6.5.4]

/// A type-erased gesture.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct AnyGesture<Value>: PrimitiveGesture, Gesture {
    fileprivate var storage: AnyGestureStorageBase<Value>

    /// Creates an instance from another gesture.
    ///
    /// - Parameter gesture: A gesture that you use to create a new gesture.
    public init<T>(_ gesture: T) where Value == T.Value, T: Gesture {
        storage = AnyGestureStorage(gesture: gesture)
    }

    nonisolated public static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Value> {
        let outputs: _GestureOutputs<Value> = inputs.makeIndirectOutputs()
        let currentSubgraph = Subgraph.current!
        let info = Attribute(AnyGestureInfo<Value>(
            gesture: gesture.value,
            inputs: inputs,
            outputs: outputs,
            parentSubgraph: currentSubgraph
        ))
        info.setFlags(.active, mask: .mask)
        outputs.setIndirectDependency(info.identifier)
        return outputs
    }
}

@available(*, unavailable)
extension AnyGesture: Sendable {}

@usableFromInline
class AnyGestureStorageBase<Value> {

    fileprivate func matches(_ other: AnyGestureStorageBase<Value>) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    fileprivate func makeChild(
        uniqueId: UInt32,
        container: Attribute<AnyGestureInfo<Value>.Value>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Value> {
        _openSwiftUIBaseClassAbstractMethod()
    }

    fileprivate func updateChild(context: AnyRuleContext) {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@available(*, unavailable)
extension AnyGestureStorageBase: Sendable {}

private final class AnyGestureStorage<G>: AnyGestureStorageBase<G.Value> where G: Gesture {
    var gesture: G

    init(gesture: G) {
        self.gesture = gesture
    }

    override func matches(_ other: AnyGestureStorageBase<G.Value>) -> Bool {
        other is AnyGestureStorage<G>
    }

    override func makeChild(
        uniqueId: UInt32,
        container: Attribute<AnyGestureInfo<G.Value>.Value>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<G.Value> {
        let child = Attribute(AnyGestureChild<G>(info: container, uniqueId: uniqueId))
        return G.makeDebuggableGesture(gesture: _GraphValue(child), inputs: inputs)
    }

    override func updateChild(context: AnyRuleContext) {
        context.unsafeCast(to: G.self).value = gesture
    }
}

private struct AnyGestureInfo<V>: StatefulRule {
    @Attribute var gesture: AnyGesture<V>
    var inputs: _GestureInputs
    var outputs: _GestureOutputs<V>
    let parentSubgraph: Subgraph
    var oldInfo: Value?

    struct Value {
        var item: AnyGestureStorageBase<V>
        var subgraph: Subgraph
        var uniqueId: UInt32
    }

    mutating func updateValue() {
        let newInfo: Value
        if let oldInfo, oldInfo.item.matches(gesture.storage) {
            newInfo = Value(item: gesture.storage, subgraph: oldInfo.subgraph, uniqueId: oldInfo.uniqueId)
        } else {
            let uniqueId: UInt32
            if let oldInfo {
                eraseItem(info: oldInfo)
                uniqueId = oldInfo.uniqueId &+ 1
            } else {
                uniqueId = 0
            }
            newInfo = makeItem(gesture.storage, uniqueId: uniqueId)
        }
        value = newInfo
        oldInfo = newInfo
    }

    func makeItem(
        _ storage: AnyGestureStorageBase<V>,
        uniqueId: UInt32
    ) -> Value {
        let childGraph = Subgraph(graph: parentSubgraph.graph)
        parentSubgraph.addChild(childGraph)
        return childGraph.apply {
            var childInputs = inputs
            childInputs.copyCaches()
            childInputs.resetSeed = Attribute(AnyResetSeed<V>(
                resetSeed: inputs.resetSeed,
                info: attribute
            ))
            let childOutputs = storage.makeChild(
                uniqueId: uniqueId,
                container: attribute,
                inputs: childInputs
            )
            outputs.attachIndirectOutputs(childOutputs)
            return Value(item: storage, subgraph: childGraph, uniqueId: uniqueId)
        }
    }

    func eraseItem(info: Value) {
        outputs.detachIndirectOutputs()
        let subgraph = info.subgraph
        subgraph.willInvalidate(isInserted: true)
        subgraph.invalidate()
    }
}

private struct AnyGestureChild<G>: StatefulRule where G: Gesture {
    @Attribute var info: AnyGestureInfo<G.Value>.Value
    let uniqueId: UInt32

    typealias Value = G

    func updateValue() {
        guard uniqueId == info.uniqueId else {
            return
        }
        info.item.updateChild(context: AnyRuleContext(context))
    }
}

private struct AnyResetSeed<V>: Rule {
    @Attribute var resetSeed: UInt32
    @Attribute var info: AnyGestureInfo<V>.Value

    var value: UInt32 {
        let resetSeed = resetSeed
        let uniqueId = info.uniqueId
        return uniqueId &+ resetSeed
    }
}
