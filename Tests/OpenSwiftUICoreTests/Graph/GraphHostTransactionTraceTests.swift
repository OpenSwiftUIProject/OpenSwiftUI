//
//  GraphHostTransactionTraceTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@MainActor
struct GraphHostTransactionTraceTests {
    #if canImport(Darwin)
    @Test
    func coalescingPreservesTraceID() {
        let host = GraphHost(data: .init())
        let first = host.asyncTransaction {}
        let appended = host.asyncTransaction {}
        #expect(first >= 2)
        #expect(appended == first)
        host.flushTransactions()
        let next = host.asyncTransaction {}
        #expect(next > first)
        host.flushTransactions()
    }

    @Test
    func invalidHostReturnsZero() {
        let host = GraphHost(data: .init())
        host.invalidate()
        #expect(host.asyncTransaction {} == 0)
        #expect(host.asyncTransaction(mutation: CustomGraphMutation({})) == 0)
        #expect(host.asyncTransaction(invalidating: WeakAttribute<Int>()) == 0)
        #expect(host.emptyTransaction() == 0)
        #expect(!host.hasPendingTransactions)
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

    @Test
    func wrappersReturnCoalescedID() {
        let host = GraphHost(data: .init())
        let first = host.asyncTransaction(invalidating: WeakAttribute<Int>())
        #expect(first >= 2)
        #expect(host.emptyTransaction() == first)
        #expect(host.asyncTransaction {} == first)
        host.flushTransactions()
    }

    @Test
    func continuationQueuesNewTransaction() {
        Update.perform {
            let host = GraphHost(data: .init())
            var applied = false
            host.continueTransaction { applied = true }
            Update.dispatchActions()
            #expect(host.hasPendingTransactions)
            #expect(!applied)
            host.flushTransactions()
            #expect(applied)
            #expect(!host.hasPendingTransactions)
        }
    }
    #endif
}
