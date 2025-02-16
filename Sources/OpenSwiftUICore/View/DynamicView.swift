//
//  DynamicView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
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
        outputs.setIndirectDependency(attribute.identifier)
        return outputs
    }

    package static func makeDynamicViewList(metadata: Metadata, view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        let list = DynamicViewList(metadata: metadata, view: view.value, inputs: inputs, lastItem: nil)
        let attribute = Attribute(list)
        return _ViewListOutputs(
            .dynamicList(attribute, nil),
            nextImplicitID: inputs.implicitID,
            staticCount: nil
        )
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
        let oldValue: Value? = Graph.outputValue()?.pointee
        guard oldValue.map({ $0.matches(type: type, id: id)}) == false else {
            return
        }
        if let oldValue {
            outputs.detachIndirectOutputs()
            oldValue.subgraph.willInvalidate(isInserted: true)
            oldValue.subgraph.invalidate()
        }
        let parentSubgraph = parentSubgraph
        let graph = parentSubgraph.graph
        let newSubgraph = Subgraph(graph: graph)
        parentSubgraph.addChild(newSubgraph)

        value = newSubgraph.apply {
            let childOutputs = view.makeChildView(
                metadata: metadata,
                view: $view,
                inputs: inputs.detachedEnvironmentInputs()
            )
            outputs.attachIndirectOutputs(to: childOutputs)
            return Value(type: type, id: id, subgraph: newSubgraph)
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

// MARK: - DynamicViewList

private struct DynamicViewList<V>: StatefulRule, AsyncAttribute where V: DynamicView {
    let metadata: V.Metadata
    @Attribute var view: V
    let inputs: _ViewListInputs
    let parentSubgraph: Subgraph
    private let allItems: MutableBox<[Unmanaged<Item>]>
    private var lastItem: Item?

    fileprivate init(metadata: V.Metadata, view: Attribute<V>, inputs: _ViewListInputs, lastItem: Item?) {
        self.metadata = metadata
        self._view = view
        self.inputs = inputs
        self.parentSubgraph = Subgraph.current!
        self.allItems = MutableBox([])
        self.lastItem = lastItem
    }

    typealias Value = (any ViewList)

    mutating func updateValue() {
        let (type, id) = view.childInfo(metadata: metadata)

        let lastID: V.ID?
        if let lastItem {
            lastID = lastItem.id
            if lastItem.matches(type: type, id: id), lastItem.isValid {
                setValue(for: lastItem, id: lastID)
                return
            }
            lastItem.remove(from: parentSubgraph)
            self.lastItem = nil
        } else {
            lastID = nil
        }

        for item in allItems.wrappedValue {
            let item = item.takeUnretainedValue()
            guard item.matches(type: type, id: id) else {
                continue
            }
            item.retain()
            // parentSubgraph.addChild(item.subgraph)
            item.subgraph.didReinsert()
            lastItem = item
            setValue(for: item, id: lastID)
            return
        }

        let parentSubgraph = parentSubgraph
        guard parentSubgraph.isValid else {
            value = EmptyViewList()
            return
        }
        let graph = parentSubgraph.graph
        let newSubgraph = Subgraph(graph: graph)
        parentSubgraph.addChild(newSubgraph)
        let (listAttribute, isUnary) = newSubgraph.apply {
            var newInputs = inputs
            newInputs.detachEnvironmentInputs()
            if V.canTransition {
                newInputs.options.insert(.canTransition)
            }
            newInputs.implicitID = 0
            let outputs = view.makeChildViewList(metadata: metadata, view: $view, inputs: newInputs)
            let attribute = outputs.makeAttribute(inputs: newInputs)
            return (attribute, outputs.staticCount == 1)
        }
        let item = Item(
            type: type,
            owner: context.attribute.identifier,
            list: listAttribute,
            id: id ?? V.makeID(),
            isUnary: isUnary,
            subgraph: newSubgraph,
            allItems: allItems
        )
        lastItem = item
        setValue(for: item, id: lastID)
    }

    private mutating func setValue(for item: Item, id: V.ID?) {
        value = WrappedList(
            base: item.list,
            item: item,
            lastID: id,
            lastTransaction: TransactionID(context: context)
        )
    }

    fileprivate final class Item: ViewList.Subgraph {
        let type: any Any.Type
        let id: V.ID
        let owner: AnyAttribute
        @Attribute var list: any ViewList
        let isUnary: Bool
        let allItems: MutableBox<[Unmanaged<Item>]>

        init(type: any Any.Type, owner: AnyAttribute, list: Attribute<any ViewList>, id: V.ID, isUnary: Bool, subgraph: Subgraph, allItems: MutableBox<[Unmanaged<Item>]>) {
            self.type = type
            self.id = id
            self.owner = owner
            self._list = list
            self.isUnary = isUnary
            self.allItems = allItems
            super.init(subgraph: subgraph)
            allItems.wrappedValue.append(.passRetained(self))
        }

        override func invalidate() {
            if let index = allItems.wrappedValue.firstIndex(where: { $0 == .passUnretained(self) }) {
                allItems.wrappedValue.remove(at: index)
            }
        }

        func matches(type: Any.Type, id: V.ID?) -> Bool {
            self.type == type && id.map { $0 == self.id } != false
        }

        func bindID(_ id: inout ViewList.ID) {
            id.bind(explicitID: id, owner: owner, isUnary: isUnary, reuseID: Int(bitPattern: ObjectIdentifier(Int.self)))
        }
    }
}

extension DynamicViewList {
    private struct WrappedList: ViewList {
        let base: any ViewList
        let item: Item
        let lastID: V.ID?
        let lastTransaction: TransactionID

        init(base: any ViewList, item: Item, lastID: V.ID?, lastTransaction: TransactionID) {
            self.base = base
            self.item = item
            self.lastID = lastID
            self.lastTransaction = lastTransaction
        }

        func count(style: IteratorStyle) -> Int {
            base.count(style: style)
        }

        func estimatedCount(style: IteratorStyle) -> Int {
            base.estimatedCount(style: style)
        }

        var traitKeys: ViewTraitKeys? {
            var keys = base.traitKeys
            if V.traitKeysDependOnView {
                keys?.isDataDependent = true
            }
            return keys
        }

        var viewIDs: ID.Views? {
            base.viewIDs.map { viewIDs in
                ViewList.ID._Views(
                    WrappedIDs(base: viewIDs, item: item),
                    isDataDependent: true
                )
            }
        }

        var traits: ViewTraitCollection {
            base.traits
        }

        @discardableResult
        func applyNodes(
            from start: inout Int,
            style: IteratorStyle,
            list: Attribute<any ViewList>?,
            transform: inout SublistTransform,
            to body: ApplyBody
        ) -> Bool {
            transform.push(Transform(item: item))
            defer { transform.pop() }
            return base.applyNodes(
                from: &start,
                style: style,
                list: list,
                transform: &transform,
                to: body
            )
        }

        func edit(forID id: ID, since transaction: TransactionID) -> Edit? {
            guard transaction >= lastTransaction,
                  let lastID,
                  lastID != item.id,
                  let explicitID: V.ID = id.explicitID(owner: item.owner)
            else {
                return base.edit(forID: id, since: transaction)
            }
            if explicitID == lastID {
                return .removed
            } else if explicitID == item.id {
                return .inserted
            } else {
                return base.edit(forID: id, since: transaction)
            }
        }

        func firstOffset<OtherID>(forID id: OtherID, style: IteratorStyle) -> Int? where OtherID: Hashable {
            guard let otherID = id as? V.ID,
                  otherID == item.id
            else {
                return base.firstOffset(forID: id, style: style)
            }
            return 0
        }
    }

    private struct WrappedIDs: RandomAccessCollection, Equatable {
        let base: ViewList.ID.Views
        let item: Item

        var startIndex: Int { .zero }

        var endIndex: Int { base.endIndex }

        subscript(index: Int) -> ViewList.ID {
            _read {
                var id = base[index]
                item.bindID(&id)
                yield id
            }
        }

        static func ==(_ lhs: WrappedIDs, _ rhs: WrappedIDs) -> Bool {
            lhs.item === rhs.item && lhs.base.isEqual(to: rhs.base)
        }
    }

    private struct Transform: ViewList.SublistTransform.Item {
        var item: Item

        package func apply(sublist: inout ViewList.Sublist) {
            item.bindID(&sublist.id)
            sublist.elements = item.wrapping(sublist.elements)
        }

        package func bindID(_ id: inout ViewList.ID) {
            item.bindID(&id)
        }
    }
}
