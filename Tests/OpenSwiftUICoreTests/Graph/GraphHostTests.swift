//
//  GraphHostTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct GraphHostTests {
    @Test
    func dataRestoresCurrentSubgraph() {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        let oldCurrent = Subgraph.current
        Subgraph.current = subgraph
        defer { Subgraph.current = oldCurrent }

        var data = GraphHost.Data()
        #expect(Subgraph.current === subgraph)
        data.invalidate()
    }

    @Test
    func transactionSeedWraps() {
        Update.perform {
            let host = GraphHost(data: .init())
            host.data.transactionSeed = .max
            host.runTransaction()
            #expect(host.data.transactionSeed == 0)
        }
    }

    @Test
    func immediateUpdateRequestSurvivesDeferredMutation() {
        let host = GraphHost(data: .init())
        host.asyncTransaction(mutation: CustomGraphMutation({}), mayDeferUpdate: false)
        #expect(!host.mayDeferUpdate)
        host.asyncTransaction(mutation: CustomGraphMutation({}), mayDeferUpdate: true)
        #expect(!host.mayDeferUpdate)
        host.flushTransactions()
        #expect(host.mayDeferUpdate)
    }

    @Test
    func inheritedRemovalUsesHiddenForReuse() {
        let parent = GraphHost(data: .init())
        let child = ChildHost(data: .init())
        child.parent = parent

        parent.removedState = .unattached
        child.updateRemovedState()
        #expect(!child.data.isRemoved)
        #expect(child.hiddenStates.isEmpty)

        parent.removedState = .hiddenForReuse
        child.updateRemovedState()
        #expect(child.data.isRemoved)
        #expect(child.hiddenStates == [true])

        child.updateRemovedState()
        #expect(child.hiddenStates == [true])

        parent.removedState = []
        child.updateRemovedState()
        #expect(!child.data.isRemoved)
        #expect(child.hiddenStates == [true, false])
    }

    @Test(arguments: [false, true])
    func uninstantiateReplacesRoot(immediately: Bool) {
        Update.perform {
            let host = GraphHost(data: .init())
            host.instantiate()
            let oldRoot = host.rootSubgraph
            host.uninstantiate(immediately: immediately)
            #expect(!host.isInstantiated)
            #expect(host.rootSubgraph !== oldRoot)
            #expect(oldRoot.isValid == !immediately)
            Update.dispatchActions()
            #expect(!oldRoot.isValid)
            host.instantiate()
            #expect(host.isInstantiated)
        }
    }

    @Test
    func continuationWithoutActiveAncestorQueuesOnOriginalHost() {
        Update.perform {
            let parent = GraphHost(data: .init())
            let child = ChildHost(data: .init())
            child.parent = parent
            var applied = 0

            child.continueTransaction { applied += 1 }
            Update.dispatchActions()
            #expect(applied == 0)

            parent.flushTransactions()
            #expect(applied == 0)
            child.flushTransactions()
            #expect(applied == 1)
        }
    }

    @Test
    func setTimeNotifiesOnlyWhenValueChanges() {
        let host = TimeHost(data: .init())
        host.setTime(.zero)
        #expect(host.observedTimes.isEmpty)

        host.setTime(Time(seconds: 1))
        host.setTime(Time(seconds: 1))
        #expect(host.observedTimes == [1])

        host.setTime(Time(seconds: 2))
        #expect(host.observedTimes == [1, 2])
    }

    @MainActor
    @Suite
    struct GraphHostTransactionTraceTests {
        @Test
        func coalescingPreservesTraceID() {
            let host = GraphHost(data: .init())
            let first = host.asyncTransaction {}
            let appended = host.asyncTransaction {}
            #expect(first != 0)
            #expect(appended == first)
            host.flushTransactions()
            let next = host.asyncTransaction {}
            #expect(next != first)
            host.flushTransactions()
        }

        @Test
        func invalidHostRejectsMutation() {
            let host = GraphHost(data: .init())
            var applied = false
            host.invalidate()
            let id = host.asyncTransaction(mutation: CustomGraphMutation { applied = true })
            #expect(id == 0)
            #expect(!host.hasPendingTransactions)
            host.flushTransactions()
            #expect(!applied)
        }

        @Test
        func immediateAppendPreservesTailAcrossFlush() {
            let host = GraphHost(data: .init())
            var applied: [Int] = []
            let first = host.asyncTransaction(id: .init(value: 10)) { applied.append(1) }
            let tail = host.asyncTransaction(id: .init(value: 20)) { applied.append(2) }
            #expect(tail != first)
            let appended = host.asyncTransaction(
                id: .init(value: 20),
                mutation: CustomGraphMutation { applied.append(3) },
                style: .immediate
            )
            #expect(appended == tail)
            #expect(applied == [1])
            host.flushTransactions()
            #expect(applied == [1, 2, 3])
        }
    }

    @MainActor
    @Suite
    struct GraphHostGlobalTransactionTests {
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
            #expect(host.changes == 1)
        }

        @Test(arguments: [
            (false, UInt32(1), 7), // Different provider.
            (true, UInt32(2), 7),  // Different transaction ID.
            (true, UInt32(1), 8),  // Incompatible transaction values.
        ])
        func incompatibleTailKeepsMutationsSeparate(sameProvider: Bool, secondID: UInt32, secondValue: Int) {
            let host = TestHost(data: .init())
            let first = Provider(host)
            let second = sameProvider ? first : Provider(host)
            let values = Values()
            let firstTransaction = transaction(value: 7)
            let secondTransaction = secondValue == 7 ? firstTransaction : transaction(value: secondValue)
            GraphHost.globalTransaction(firstTransaction, id: .init(value: 1), mutation: SumMutation(values: values, sum: 1), hostProvider: first)
            GraphHost.globalTransaction(secondTransaction, id: .init(value: secondID), mutation: SumMutation(values: values, sum: 2), hostProvider: second)
            RunLoop.flushObservers()
            #expect(values.applied == [1, 2])
        }

        @Test
        func resolvesHostAtFlushWithoutDrainingItsLocalQueue() {
            let host = TestHost(data: .init())
            let provider = Provider(nil)
            var applied: [Int] = []
            host.asyncTransaction { applied.append(2) }
            GraphHost.globalTransaction(transaction(value: 7), mutation: CustomGraphMutation {
                #expect(host.data.transaction[ValueKey.self] == 7)
                #expect(Transaction.current[ValueKey.self] == 7)
                applied.append(1)
            }, hostProvider: provider)
            provider.host = host
            RunLoop.flushObservers()
            #expect(applied == [1])
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
    }

    private final class ChildHost: GraphHost {
        var parent: GraphHost?
        var hiddenStates: [Bool] = []

        override var parentHost: GraphHost? { parent }

        override func isHiddenForReuseDidChange() {
            hiddenStates.append(data.isHiddenForReuse)
        }
    }

    private final class TimeHost: GraphHost {
        var observedTimes: [Double] = []

        override func timeDidChange() {
            observedTimes.append(data.time.seconds)
        }
    }
}
