//
//  AnyView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: A96961F3546506F21D8995C6092F15B5

internal import OpenGraphShims
internal import OpenSwiftUI_SPI

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

    public init?(_fromValue value: Any) {
        struct Visitor: ViewTypeVisitor {
            var value: Any
            var view: AnyView?
            
            mutating func visit<V: View>(type: V.Type) {
                view = AnyView(value as! V)
            }
        }
        guard let conformace = TypeConformance<ViewDescriptor>(type(of: value)) else {
            return nil
        }
        // Audited for RELEASE_2023
        var visitor = Visitor(value: value)
        withUnsafePointer(to: conformace) { pointer in
            let type = UnsafeRawPointer(pointer).assumingMemoryBound(to: (any View.Type).self)
            visitor.visit(type: type.pointee)
        }
        self = visitor.view!
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
        #if canImport(Darwin)
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
        #else
        fatalError("See #39")
        #endif
    }
    
    public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        fatalError("TODO")
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
        uniqueId: UInt32,
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
    
    override func makeChild(
        uniqueId: UInt32,
        container: Attribute<AnyViewInfo>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let child = AnyViewChild<V>(info: container, uniqueId: uniqueId)
        let graphValue = _GraphValue(Attribute(child))
        // FIXME
        return _ViewDebug.makeView(
            view: graphValue,
            inputs: inputs
        ) { view, inputs in
            V._makeView(view: view, inputs: inputs)
        }
    }
    
    override func child<Value>() -> Value { view as! Value }
    
    override func makeViewList(
        view: _GraphValue<AnyView>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        let childList = AnyViewChildList<V>(view: view.value, id: id)
        let childListAttribute = Attribute(childList)
        childListAttribute.value = self.view
        return V.makeDebuggableViewList(view: _GraphValue(childListAttribute), inputs: inputs)
    }
    
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
                newInfo = makeItem(view.storage, uniqueId: oldInfo.uniqueID &+ 1)
            }
        } else {
            newInfo = makeItem(view.storage, uniqueId: 0)
        }
        value = newInfo
    }
    
    func makeItem(_ storage: AnyViewStorageBase, uniqueId: UInt32) -> AnyViewInfo {
        #if canImport(Darwin)
        let current = AnyAttribute.current!
        let childGraph = OGSubgraph(graph: parentSubgraph.graph)
        parentSubgraph.addChild(childGraph)
        return childGraph.apply {
            let childInputs = inputs.detechedEnvironmentInputs()
            let childOutputs = storage.makeChild(
                uniqueId: uniqueId,
                container: current.unsafeCast(to: AnyViewInfo.self),
                inputs: childInputs
            )
            outputs.attachIndirectOutputs(to: childOutputs)
            return AnyViewInfo(item: storage, subgraph: childGraph, uniqueID: uniqueId)
        }
        #else
        fatalError("#See #39")
        #endif
    }
    
    func eraseItem(info: AnyViewInfo) {
        outputs.detachIndirectOutputs()
        let subgraph = info.subgraph
        subgraph.willInvalidate(isInserted: true)
        subgraph.invalidate()
    }
}

private struct AnyViewChild<V: View>: StatefulRule, AsyncAttribute {
    @Attribute var info: AnyViewInfo
    let uniqueId: UInt32
    
    typealias Value = V
    
    func updateValue() {
        guard uniqueId == info.uniqueID else {
            return
        }
        value = info.item.child()
    }
}

extension AnyViewChild: CustomStringConvertible {
    var description: String { "\(V.self)" }
}

private struct AnyViewChildList<V: View>: StatefulRule, AsyncAttribute {
    typealias Value = V
    
    @Attribute var view: AnyView
    var id: UniqueID?
    
    func updateValue() {
        guard let storage = view.storage as? AnyViewStorage<V>,
            storage.id == id else {
            return
        }
        value = storage.view
        return
    }
}

// TODO
private struct AnyViewList: StatefulRule, AsyncAttribute {
    @Attribute var view: AnyView
    let inputs: _ViewListInputs
    let parentSubgraph: OGSubgraph
    let allItems: MutableBox<[Unmanaged<Item>]>
    var lastItem: Item?
    
    typealias Value = AnyView // FIXME
    
    func updateValue() {
        fatalError("TODO")
    }
    
    final class Item: _ViewList_Subgraph {
        let type: Any.Type
        #if canImport(Darwin)
        let owner: AnyAttribute
        #endif
        @Attribute var list: ViewList
        let id: UniqueID
        let isUnary: Bool
        let allItems: MutableBox<[Unmanaged<Item>]>
        
        #if canImport(Darwin)
        init(type: Any.Type, owner: AnyAttribute, list: Attribute<ViewList>, id: UniqueID, isUnary: Bool, subgraph: OGSubgraph, allItems: MutableBox<[Unmanaged<Item>]>) {
            self.type = type
            self.owner = owner
            _list = list
            self.id = id
            self.isUnary = isUnary
            self.allItems = allItems
            super.init(subgraph: subgraph)
            allItems.wrappedValue.append(.passUnretained(self))
        }
        #else
        init(type: Any.Type, list: Attribute<ViewList>, id: UniqueID, isUnary: Bool, subgraph: OGSubgraph, allItems: MutableBox<[Unmanaged<Item>]>) {
            self.type = type
            _list = list
            self.id = id
            self.isUnary = isUnary
            self.allItems = allItems
            super.init(subgraph: subgraph)
            allItems.wrappedValue.append(.passUnretained(self))
        }
        #endif
        
        override func invalidate() {
            for (index, item) in allItems.wrappedValue.enumerated() {
                guard item == .passUnretained(self) else {
                    continue
                }
                allItems.wrappedValue.remove(at: index)
                break
            }
        }
        
        func bindID(_ id: inout _ViewList_ID) {
            #if canImport(Darwin)
            id.bind(explicitID: AnyHashable(self.id), owner: owner, isUnary: isUnary)
            #endif
        }
    }
    
    // TODO
    struct WrappedList {
        let base: ViewList
        let item: Item
        let lastID: UniqueID?
        let lastTransaction: TransactionID
    }
    
    // TODO
    struct WrappedIDs/*: Sequence*/ {
        let base: _ViewList_ID.Views
        let item: Item
    }
    
    struct Transform: _ViewList_SublistTransform_Item {
        func apply(sublist: inout _ViewList_Sublist) {
            item.bindID(&sublist.id)
            sublist.elements = item.wrapping(sublist.elements)
        }
        
        var item: Item
    }
}
