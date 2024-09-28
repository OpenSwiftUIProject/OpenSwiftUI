//
//  Transaction.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

internal import COpenSwiftUICore

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
    
    @inline(__always)
    package var isEmpty: Bool { plist.elements == nil }
    
    @inline(__always)
    mutating package func override(_ transaction: Transaction) {
        plist.override(with: transaction.plist)
    }
    
    @inline(__always)
    package static var current: Transaction {
        Transaction(plist: .current)
    }
}

extension Transaction {
    package struct Key<K: TransactionKey>: PropertyKey {
        package static var defaultValue: K.Value { K.defaultValue }
    }
}

package protocol TransactionKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

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
        let data = transaction.plist.elements.map { Unmanaged.passUnretained($0).toOpaque() }        
        _setThreadTransactionData(data)
        return try body()
    }
}

package struct TransactionID {
    package var id: Int
    package init(id: Int) {
        self.id = id
    }
}
