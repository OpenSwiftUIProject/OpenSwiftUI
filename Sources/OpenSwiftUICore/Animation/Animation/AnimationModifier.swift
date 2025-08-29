//
//  AnimationModifier.swift
//  OpenSwiftUICore
//
//  Audited: 6.5.4
//  Status: Blocked by ArichevedView
//  ID: 530459AF10BEFD7ED901D8CE93C1E289 (SwiftUICore)

import OpenAttributeGraphShims

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _AnimationModifier<Value>: ViewModifier, PrimitiveViewModifier where Value: Equatable {
    public var animation: Animation?

    public var value: Value

    @inlinable
    public init(animation: Animation?, value: Value) {
        self.animation = animation
        self.value = value
    }

    nonisolated static func _makeInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) {
        let transactionSeed = GraphHost.currentHost.data.$transactionSeed
        let seed  = Attribute(
            ValueTransactionSeed(
                value: modifier.value[offset: { .of(&$0.value) }],
                transactionSeed: transactionSeed
            )
        )
        seed.flags = .transactional
        inputs.transaction = Attribute(
            ChildTransaction(
                valueTransactionSeed: seed,
                animation: modifier.value[offset: { .of(&$0.animation) }],
                transaction: inputs.transaction,
                transactionSeed: transactionSeed
            )
        )
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let archivedView = inputs.archivedView
        if archivedView.isArchived {
            // makeArchivedView
            _openSwiftUIUnimplementedFailure()
        } else {
            var inputs = inputs
            _makeInputs(modifier: modifier, inputs: &inputs.base)
            return body(_Graph(), inputs)
        }
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let archivedView = inputs.archivedView
        if archivedView.isArchived {
            // makeArchivedViewList
            _openSwiftUIUnimplementedFailure()
        } else {
            var inputs = inputs
            _makeInputs(modifier: modifier, inputs: &inputs.base)
            return body(_Graph(), inputs)
        }
    }
}

@available(*, unavailable)
extension _AnimationModifier: Sendable {}

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _AnimationView<Content>: View, PrimitiveView where Content: Equatable, Content: View {
    public var content: Content

    public var animation: Animation?

    @inlinable
    public init(content: Content, animation: Animation?) {
        self.content = content
        self.animation = animation
    }

    nonisolated static func _makeInputs(
        view: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) -> _GraphValue<Content> {
        let value = view.value[offset: { .of(&$0.content) }]
        let transactionSeed = GraphHost.currentHost.data.$transactionSeed
        let seed = Attribute(
            ValueTransactionSeed(
                value: value,
                transactionSeed: transactionSeed
            )
        )
        seed.flags = .transactional
        inputs.transaction = Attribute(
            ChildTransaction(
                valueTransactionSeed: seed,
                animation: view.value[offset: { .of(&$0.animation) }],
                transaction: inputs.transaction,
                transactionSeed: transactionSeed
            )
        )
        return _GraphValue(value)
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var inputs = inputs
        let value = _makeInputs(view: view, inputs: &inputs.base)
        return Content.makeDebuggableView(view: value, inputs: inputs)
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        let value = _makeInputs(view: view, inputs: &inputs.base)
        return Content.makeDebuggableViewList(view: value, inputs: inputs)
    }

    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        Content._viewListCount(inputs: inputs)
    }
}

@available(*, unavailable)
extension _AnimationView: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension _AnimationModifier: Equatable {}

@available(OpenSwiftUI_v1_0, *)
extension View {
    @inlinable
    nonisolated public func animation<V>(_ animation: Animation?, value: V) -> some View where V: Equatable {
        modifier(_AnimationModifier(animation: animation, value: value))
    }
}

@available(OpenSwiftUI_v3_0, *)
extension View where Self: Equatable {
    @available(OpenSwiftUI_v3_0, *)
    @inlinable
    nonisolated public func animation(_ animation: Animation?) -> some View {
        _AnimationView(content: self, animation: animation)
    }
}

/// A stateful rule that tracks value changes to determine when to update transactions.
///
/// This structure maintains state about a value being monitored, comparing new values
/// with the previous ones to detect changes.
struct ValueTransactionSeed<V>: StatefulRule, AsyncAttribute where V: Equatable {
    @Attribute var value: V
    @Attribute var transactionSeed: UInt32
    var oldValue: V?

    init(value: Attribute<V>, transactionSeed: Attribute<UInt32>, oldValue: V? = nil) {
        self._value = value
        self._transactionSeed = transactionSeed
        self.oldValue = oldValue
    }

    typealias Value = UInt32

    mutating func updateValue() {
        let newValue = value
        if let oldValue {
            guard oldValue != newValue else {
                return
            }
            value = Graph.withoutUpdate { transactionSeed }
        } else {
            value = .max
        }
        oldValue = newValue
    }
}

// TODO: Archived stuff

private struct ChildTransaction: Rule, AsyncAttribute {
    @Attribute var valueTransactionSeed: UInt32
    @Attribute var animation: Animation?
    @Attribute var transaction: Transaction
    @Attribute var transactionSeed: UInt32

    var value: Transaction {
        var transaction = transaction
        guard !transaction.disablesAnimations else {
            return transaction
        }
        let oldTransactionSeed = Graph.withoutUpdate { transactionSeed }
        guard valueTransactionSeed == oldTransactionSeed else {
            return transaction
        }
        transaction.animation = animation
        Swift.assert(transactionSeed == oldTransactionSeed)
        return transaction
    }
}
