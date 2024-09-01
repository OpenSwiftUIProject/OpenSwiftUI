//
//  Transaction.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

internal import COpenSwiftUI

/// The context of the current state-processing update.
///
/// Use a transaction to pass an animation between views in a view hierarchy.
///
/// The root transaction for a state change comes from the binding that changed,
/// plus any global values set by calling ``withTransaction(_:_:)`` or
/// ``withAnimation(_:_:)``
@frozen
public struct Transaction {
    /// Creates a transaction.
    @inlinable
    public init() {
        plist = PropertyList()
    }
    
    @inline(__always)
    init(plist: PropertyList) {
        self.plist = plist
    }
    
    @usableFromInline
    var plist: PropertyList
    
    @inline(__always)
    var isEmpty: Bool { plist.elements == nil }
    
    @inline(__always)
    mutating func override(_ transaction: Transaction) {
        plist.override(with: transaction.plist)
    }
    
    @inline(__always)
    static var current: Transaction {
        Transaction(plist: .current)
    }
}

extension Transaction {
    struct Key<K: TransactionKey>: PropertyKey {
        static var defaultValue: K.Value { K.defaultValue }
    }
}

protocol TransactionKey {
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

struct TransactionID {
    var id: Int
}
