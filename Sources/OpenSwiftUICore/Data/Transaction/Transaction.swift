//
//  Transaction.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: B2543BCA257433E04979186A1DC2B6BC

package import OpenGraphShims
import OpenSwiftUI_SPI

/// The context of the current state-processing update.
///
/// Use a transaction to pass an animation between views in a view hierarchy.
///
/// The root transaction for a state change comes from the binding that changed,
/// plus any global values set by calling ``withTransaction(_:_:)`` or
/// ``withAnimation(_:_:)``
@frozen
public struct Transaction {
    @usableFromInline
    package var plist: PropertyList
    
    /// Creates a transaction.
    @inlinable
    public init() {
        plist = PropertyList()
    }
    
    @inlinable
    package init(plist: PropertyList) {
        self.plist = plist
    }
    
    package struct ID: Hashable {
        var value: UInt32
    }
    
    package static var id: ID {
        ID(value: _threadTransactionID(false))
    }
    
    package static func _core_barrier() {
        _threadTransactionID(true)
    }
    
    /// Accesses the transaction value associated with a custom key.
    ///
    /// Create custom transaction values by defining a key that conforms to the
    /// ``TransactionKey`` protocol, and then using that key with the subscript
    /// operator of the ``Transaction`` structure to get and set a value for
    /// that key:
    ///
    ///     private struct MyTransactionKey: TransactionKey {
    ///         static let defaultValue = false
    ///     }
    ///
    ///     extension Transaction {
    ///         var myCustomValue: Bool {
    ///             get { self[MyTransactionKey.self] }
    ///             set { self[MyTransactionKey.self] = newValue }
    ///         }
    ///     }
    public subscript<K>(key: K.Type) -> K.Value where K: TransactionKey {
        get {
            plist[TransactionPropertyKey<K>.self]
        }
        set {
            plist[TransactionPropertyKey<K>.self] = newValue
        }
    }
    
    @inlinable
    package var isEmpty: Bool { plist.isEmpty }
    
    package func mayConcatenate(with other: Transaction) -> Bool {
        // preconditionFailure("TODO")
        false
    }
    
    @_transparent
    package mutating func set(_ other: Transaction) {
        if plist.isEmpty {
            if !other.plist.isEmpty {
                plist = other.plist
            }
        } else if other.plist.isEmpty {
            plist = other.plist
        } else if plist.data !== other.plist.data {
            plist = other.plist
        }
    }
    
    package static var current: Transaction {
        if let data = _threadTransactionData() {
            Transaction(plist: PropertyList(data: data as AnyObject))
        } else {
            Transaction()
        }
    }
    
    package var current: Transaction {
        preconditionFailure("TODO")
    }
    
    package func forEach<K>(keyType: K.Type, _ body: (K.Value, inout Bool) -> Void) where K: TransactionKey {
        preconditionFailure("TODO")
    }
    
    // FIXME: TO BE REMOVED
    @inline(__always)
    mutating package func override(_ transaction: Transaction) {
        plist.override(with: transaction.plist)
    }
}

@available(*, unavailable)
extension Transaction: Sendable {}

// MARK: - withTransaction

/// Executes a closure with the specified transaction and returns the result.
///
/// - Parameters:
///   - transaction : An instance of a transaction, set as the thread's current
///     transaction.
///   - body: A closure to execute.
///
/// - Returns: The result of executing the closure with the specified
///   transaction.
public func withTransaction<Result>(
    _ transaction: Transaction,
    _ body: () throws -> Result
) rethrows -> Result {
    try withExtendedLifetime(transaction) {
        let oldData = _threadTransactionData()
        defer { _setThreadTransactionData(oldData) }
        // FIXME after Transaction update
        let result: Transaction
        if isDeployedOnOrAfter(Semantics.v5) {
            var transaction = Transaction.current
            transaction.plist.merge(transaction.plist)
            result = transaction
        } else {
            result = transaction
        }
        let data = result.plist.elements.map { Unmanaged.passUnretained($0).toOpaque() }
        _setThreadTransactionData(data)
        return try body()
    }
}

/// Executes a closure with the specified transaction key path and value and
/// returns the result.
///
/// - Parameters:
///   - keyPath: A key path that indicates the property of the ``Transaction``
///     structure to update.
///   - value: The new value to set for the item specified by `keyPath`.
///   - body: A closure to execute.
///
/// - Returns: The result of executing the closure with the specified
///   transaction value.
@_alwaysEmitIntoClient
public func withTransaction<R, V>(
    _ keyPath: WritableKeyPath<Transaction, V>,
    _ value: V,
    _ body: () throws -> R
) rethrows -> R {
    var transaction = Transaction()
    transaction[keyPath: keyPath] = value
    return try withTransaction(transaction, body)
}

// MARK: - TransactionKey

/// A key for accessing values in a transaction.
///
/// You can create custom transaction values by extending the ``Transaction``
/// structure with new properties.
/// First declare a new transaction key type and specify a value for the
/// required ``defaultValue`` property:
///
///     private struct MyTransactionKey: TransactionKey {
///         static let defaultValue = false
///     }
///
/// The Swift compiler automatically infers the associated ``Value`` type as the
/// type you specify for the default value. Then use the key to define a new
/// transaction value property:
///
///     extension Transaction {
///         var myCustomValue: Bool {
///             get { self[MyTransactionKey.self] }
///             set { self[MyTransactionKey.self] = newValue }
///         }
///     }
///
/// Clients of your transaction value never use the key directly.
/// Instead, they use the key path of your custom transaction value property.
/// To set the transaction value for a change, wrap that change in a call to
/// `withTransaction`:
///
///     withTransaction(\.myCustomValue, true) {
///         isActive.toggle()
///     }
///
/// To use the value from inside `MyView` or one of its descendants, use the
/// ``View/transaction(_:)`` view modifier:
///
///     MyView()
///         .transaction { transaction in
///             if transaction.myCustomValue {
///                 transaction.animation = .default.repeatCount(3)
///             }
///         }
public protocol TransactionKey {
    /// The associated type representing the type of the transaction key's
    /// value.
    associatedtype Value
    
    /// The default value for the transaction key.
    static var defaultValue: Value { get }
    
    static func _valuesEqual(_ lhs: Self.Value, _ rhs: Self.Value) -> Swift.Bool
}

extension TransactionKey {
    public static func _valuesEqual(_ lhs: Self.Value, _ rhs: Self.Value) -> Bool {
        compareValues(lhs, rhs)
    }
}

extension TransactionKey where Value: Equatable {
    public static func _valuesEqual(_ lhs: Self.Value, _ rhs: Self.Value) -> Bool {
        lhs == rhs
    }
}

// MARK: - TransactionPropertyKey

private struct TransactionPropertyKey<Key>: PropertyKey where Key: TransactionKey {
    typealias Value = Key.Value
    
    static var defaultValue: Key.Value { Key.defaultValue }
    
    static func valuesEqual(_ lhs: Value, _ rhs: Value) -> Bool {
        Key._valuesEqual(lhs, rhs)
    }
}

// FIXME: TO BE REMOVED
extension Transaction {
    package struct Key<K: TransactionKey>: PropertyKey {
        package static var defaultValue: K.Value { K.defaultValue }
    }
}

// MARK: - TransactionID

package struct TransactionID: Comparable, Hashable {
    package var id: Int

    @inlinable
    package init() { id = .zero }

    @inlinable
    package init(graph: Graph) {
        id = Int(graph.counter(for: ._1))
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
