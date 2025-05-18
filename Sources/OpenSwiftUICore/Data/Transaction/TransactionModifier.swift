//
//  TransactionModifier.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: A1B10B5AB036C34AB7DD2EE8825FCA93 (SwiftUICore)

package import OpenGraphShims

// MARK: - TransactionModifier

@frozen
public struct _TransactionModifier: ViewModifier, _GraphInputsModifier, PrimitiveViewModifier {
    public var transform: (inout Transaction) -> ()

    public init(transform: @escaping (inout Transaction) -> ()) {
        self.transform = transform
    }

    public static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        let child = ChildTransaction(modifier: modifier.value, transaction: inputs.transaction)
        inputs.transaction = Attribute(child)
    }
}

@available(*, unavailable)
extension _TransactionModifier: Sendable {}

private struct ChildTransaction: Rule, AsyncAttribute {
    @Attribute var modifier: _TransactionModifier
    @Attribute var transaction: Transaction

    var value: Transaction {
        var transaction = transaction
        $modifier.syncMainIfReferences { modifier in
            modifier.transform(&transaction)
        }
        return transaction
    }
}

// MARK: - ValueTransactionModifier

@frozen
public struct _ValueTransactionModifier<Value>: ViewModifier, _GraphInputsModifier, PrimitiveViewModifier where Value: Equatable {
    public var value: Value

    public var transform: (inout Transaction) -> ()

    public init(value: Value, transform: @escaping (inout Transaction) -> Void) {
        self.value = value
        self.transform = transform
    }

    public static func _makeInputs(modifier: _GraphValue<_ValueTransactionModifier<Value>>, inputs: inout _GraphInputs) {
        let value = modifier[offset: { .of(&$0.value) }]
        let host = GraphHost.currentHost
        let transactionSeed = host.data.$transactionSeed
        let seed = ValueTransactionSeed(
            value: value.value,
            transactionSeed: transactionSeed
        )
        let seedAttribute = Attribute(seed)
        seedAttribute.flags = .active
        let child = ChildValueTransaction(
            valueTransactionSeed: seedAttribute,
            transform: modifier.value[keyPath: \.transform],
            transaction: inputs.transaction,
            transactionSeed: transactionSeed
        )
        inputs.transaction = Attribute(child)
    }
}

@available(*, unavailable)
extension _ValueTransactionModifier: Sendable {}

struct ValueTransactionSeed<V>: StatefulRule, AsyncAttribute where V: Equatable {
    var _value: Attribute<V>
    var _transactionSeed: Attribute<UInt32>
    var oldValue: V?

    init(value: Attribute<V>, transactionSeed: Attribute<UInt32>, oldValue: V? = nil) {
        self._value = value
        self._transactionSeed = transactionSeed
        self.oldValue = oldValue
    }

    typealias Value = UInt32

    mutating func updateValue() {
        let newValue = _value.value
        if let oldValue {
            guard oldValue != newValue else {
                return
            }
            value = Graph.withoutUpdate { _transactionSeed.value }
        } else {
            value = .max
        }
        oldValue = newValue
    }
}

private struct ChildValueTransaction: Rule, AsyncAttribute {
    @Attribute var valueTransactionSeed: UInt32
    @Attribute var transform: (inout Transaction) -> ()
    @Attribute var transaction: Transaction
    @Attribute var transactionSeed: UInt32

    var value: Transaction {
        var transaction = transaction
        let seed = Graph.withoutUpdate({ transactionSeed })
        if valueTransactionSeed == seed  {
            $transform.syncMainIfReferences { transform in
                transform(&transaction)
            }
            Swift.precondition(transactionSeed == seed)
        }
        return transaction
    }
}

// MARK: - PushPopTransactionModifier

@frozen
public struct _PushPopTransactionModifier<Content>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Content: ViewModifier {
    public var content: Content

    public var base: _TransactionModifier

    public init(content: Content, transform: @escaping (inout Transaction) -> Void) {
        self.content = content
        self.base = .init(transform: transform)
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        let transaction = inputs.transaction
        inputs.savedTransactions.append(transaction)
        let child = ChildTransaction(
            modifier: modifier.value[offset: { .of(&$0.base) }],
            transaction: transaction
        )
        inputs.transaction = Attribute(child)
        return Content.makeDebuggableView(
            modifier: modifier[offset: { .of(&$0.content) }],
            inputs: inputs
        ) { graph, inputs in
            var inputs = inputs
            inputs.savedTransactions.removeLast()
            return body(graph, inputs)
        }
    }
}

@available(*, unavailable)
extension _PushPopTransactionModifier: Sendable {}

extension _GraphInputs {
    private struct SavedTransactionKey: ViewInput {
        static let defaultValue: [Attribute<Transaction>] = []
    }

    package var savedTransactions: [Attribute<Transaction>] {
        get { self[SavedTransactionKey.self] }
        set { self[SavedTransactionKey.self] = newValue }
    }
}

extension _ViewInputs {
    package var savedTransactions: [Attribute<Transaction>] {
        get { base.savedTransactions }
        set { base.savedTransactions = newValue }
    }

    package func geometryTransaction() -> Attribute<Transaction> {
        savedTransactions.first ?? transaction
    }
}
