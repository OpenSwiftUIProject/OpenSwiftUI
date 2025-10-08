//
//  DynamicContainerAdaptor.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import OpenAttributeGraphShims

package protocol DynamicContainerAdaptor {
    associatedtype Item: DynamicContainerItem

    associatedtype Items

    static var maxUnusedItems: Int { get }

    mutating func updatedItems() -> Items?

    func foreachItem(items: Items, _ body: (Item) -> Void)

    static func containsItem(_ items: Items, _ item: Item) -> Bool

    associatedtype ItemLayout

    func makeItemLayout(
        item: Item,
        uniqueId: UInt32,
        inputs: _ViewInputs,
        containerInfo: Attribute<DynamicContainer.Info>,
        containerInputs: (inout _ViewInputs) -> Void
    ) -> (_ViewOutputs, ItemLayout)

    func removeItemLayout(uniqueId: UInt32, itemLayout: ItemLayout)
}

extension DynamicContainerAdaptor where Item == Items {
    @inline(__always)
    package func foreachItem(items: Items, _ body: (Item) -> Void) {
        body(items)
    }

    @inline(__always)
    package static func containsItem(_ items: Items, _ item: Item) -> Bool {
        items.matchesIdentity(of: item)
    }
}

extension DynamicContainerAdaptor where Item == Items.Element, Items: Collection {
    @inline(__always)
    package func foreachItem(items: Items, _ body: (Item) -> Void) {
        items.forEach(body)
    }

    @inline(__always)
    package static func containsItem(_ items: Items, _ item: Item) -> Bool {
        items.contains { $0.matchesIdentity(of: item) }
    }
}

extension DynamicContainerAdaptor {
    package static var maxUnusedItems: Int { .zero }
}
