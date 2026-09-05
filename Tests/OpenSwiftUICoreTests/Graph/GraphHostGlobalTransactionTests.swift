//
//  GraphHostGlobalTransactionTests.swift
//  OpenSwiftUICoreTests

import Foundation
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@MainActor
struct GraphHostGlobalTransactionTests {
    #if canImport(Darwin)
    @Test
    func compatibleTailCombinesMutations() {
        let host = TestHost(data: .init())
        let provider = Provider(host)
        let values = Values()
        let transaction = transaction(value: 7)
        GraphHost.globalTransaction(transaction, id: .init(value: 10), mutation: SumMutation(values: values, sum: 1), hostProvider: provider)
        GraphHost.globalTransaction(transaction, id: .init(value: 10), mutation: SumMutation(values: values, sum: 2), hostProvider: provider)
        #expect(provider.reads == 0)
        #expect(values.applied.isEmpty)
        RunLoop.flushObservers()
        #expect(values.applied == [3])
        #expect(provider.reads == 1)
        #expect(host.data.transactionSeed == 1)
        #expect(host.changes == 1)
    }

    @Test
    func providerIdentityIDAndCompatibilitySeparateEntries() {
        let host = TestHost(data: .init())
        let first = Provider(host)
        let second = Provider(host)
        let values = Values()
        for (provider, id, value) in [(first, UInt32(1), 7), (second, 1, 7), (second, 2, 7), (second, 2, 8)] {
            GraphHost.globalTransaction(transaction(value: value), id: .init(value: id), mutation: CustomGraphMutation {
                values.applied.append(Transaction.current[ValueKey.self])
            }, hostProvider: provider)
        }
        RunLoop.flushObservers()
        #expect(values.applied == [7, 7, 7, 8])
        #expect(first.reads == 1)
        #expect(second.reads == 3)
        #expect(host.data.transactionSeed == 4)
        #expect(host.changes == 4)
    }

    @Test
    func resolvesHostAtFlushWithoutDrainingItsLocalQueue() {
        let host = TestHost(data: .init())
        let provider = Provider(nil)
        var applied: [Int] = []
        host.asyncTransaction { applied.append(2) }
        GraphHost.globalTransaction(transaction(value: 7), mutation: CustomGraphMutation {
            #expect(host.inTransaction)
            #expect(host.data.transaction[ValueKey.self] == 7)
            #expect(Transaction.current[ValueKey.self] == 7)
            applied.append(1)
        }, hostProvider: provider)
        provider.host = host
        RunLoop.flushObservers()
        #expect(applied == [1])
        #expect(host.hasPendingTransactions)
        #expect(!host.inTransaction)
        #expect(host.data.transaction.isEmpty)
        host.flushTransactions()
        #expect(applied == [1, 2])
    }

    @Test
    func missingHostStillAppliesAndRestoresThreadTransaction() {
        let provider = Provider(nil)
        var observed: [Int] = []
        GraphHost.globalTransaction(transaction(value: 7), mutation: CustomGraphMutation {
            observed.append(Transaction.current[ValueKey.self])
        }, hostProvider: provider)
        withTransaction(transaction(value: 21)) {
            RunLoop.flushObservers()
            #expect(Transaction.current[ValueKey.self] == 21)
        }
        #expect(observed == [7])
        #expect(provider.reads == 1)
    }

    @Test
    func reentrantEnqueueRunsAfterTheCurrentSnapshot() {
        let host = TestHost(data: .init())
        let provider = Provider(host)
        var applied: [Int] = []
        GraphHost.globalTransaction(id: .init(value: 1), mutation: CustomGraphMutation {
            applied.append(1)
            GraphHost.globalTransaction(id: .init(value: 2), mutation: CustomGraphMutation {
                applied.append(3)
            }, hostProvider: provider)
        }, hostProvider: provider)
        GraphHost.globalTransaction(id: .init(value: 2), mutation: CustomGraphMutation {
            applied.append(2)
        }, hostProvider: provider)
        RunLoop.flushObservers()
        #expect(applied == [1, 2, 3])
        #expect(provider.reads == 3)
        #expect(host.data.transactionSeed == 3)
    }

    private func transaction(value: Int) -> Transaction {
        var transaction = Transaction()
        transaction[ValueKey.self] = value
        return transaction
    }

    private struct ValueKey: TransactionKey {
        static let defaultValue = 0
    }

    private final class Values {
        var applied: [Int] = []
    }

    private struct SumMutation: GraphMutation {
        let values: Values
        var sum: Int

        func apply() { values.applied.append(sum) }

        mutating func combine<T>(with other: T) -> Bool where T: GraphMutation {
            guard let other = other as? SumMutation, values === other.values else { return false }
            sum += other.sum
            return true
        }
    }

    private final class Provider: TransactionHostProvider {
        var host: GraphHost?
        var reads = 0
        var mutationHost: GraphHost? {
            reads += 1
            return host
        }
        init(_ host: GraphHost?) { self.host = host }
    }

    private final class TestHost: GraphHost, GraphDelegate {
        var changes = 0
        override var graphDelegate: GraphDelegate? { self }
        func updateGraph<T>(body: (GraphHost) -> T) -> T { body(self) }
        func graphDidChange() { changes += 1 }
        func preferencesDidChange() {}
        func beginTransaction() {}
    }
    #endif
}
