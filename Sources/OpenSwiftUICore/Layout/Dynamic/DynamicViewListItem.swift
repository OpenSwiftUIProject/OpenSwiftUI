//
//  DynamicViewListItem.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims

struct DynamicViewListItem: DynamicContainerItem {
    var id: ViewList.ID
    var elements: ViewList.Elements
    var traits: ViewTraitCollection
    var list: Attribute<any ViewList>?

    var count: Int {
        elements.count
    }

    var needsTransitions: Bool {
        traits.optionalTransition() != nil
    }

    var zIndex: Double {
        traits.zIndex
    }

    func matchesIdentity(of other: DynamicViewListItem) -> Bool {
        list == other.list && id == other.id
    }

    var viewID: _ViewList_ID? { id }
}
