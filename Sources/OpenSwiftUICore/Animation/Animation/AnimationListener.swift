//
//  AnimationListener.swift
//  OpenSwiftUICore
//
//  Audited: 6.5.4
//  Status: Complete
//  ID: 390609F81ACEBEAF00AD8179BD31E870 (SwiftUICore)

import Dispatch

// MARK: - AnimationListener

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
open class AnimationListener: @unchecked Sendable {
    public init() {
        _openSwiftUIEmptyStub()
    }

    open func animationWasAdded() {
        _openSwiftUIEmptyStub()
    }

    open func animationWasRemoved() {
        _openSwiftUIEmptyStub()
    }

    open func finalizeTransaction() {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - ListenerPair

private final class ListenerPair: AnimationListener, @unchecked Sendable {
    let first: AnimationListener
    let second: AnimationListener

    init(first: AnimationListener, second: AnimationListener) {
        self.first = first
        self.second = second
        super.init()
    }

    override func animationWasAdded() {
        first.animationWasAdded()
        second.animationWasAdded()
    }

    override func animationWasRemoved() {
        first.animationWasAdded()
        second.animationWasRemoved()
    }
}

// MARK: - AllFinishedListener

private final class AllFinishedListener: AnimationListener, @unchecked Sendable {
    let allFinished: (Transaction.AnimationCompletionInfo) -> Void
    var count: Int
    var maxCount: Int
    var dispatched: Bool

    init(allFinished: @escaping (Transaction.AnimationCompletionInfo) -> Void) {
        self.allFinished = allFinished
        self.count = 0
        self.maxCount = 0
        self.dispatched = false
        super.init()
    }

    override func animationWasAdded() {
        count += 1
        maxCount += 1
    }

    override func animationWasRemoved() {
        count -= 1
        dispatchIfNeeded()
    }

    override func finalizeTransaction() {
        dispatchIfNeeded()
    }

    @inline(__always)
    func dispatchIfNeeded() {
        guard count == 0, !dispatched else {
            return
        }
        dispatched = true
        allFinished(.init(completedCount: maxCount))
    }

    deinit {
        dispatchIfNeeded()
    }
}

// MARK: - Transaction + AnimationListener

extension Transaction {
    private static var pendingListeners = AtomicBox(wrappedValue: PendingListeners())

    private struct PendingListeners {
        var pending: [WeakListener] = []
        var next: DispatchTime?

        struct WeakListener {
            weak var listener: AnimationListener?
            var time: DispatchTime
        }
    }

    private static func addPendingListener(_ listener: AnimationListener) {
        pendingListeners.access { pendingListeners in
            let time = DispatchTime.now() + 0.01
            pendingListeners.pending.append(.init(listener: listener, time: time))
            if pendingListeners.next == nil {
                pendingListeners.next = time
                DispatchQueue.main.asyncAfter(deadline: time) {
                    dispatchPending()
                }
            }
        }
    }

    private static func dispatchPending() {
        let pendingListeners = pendingListeners.access { pendingListeners in
            guard let next = pendingListeners.next else {
                let pending = pendingListeners.pending
                pendingListeners.pending = []
                return pending
            }
            pendingListeners.next = nil
            let pending = pendingListeners.pending
            let filtered = pending.filter { $0.time > next }
            pendingListeners.pending = filtered
            guard !filtered.isEmpty else {
                return pending
            }
            DispatchQueue.main.asyncAfter(deadline: next) {
                dispatchPending()
            }
            return pending.filter { $0.time <= next }
        }
        guard !pendingListeners.isEmpty else {
            return
        }
        Update.ensure {
            for pendingListener in pendingListeners {
                guard let listener = pendingListener.listener else {
                    continue
                }
                listener.finalizeTransaction()
            }
        }
    }

    private struct AnimationListenerKey: TransactionKey {
        static var defaultValue: AnimationListener? { nil }
    }

    package var animationListener: AnimationListener? {
        self[AnimationListenerKey.self]
    }

    package mutating func addAnimationListener(_ listener: AnimationListener) {
        Self.addPendingListener(listener)
        if let existing = self[AnimationListenerKey.self] {
            self[AnimationListenerKey.self] = ListenerPair(first: existing, second: listener)
        } else {
            self[AnimationListenerKey.self] = listener
        }
    }

    package mutating func addAnimationListener(allFinished: @escaping () -> Void) {
        addAnimationListener(AllFinishedListener(allFinished: { _ in allFinished() }))
    }

    package mutating func addAnimationListener(allFinished: @escaping (Transaction.AnimationCompletionInfo) -> Void) {
        addAnimationListener(AllFinishedListener(allFinished: allFinished))
    }

    private struct AnimationLogicalListenerKey: TransactionKey {
        static var defaultValue: AnimationListener? { nil }
    }

    package var animationLogicalListener: AnimationListener? {
        self[AnimationLogicalListenerKey.self]
    }

    package mutating func addAnimationLogicalListener(_ listener: AnimationListener) {
        Self.addPendingListener(listener)
        if let existing = self[AnimationLogicalListenerKey.self] {
            self[AnimationLogicalListenerKey.self] = ListenerPair(first: existing, second: listener)
        } else {
            self[AnimationLogicalListenerKey.self] = listener
        }
    }

    package mutating func addAnimationLogicalListener(allFinished: @escaping () -> Void) {
        addAnimationLogicalListener(AllFinishedListener(allFinished: { _ in allFinished() }))
    }

    package mutating func addAnimationLogicalListener(allFinished: @escaping (Transaction.AnimationCompletionInfo) -> Void) {
        addAnimationLogicalListener(AllFinishedListener(allFinished: allFinished))
    }

    package struct AnimationCompletionInfo {
        package var completedCount: Int

        package init(completedCount: Int) {
            self.completedCount = completedCount
        }
    }

    package var combinedAnimationListener: AnimationListener? {
        let animationListener = animationListener
        let animationLogicalListener = animationLogicalListener
        if let animationListener, let animationLogicalListener {
            return ListenerPair(first: animationListener, second: animationLogicalListener)
        } else {
            return animationListener ?? animationLogicalListener
        }
    }
}
