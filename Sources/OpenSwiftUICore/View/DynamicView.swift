//
//  DynamicView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by DynamicViewList
//  ID: 3FB6ABB0477B815AB3C89DD5EDC9F0F0 (SwiftUICore)

package import OpenGraphShims

package protocol DynamicView {
    static var canTransition: Bool { get }
    static var traitKeysDependOnView: Bool { get }
    associatedtype Metadata
    associatedtype ID : Hashable
    static func makeID() -> ID
    func childInfo(metadata: Metadata) -> (any Any.Type, ID?)
    func makeChildView(metadata: Metadata, view: Attribute<Self>, inputs: _ViewInputs) -> _ViewOutputs
    func makeChildViewList(metadata: Metadata, view: Attribute<Self>, inputs: _ViewListInputs) -> _ViewListOutputs
}

extension DynamicView {
    package static var traitKeysDependOnView: Bool { true }
}

extension DynamicView where ID == UniqueID {
    package static func makeID() -> UniqueID { UniqueID() }
}

extension DynamicView {
    package static func makeDynamicView(metadata: Metadata, view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let outputs = inputs.makeIndirectOutputs()
        let container = DynamicViewContainer(
            metadata: metadata,
            view: view.value,
            inputs: inputs,
            outputs: inputs.makeIndirectOutputs()
        )
        let attribute = Attribute(container)
        attribute.flags = .active
        #if canImport(Darwin)
        outputs.setIndirectDependency(attribute.identifier)
        #endif
        return outputs
    }

    package static func makeDynamicViewList(metadata: Metadata, view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        preconditionFailure("TODO")
    }
}

// MARK: - DynamicViewContainer

private struct DynamicViewContainer<V>: StatefulRule, AsyncAttribute where V: DynamicView {
    let metadata: V.Metadata
    @Attribute var view: V
    let inputs: _ViewInputs
    let outputs: _ViewOutputs
    let parentSubgraph: Subgraph

    init(metadata: V.Metadata, view: Attribute<V>, inputs: _ViewInputs, outputs: _ViewOutputs) {
        self.metadata = metadata
        self._view = view
        self.inputs = inputs
        self.outputs = outputs
        self.parentSubgraph = Subgraph.current!
    }

    func updateValue() {
        let (type, id) = view.childInfo(metadata: metadata)
        let value: Value? = Graph.outputValue()?.pointee
        guard value.map({ $0.matches(type: type, id: id)}) == false else {
            return
        }
        if let value {
            outputs.detachIndirectOutputs()
            value.subgraph.willInvalidate(isInserted: true)
            value.subgraph.invalidate()
        }
        let parentSubgraph = parentSubgraph
        let graph = parentSubgraph.graph
        let newSubgraph = Subgraph(graph: graph)
        parentSubgraph.addChild(newSubgraph)

        let newValue = newSubgraph.apply {
            let childOutputs = view.makeChildView(
                metadata: metadata,
                view: $view,
                inputs: inputs.detechedEnvironmentInputs()
            )
            outputs.attachIndirectOutputs(to: childOutputs)
            return Value(type: type, id: id, subgraph: newSubgraph)
        }
        withUnsafePointer(to: newValue) { pointer in
            Graph.setOutputValue(pointer)
        }
    }

    struct Value {
        var type: Any.Type
        var id: V.ID?
        var subgraph: Subgraph

        init(type: Any.Type, id: V.ID? = nil, subgraph: Subgraph) {
            self.type = type
            self.id = id
            self.subgraph = subgraph
        }

        func matches(type: Any.Type, id: V.ID?) -> Bool {
            self.type == type && id.map { $0 == id } != false
        }
    }
}
