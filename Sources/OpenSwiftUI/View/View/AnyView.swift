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
    // WIP
    public init<V>(_ view: V) where V : View {
        storage = .init(id: nil)
    }

    @_alwaysEmitIntoClient
    public init<V>(erasing view: V) where V : View {
        self.init(view)
    }

    // WIP
    public init?(_fromValue value: Any) {
        return nil
    }
//  public static func _makeView(view: _GraphValue<SwiftUI.AnyView>, inputs: _ViewInputs) -> _ViewOutputs
//  public static func _makeViewList(view: _GraphValue<AnyView>, inputs: _ViewListInputs) -> _ViewListOutputs

    // WIP
    init<V: View>(_ view: V, id: UniqueID?) {
        storage = .init(id: nil)
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
            var childInputs = inputs.detechedEnvironmentInputs()
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
