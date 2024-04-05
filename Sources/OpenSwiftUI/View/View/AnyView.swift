//
//  AnyView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: A96961F3546506F21D8995C6092F15B5

internal import OpenGraphShims

@frozen
public struct AnyView: PrimitiveView {
    var storage: AnyViewStorageBase

    public init<V>(_ view: V) where V: View {
        self.init(view, id: nil)
    }

    @_alwaysEmitIntoClient
    public init<V>(erasing view: V) where V : View {
        self.init(view)
    }

    // WIP
    public init?(_fromValue value: Any) {
        fatalError("TODO")
    }
    
    init<V: View>(_ view: V, id: UniqueID?) {
        if let anyView = view as? AnyView {
            storage = anyView.storage
        } else {
            storage = AnyViewStorage(view: view, id: id)
        }
    }
    
    func visitContent<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        storage.visitContent(&visitor)
    }
    
    public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let outputs = inputs.makeIndirectOutputs()
        let parent = OGSubgraph.current!
        let container = AnyViewContainer(view: view.value, inputs: inputs, outputs: outputs, parentSubgraph: parent)
        let containerAttribute = Attribute(container)
        outputs.forEach { key, value in
            value.indirectDependency = containerAttribute.identifier
        }
        if let layoutComputer = outputs.$layoutComputer {
            layoutComputer.identifier.indirectDependency = containerAttribute.identifier
        }
        return outputs
    }
    
    public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        // TODO
        .init()
    }
}

@usableFromInline
class AnyViewStorageBase {
    let id: UniqueID?
    
    init(id: UniqueID?) {
        self.id = id
    }
    
    fileprivate var type: Any.Type { fatalError() }
    fileprivate var canTransition: Bool { fatalError() }
    fileprivate func matches(_ other: AnyViewStorageBase) -> Bool { fatalError() }
    fileprivate func makeChild(
        uniqueID: UInt32,
        container: Attribute<AnyViewInfo>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        fatalError()
    }
    func child<Value>() -> Value { fatalError() }
    fileprivate func makeViewList(
        view: _GraphValue<AnyView>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        fatalError()
    }
    fileprivate func visitContent<Vistor: ViewVisitor>(_ visitor: inout Vistor) {
        fatalError()
    }
}

private final class AnyViewStorage<V: View>: AnyViewStorageBase {
    let view: V
    
    init(view: V, id: UniqueID?) {
        self.view = view
        super.init(id: id)
    }
    
    override var type: Any.Type { V.self }
    
    override var canTransition: Bool { id != nil }
    
    override func matches(_ other: AnyViewStorageBase) -> Bool {
        other is AnyViewStorage<V>
    }
    
    override func child<Value>() -> Value { view as! Value }
    
    // TODO
//    override func makeViewList(
//        view: _GraphValue<AnyView>,
//        inputs: _ViewListInputs
//    ) -> _ViewListOutputs {
//    }
    
    override func visitContent<Vistor>(_ visitor: inout Vistor) where Vistor : ViewVisitor {
        visitor.visit(view)
    }
}

private struct AnyViewInfo {
    var item: AnyViewStorageBase
    var subgraph: OGSubgraph
    var uniqueID: UInt32
}

private struct AnyViewContainer: StatefulRule, AsyncAttribute {
    @Attribute var view: AnyView
    let inputs: _ViewInputs
    let outputs: _ViewOutputs
    let parentSubgraph: OGSubgraph
    
    typealias Value = AnyViewInfo
    
    func updateValue() {
        let view = view
        let newInfo: AnyViewInfo
        if hasValue {
            let oldInfo = value
            if oldInfo.item.matches(view.storage) {
                newInfo = oldInfo
            } else {
                eraseItem(info: oldInfo)
                newInfo = makeItem(view.storage, uniqueId: oldInfo.uniqueID + 1)
            }
        } else {
            newInfo = makeItem(view.storage, uniqueId: 0)
        }
        value = newInfo
    }
    
    func makeItem(_ storage: AnyViewStorageBase, uniqueId: UInt32) -> AnyViewInfo {
        let current = OGAttribute.current!
        let childGraph = OGSubgraph(graph: parentSubgraph.graph)
        parentSubgraph.addChild(childGraph)
        return childGraph.apply {
            let childInputs = inputs.detechedEnvironmentInputs()
            let childOutputs = storage.makeChild(uniqueID: uniqueId, container: current.unsafeCast(to: AnyViewInfo.self), inputs: childInputs)
            outputs.attachIndirectOutputs(to: childOutputs)
            return AnyViewInfo(item: storage, subgraph: childGraph, uniqueID: uniqueId)
        }
    }
    
    func eraseItem(info: AnyViewInfo) {
        outputs.detachIndirectOutputs()
        let subgraph = info.subgraph
        subgraph.willInvalidate(isInserted: true)
        subgraph.invalidate()
    }
}
