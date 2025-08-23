//
//  TransactionID.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import OpenGraphShims

// MARK: - TransactionID

package struct TransactionID: Comparable, Hashable {
    package var id: Int

    @inlinable
    package init() { id = .zero }

    @inlinable
    package init(graph: Graph) {
        id = Int(graph.counter(for: .transactions))
    }

    @inlinable
    package init(context: AnyRuleContext) {
        self.init(graph: context.attribute.graph)
    }

    @inlinable
    package init<Value>(context: RuleContext<Value>) {
        self.init(graph: context.attribute.graph)
    }

    @inlinable
    package static func < (lhs: TransactionID, rhs: TransactionID) -> Bool {
        lhs.id < rhs.id
    }
}
