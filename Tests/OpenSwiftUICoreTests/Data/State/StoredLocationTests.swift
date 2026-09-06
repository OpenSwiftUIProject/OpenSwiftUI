//
//  StoredLocationTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct StoredLocationTests {
    @Test
    func initialValueAndReadTracking() {
        let location = StoredLocation(initialValue: 42, host: nil, signal: .init())

        #expect(location.get() == 42)
        #expect(location.updateValue == 42)
        #expect(!location.wasRead)
        let (value, changed) = location.update()
        #expect(value == 42)
        #expect(changed)
        #expect(location.wasRead)
        location.wasRead = false
        #expect(!location.wasRead)
    }

    @Test
    func setDefersSavedValueAndNotification() {
        let host = GraphHost(data: .init())
        var reads = 0
        let signal = makeLocationSignal(in: host) { reads += 1 }
        let location = StoredLocation(initialValue: 0, host: host, signal: WeakAttribute(signal))
        _ = signal.value

        location.set(1, transaction: .init())
        #expect(location.get() == 1)
        #expect(location.updateValue == 0)
        #expect(host.hasPendingTransactions)
        _ = signal.value
        #expect(reads == 1)

        host.flushTransactions()
        #expect(location.updateValue == 1)
        #expect(!host.hasPendingTransactions)
        _ = signal.value
        #expect(reads == 2)
    }

    @Test
    func compatibleWritesCoalesce() {
        let host = GraphHost(data: .init())
        let location = StoredLocation(initialValue: 0, host: host, signal: .init())

        location.set(1, transaction: .init())
        location.set(2, transaction: .init())
        location.set(3, transaction: .init())
        #expect(location.get() == 3)
        #expect(location.updateValue == 0)

        host.flushTransactions()
        #expect(location.updateValue == 3)
        #expect(host.data.transactionSeed == 1)
    }

    @Test
    func differentLocationsKeepIndependentSavedValues() {
        let host = GraphHost(data: .init())
        let first = StoredLocation(initialValue: 0, host: host, signal: .init())
        let second = StoredLocation(initialValue: 10, host: host, signal: .init())

        first.set(1, transaction: .init())
        second.set(11, transaction: .init())
        first.set(2, transaction: .init())
        #expect(first.updateValue == 0)
        #expect(second.updateValue == 10)

        host.flushTransactions()
        #expect(first.updateValue == 2)
        #expect(second.updateValue == 11)
        #expect(host.data.transactionSeed == 1)
    }

    @Test(arguments: [false, true])
    func incompatibleWritesRemainSeparate(changeID: Bool) {
        let host = GraphHost(data: .init())
        let location = StoredLocation(initialValue: 0, host: host, signal: .init())
        var transaction = Transaction()
        transaction[LocationTransactionKey.self] = 1
        location.set(1, transaction: transaction)
        if changeID {
            Transaction._core_barrier()
        } else {
            transaction[LocationTransactionKey.self] = 2
        }
        location.set(2, transaction: transaction)

        host.flushTransactions()
        #expect(location.updateValue == 2)
        #expect(host.data.transactionSeed == 2)
    }

    #if canImport(Darwin)
    @Test
    func backgroundWritesPreserveTransactionIDs() throws {
        let host = GraphHost(data: .init())
        let location = StoredLocation(initialValue: 0, host: host, signal: .init())
        let completed = AtomicBox(wrappedValue: false)
        let enqueued = DispatchSemaphore(value: 0)
        DispatchQueue(label: "org.openswiftuiproject.openswiftui.stored-location-tests").async { [location = UncheckedSendable(location)] in
            defer { enqueued.signal() }
            Transaction._core_barrier()
            location.value.set(1, transaction: .init())
            Transaction._core_barrier()
            location.value.set(2, transaction: .init())
            RunLoop.main.perform(inModes: [.common]) {
                completed.wrappedValue = true
                CFRunLoopStop(CFRunLoopGetMain())
            }
        }
        try #require(enqueued.wait(timeout: .now() + 2) == .success)
        #expect(location.get() == 2)
        #expect(!host.hasPendingTransactions)

        RunLoop.runAllowingEarlyExit(until: Date(timeIntervalSinceNow: 1)) {
            completed.wrappedValue
        }
        #expect(completed.wrappedValue)
        host.flushTransactions()
        #expect(location.updateValue == 2)
        #expect(host.data.transactionSeed == 2)
    }
    #endif

    @Test
    func equalValueDoesNotScheduleTransaction() {
        let host = GraphHost(data: .init())
        let location = StoredLocation(initialValue: 7, host: host, signal: .init())

        location.set(7, transaction: .init())
        #expect(location.get() == 7)
        #expect(location.updateValue == 7)
        #expect(!host.hasPendingTransactions)
    }

    @Test
    func missingHostRejectsWrites() {
        let location = StoredLocation(initialValue: 7, host: nil, signal: .init())

        location.set(8, transaction: .init())
        #expect(location.get() == 7)
        #expect(location.updateValue == 7)
    }

    @Test
    func invalidHostClearsSavedValuesWithoutChangingCurrentValue() {
        let host = GraphHost(data: .init())
        let location = StoredLocation(initialValue: 0, host: host, signal: .init())
        location.set(1, transaction: .init())
        #expect(location.updateValue == 0)

        host.invalidate()
        location.set(2, transaction: .init())
        #expect(location.get() == 1)
        #expect(location.updateValue == 1)
    }

    @Test
    func hostIsNotRetained() {
        var host: GraphHost? = GraphHost(data: .init())
        weak let weakHost = host
        let location = StoredLocation(initialValue: 0, host: host, signal: .init())
        host = nil

        #expect(weakHost == nil)
        location.set(1, transaction: .init())
        #expect(location.get() == 0)
    }

    @Test
    func pendingMutationDoesNotRetainLocation() {
        let host = GraphHost(data: .init())
        var location: StoredLocation<Int>? = StoredLocation(initialValue: 0, host: host, signal: .init())
        weak let weakLocation = location
        location?.set(1, transaction: .init())
        location = nil

        #expect(weakLocation == nil)
        host.flushTransactions()
        #expect(!host.hasPendingTransactions)
    }

    @Test(containsRuntimeIssue("Modifying state during view update, this will cause undefined behavior."))
    func writesDuringGraphUpdateAreRejected() {
        let host = GraphHost(data: .init())
        let location = StoredLocation(initialValue: 0, host: host, signal: .init())
        let signal = makeLocationSignal(in: host) {
            #expect(host.isUpdating)
            location.set(1, transaction: .init())
        }

        _ = signal.value
        #expect(location.get() == 0)
        #expect(!host.hasPendingTransactions)
    }

    @Test
    func bindingAndProjectionsShareStorage() {
        struct Value: Equatable {
            var count = 0
            var name = "value"
        }
        let host = GraphHost(data: .init())
        let location = StoredLocation(initialValue: Value(), host: host, signal: .init())
        let projection = location.projecting(\Value.count)
        #expect(projection === location.projecting(\Value.count))

        projection.set(3, transaction: .init())
        #expect(location.get().count == 3)
        #expect(location.get().name == "value")
        host.flushTransactions()
        #expect(location.binding.wrappedValue.count == 3)

        location.binding.wrappedValue = Value(count: 5, name: "updated")
        host.flushTransactions()
        #expect(projection.get() == 5)
        #expect(location.get().name == "updated")

        location.invalidate()
        let newProjection = location.projecting(\Value.count)
        #expect(newProjection !== projection)
        #expect(newProjection.get() == 5)
        #expect(projection.get() == 5)
    }
}

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct ObservableLocationTests {
    @Test
    func initialValueAndReadTracking() {
        let location = ObservableLocation(initialValue: 42)

        #expect(location.get() == 42)
        #expect(location.updateValue == 42)
        #expect(location.mutationHost == nil)
        #expect(!location.wasRead)
        let (value, changed) = location.update()
        #expect(value == 42)
        #expect(changed)
        #expect(location.wasRead)
    }

    @Test
    func mutationHostSkipsReleasedHosts() {
        let location = ObservableLocation(initialValue: 0)
        var first: GraphHost? = GraphHost(data: .init())
        var second: GraphHost? = GraphHost(data: .init())
        weak let weakFirst = first
        weak let weakSecond = second
        location.addObserver(host: first!, signal: .init())
        location.addObserver(host: second!, signal: .init())
        #expect(location.mutationHost === first)

        first = nil
        #expect(weakFirst == nil)
        #expect(location.mutationHost === second)
        second = nil
        #expect(weakSecond == nil)
        #expect(location.mutationHost == nil)
    }

    @Test
    func removeObserverRemovesOnlyFirstMatch() {
        let first = GraphHost(data: .init())
        let second = GraphHost(data: .init())
        let signal = WeakAttribute(makeLocationSignal(in: first))
        let missingSignal = WeakAttribute(makeLocationSignal(in: first))
        let location = ObservableLocation(initialValue: 0)
        location.addObserver(host: first, signal: signal)
        location.addObserver(host: second, signal: signal)

        location.removeObserver(signal: missingSignal)
        #expect(location.mutationHost === first)
        location.removeObserver(signal: signal)
        #expect(location.mutationHost === second)
        location.removeObserver(signal: signal)
        #expect(location.mutationHost == nil)
    }

    @Test
    func removeObserverPreservesExpiredSignalIdentity() {
        let first = GraphHost(data: .init())
        let second = GraphHost(data: .init())
        let subgraph = Subgraph(graph: first.graph)
        let signals = subgraph.apply {
            (WeakAttribute(Attribute(value: ())), WeakAttribute(Attribute(value: ())))
        }
        let location = ObservableLocation(initialValue: 0)
        location.addObserver(host: first, signal: signals.0)
        location.addObserver(host: second, signal: signals.1)
        subgraph.invalidate()
        #expect(signals.0.attribute == nil)
        #expect(signals.1.attribute == nil)

        location.removeObserver(signal: signals.1)
        #expect(location.mutationHost === first)
        location.removeObserver(signal: signals.0)
        #expect(location.mutationHost == nil)
    }

    @Test
    func writesWithoutObserversStillCommit() {
        let location = ObservableLocation(initialValue: 0)
        location.set(1, transaction: .init())
        location.set(2, transaction: .init())
        #expect(location.get() == 2)
        #expect(location.updateValue == 0)

        RunLoop.flushObservers()
        #expect(location.updateValue == 2)
        #expect(location.mutationHost == nil)
    }

    @Test
    func notifiesEveryRegisteredObserver() {
        let first = GraphHost(data: .init())
        let second = GraphHost(data: .init())
        var firstReads = 0
        var secondReads = 0
        let firstSignal = makeLocationSignal(in: first) { firstReads += 1 }
        let secondSignal = makeLocationSignal(in: second) { secondReads += 1 }
        let location = ObservableLocation(initialValue: 0)
        location.addObserver(host: first, signal: WeakAttribute(firstSignal))
        location.addObserver(host: second, signal: WeakAttribute(secondSignal))
        _ = firstSignal.value
        _ = secondSignal.value

        location.set(1, transaction: .init())
        location.set(2, transaction: .init())
        _ = firstSignal.value
        _ = secondSignal.value
        #expect(firstReads == 1)
        #expect(secondReads == 1)
        RunLoop.flushObservers()
        _ = firstSignal.value
        _ = secondSignal.value
        #expect(firstReads == 2)
        #expect(secondReads == 2)
        #expect(location.updateValue == 2)
        #expect(first.data.transactionSeed == 1)

        location.removeObserver(signal: WeakAttribute(secondSignal))
        location.set(3, transaction: .init())
        RunLoop.flushObservers()
        _ = firstSignal.value
        _ = secondSignal.value
        #expect(firstReads == 3)
        #expect(secondReads == 2)
    }

    @Test
    func expiredObserversAreRemovedWithoutSkippingLiveSignals() {
        let first = GraphHost(data: .init())
        let second = GraphHost(data: .init())
        let third = GraphHost(data: .init())
        var secondReads = 0
        var thirdReads = 0
        let secondSignal = makeLocationSignal(in: second) { secondReads += 1 }
        let thirdSignal = makeLocationSignal(in: third) { thirdReads += 1 }
        let location = ObservableLocation(initialValue: 0)
        location.addObserver(host: first, signal: .init())
        location.addObserver(host: second, signal: WeakAttribute(secondSignal))
        location.addObserver(host: first, signal: .init())
        location.addObserver(host: third, signal: WeakAttribute(thirdSignal))
        _ = secondSignal.value
        _ = thirdSignal.value

        location.set(1, transaction: .init())
        RunLoop.flushObservers()
        _ = secondSignal.value
        _ = thirdSignal.value
        #expect(secondReads == 2)
        #expect(thirdReads == 2)
        #expect(location.mutationHost === third)

        location.removeObserver(signal: WeakAttribute(secondSignal))
        location.removeObserver(signal: WeakAttribute(thirdSignal))
        #expect(location.mutationHost == nil)
    }

    @Test
    func mutationHostIsResolvedWhenTransactionsFlush() {
        let first = GraphHost(data: .init())
        let second = GraphHost(data: .init())
        let firstSignal = WeakAttribute(makeLocationSignal(in: first))
        let location = ObservableLocation(initialValue: 0)
        location.addObserver(host: first, signal: firstSignal)
        location.set(1, transaction: .init())
        location.removeObserver(signal: firstSignal)
        location.addObserver(host: second, signal: WeakAttribute(makeLocationSignal(in: second)))

        RunLoop.flushObservers()
        #expect(location.updateValue == 1)
        #expect(first.data.transactionSeed == 0)
        #expect(second.data.transactionSeed == 1)
    }

    @Test(arguments: [false, true])
    func incompatibleWritesRemainSeparate(changeID: Bool) {
        let host = GraphHost(data: .init())
        let location = ObservableLocation(initialValue: 0)
        location.addObserver(host: host, signal: WeakAttribute(makeLocationSignal(in: host)))
        var transaction = Transaction()
        transaction[LocationTransactionKey.self] = 1
        location.set(1, transaction: transaction)
        if changeID {
            Transaction._core_barrier()
        } else {
            transaction[LocationTransactionKey.self] = 2
        }
        location.set(2, transaction: transaction)

        RunLoop.flushObservers()
        #expect(location.updateValue == 2)
        #expect(host.data.transactionSeed == 2)
    }

    @Test
    func equalValueDoesNotScheduleTransaction() {
        let host = GraphHost(data: .init())
        let location = ObservableLocation(initialValue: 7)
        location.addObserver(host: host, signal: .init())

        location.set(7, transaction: .init())
        RunLoop.flushObservers()
        #expect(location.updateValue == 7)
        #expect(host.data.transactionSeed == 0)
        #expect(location.mutationHost === host)
    }

    @Test(containsRuntimeIssue("Modifying state during view update, this will cause undefined behavior."))
    func writesDuringAnotherGraphUpdateAreRejected() {
        let host = GraphHost(data: .init())
        let location = ObservableLocation(initialValue: 0)
        let signal = makeLocationSignal(in: host) {
            #expect(GraphHost.isUpdating)
            location.set(1, transaction: .init())
        }

        _ = signal.value
        RunLoop.flushObservers()
        #expect(location.get() == 0)
        #expect(location.mutationHost == nil)
    }
}

private struct LocationTransactionKey: TransactionKey {
    static let defaultValue = 0
}

private struct LocationSignal: Rule {
    var body: () -> Void

    var value: Void {
        body()
    }
}

@MainActor
private func makeLocationSignal(in host: GraphHost, body: @escaping () -> Void = {}) -> Attribute<Void> {
    host.globalSubgraph.apply {
        Attribute(LocationSignal(body: body))
    }
}
