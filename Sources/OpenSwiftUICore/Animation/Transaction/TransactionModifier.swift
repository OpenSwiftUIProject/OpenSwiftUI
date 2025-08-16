//
//  TransactionModifier.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: A1B10B5AB036C34AB7DD2EE8825FCA93 (SwiftUICore)

package import OpenGraphShims

// MARK: - TransactionModifier

/// Modifier to set a transaction adjustment.
@frozen
public struct _TransactionModifier: ViewModifier, _GraphInputsModifier, PrimitiveViewModifier {
    /// A closure that transforms the current transaction.
    ///
    /// This closure receives the current transaction and can modify it in place.
    public var transform: (inout Transaction) -> ()

    /// Creates a transaction modifier with the specified transform closure.
    ///
    /// - Parameter transform: A closure that modifies the transaction in place.
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

/// Modifier to set a transaction adjustment with a value constraint.
@frozen
public struct _ValueTransactionModifier<Value>: ViewModifier, _GraphInputsModifier, PrimitiveViewModifier where Value: Equatable {
    /// The value to monitor for changes.
    ///
    /// When this value changes (as determined by `Equatable` conformance),
    /// the transaction modifier will be applied.
    public var value: Value

    /// A closure that transforms the current transaction.
    ///
    /// This closure receives the current transaction and can modify it in place.
    public var transform: (inout Transaction) -> ()

    /// Creates a value transaction modifier with the specified value and transform closure.
    ///
    /// - Parameters:
    ///   - value: The value to monitor for changes.
    ///   - transform: A closure that modifies the transaction in place.
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
        seedAttribute.flags = .transactional
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
    /// The content to which the transaction modification applies.
    public var content: Content

    /// The base transaction modifier to apply.
    public var base: _TransactionModifier

    /// Creates a push-pop transaction modifier with the specified content and transform closure.
    ///
    /// - Parameters:
    ///   - content: The content to which the transaction modification applies.
    ///   - transform: A closure that modifies the transaction in place.
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
        /// The default value for saved transactions.
        static let defaultValue: [Attribute<Transaction>] = []
    }

    /// The stack of saved transactions.
    ///
    /// This property maintains a stack of transaction contexts that can be restored
    /// after temporary modifications.
    package var savedTransactions: [Attribute<Transaction>] {
        get { self[SavedTransactionKey.self] }
        set { self[SavedTransactionKey.self] = newValue }
    }
}

extension _ViewInputs {
    /// The stack of saved transactions.
    ///
    /// This property provides access to the transaction stack from view inputs.
    package var savedTransactions: [Attribute<Transaction>] {
        get { base.savedTransactions }
        set { base.savedTransactions = newValue }
    }

    /// Gets the transaction to use for geometry calculations.
    ///
    /// This method returns the first saved transaction if available, or the current
    /// transaction otherwise.
    ///
    /// - Returns: The transaction attribute to use for geometry calculations.
    package func geometryTransaction() -> Attribute<Transaction> {
        savedTransactions.first ?? transaction
    }
}
