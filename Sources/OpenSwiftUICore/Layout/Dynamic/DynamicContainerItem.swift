//
//  DynamicContainerItem.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import OpenAttributeGraphShims

package protocol DynamicContainerItem {
    var count: Int { get }

    var needsTransitions: Bool { get }

    var zIndex: Double { get }

    func matchesIdentity(of other: Self) -> Bool

    static var supportsReuse: Bool { get }

    func canBeReused(by other: Self) -> Bool

    var list: Attribute<any ViewList>? { get }

    var viewID: ViewList.ID? { get }
}

extension DynamicContainerItem {
    package var needsTransitions: Bool { false }

    package var zIndex: Double { .zero }

    package static var supportsReuse: Bool { false }

    package func canBeReused(by other: Self) -> Bool { false }

    package var list: Attribute<any ViewList>? { nil }

    package var viewID: ViewList.ID? { nil }
}
