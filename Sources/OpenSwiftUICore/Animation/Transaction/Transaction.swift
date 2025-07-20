//
//  Transaction.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: B2543BCA257433E04979186A1DC2B6BC (SwiftUICore)

import OpenGraphShims
import OpenSwiftUI_SPI

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
@available(OpenSwiftUI_v5_0, *)
public protocol TransactionKey {
    /// The associated type representing the type of the transaction key's
    /// value.
    associatedtype Value

    /// The default value for the transaction key.
    static var defaultValue: Value { get }

    static func _valuesEqual(_ lhs: Value, _ rhs: Value) -> Swift.Bool
}

@available(OpenSwiftUI_v5_0, *)
extension TransactionKey {
    public static func _valuesEqual(_ lhs: Value, _ rhs: Value) -> Bool {
        compareValues(lhs, rhs)
    }
}

@available(OpenSwiftUI_v5_0, *)
extension TransactionKey where Value: Equatable {
    public static func _valuesEqual(_ lhs: Value, _ rhs: Value) -> Bool {
        lhs == rhs
    }
}

// MARK: - TransactionPropertyKey

private struct TransactionPropertyKey<Key>: PropertyKey where Key: TransactionKey {
    typealias Value = Key.Value

    static var defaultValue: Value { Key.defaultValue }

    static func valuesEqual(_ lhs: Value, _ rhs: Value) -> Bool {
        Key._valuesEqual(lhs, rhs)
    }
}

// MARK: - Transaction

/// The context of the current state-processing update.
///
/// Use a transaction to pass an animation between views in a view hierarchy.
///
/// The root transaction for a state change comes from the binding that changed,
/// plus any global values set by calling ``withTransaction(_:_:)`` or
/// ``withAnimation(_:_:)``
@available(OpenSwiftUI_v1_0, *)
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
        get { plist[TransactionPropertyKey<K>.self] }
        set { plist[TransactionPropertyKey<K>.self] = newValue }
    }
    
    @inlinable
    package var isEmpty: Bool { plist.isEmpty }
    
    package func mayConcatenate(with other: Transaction) -> Bool {
        !plist.mayNotBeEqual(to: other.plist)
    }
    
    @_transparent
    package mutating func set(_ other: Transaction) {
        plist.set(other.plist)
    }
    
    package static var current: Transaction {
        Transaction(plist: PropertyList(data: threadTransactionData))
    }
    
    package var current: Transaction {
        var newTransaction = self
        newTransaction.plist.override(with: Transaction.current.plist)
        return newTransaction
    }
    
    package func forEach<K>(keyType: K.Type, _ body: (K.Value, inout Bool) -> Void) where K: TransactionKey {
        plist.forEach(
            keyType: TransactionPropertyKey<K>.self,
            body
        )
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
@available(OpenSwiftUI_v1_0, *)
public func withTransaction<Result>(
    _ transaction: Transaction,
    _ body: () throws -> Result
) rethrows -> Result {
    try withExtendedLifetime(transaction) {
        let oldData = threadTransactionData
        defer { threadTransactionData = oldData }
        let result: Transaction
        if isDeployedOnOrAfter(Semantics.v5) {
            result = Transaction(plist: Transaction.current.plist.merging(transaction.plist))
        } else {
            result = transaction
        }
        threadTransactionData = result.plist.data
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
@available(OpenSwiftUI_v1_0, *)
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

@_transparent
private var threadTransactionData: AnyObject? {
    get {
        _threadTransactionData() as AnyObject?
    }
    set {
        _setThreadTransactionData(
            newValue.map { Unmanaged.passUnretained($0).toOpaque() }
        )
    }
}

/// Returns the result of recomputing the view's body with the provided
/// animation.
///
/// This function sets the given ``Animation`` as the ``Transaction/animation``
/// property of the thread's current ``Transaction``.
@available(OpenSwiftUI_v1_0, *)
public func withAnimation<Result>(
    _ animation: Animation? = .default,
    _ body: () throws -> Result
) rethrows -> Result {
    var transaction = Transaction()
    transaction.animation = animation
    return try withTransaction(transaction, body)
}
