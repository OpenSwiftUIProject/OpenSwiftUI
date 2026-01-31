//
//  SubscriptionLifetime.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 6C59EBF8CD01332EB851D19EA2F31D6B (SwiftUICore)

import OpenAttributeGraphShims
#if OPENSWIFTUI_OPENCOMBINE
package import OpenCombine
#else
package import Combine
#endif

// MARK: - SubscriptionLifetime

package class SubscriptionLifetime<Upstream>: Cancellable where Upstream: Publisher {

    // MARK: - Connection

    private struct Connection<Downstream>: Subscriber, CustomCombineIdentifierConvertible
    where Downstream: Subscriber, Upstream.Failure == Downstream.Failure, Upstream.Output == Downstream.Input {
        typealias Input = Downstream.Input

        typealias Failure = Downstream.Failure

        var combineIdentifier: CombineIdentifier = .init()

        weak var parent: SubscriptionLifetime?

        let downstream: Downstream

        let subscriptionID: Int

        init(
            parent: SubscriptionLifetime,
            downstream: Downstream,
            subscriptionID: Int
        ) {
            self.parent = parent
            self.downstream = downstream
            self.subscriptionID = subscriptionID
        }

        func receive(subscription: any Subscription) {
            guard let parent,
                  parent.shouldAcceptSubscription(subscription, for: subscriptionID) else {
                return
            }
            downstream.receive(subscription: subscription)
            subscription.request(.unlimited)
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            guard let parent,
                  parent.shouldAcceptValue(for: subscriptionID) else {
                return .none
            }
            _ = downstream.receive(input)
            return .none
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            guard let parent,
                  parent.shouldAcceptCompletion(for: subscriptionID) else {
                return
            }
            downstream.receive(completion: completion)
        }
    }

    // MARK: - StateType

    enum StateType {
        case requestedSubscription(to: Upstream, subscriber: AnyCancellable, subscriptionID: Int)
        case subscribed(to: Upstream, subscriber: AnyCancellable, subscription: Subscription, subscriptionID: Int)
        case uninitialized
    }

    var subscriptionID: UniqueSeedGenerator = .init()

    var state: StateType = .uninitialized

    package init() {
        _openSwiftUIEmptyStub()
    }

    deinit {
        cancel()
    }

    var isUninitialized: Bool {
        guard case .uninitialized = state else {
            return false
        }
        return true
    }

    private func shouldAcceptSubscription(_ subscription: any Subscription, for subscriptionID: Int) -> Bool {
        guard case let .requestedSubscription(oldPublisher, oldSubscriber, oldSubscriptionID) = state,
              oldSubscriptionID == subscriptionID else {
            subscription.cancel()
            return false
        }
        state = .subscribed(
            to: oldPublisher,
            subscriber: oldSubscriber,
            subscription: subscription,
            subscriptionID: subscriptionID
        )
        return true
    }

    private func shouldAcceptValue(for subscriptionID: Int) -> Bool {
        guard case .subscribed = state else {
            return false
        }
        return true
    }

    private func shouldAcceptCompletion(for subscriptionID: Int) -> Bool {
        guard case let .subscribed(_, _, _, oldSubscriptionID) = state,
              subscriptionID == oldSubscriptionID else {
            return false
        }
        state = .uninitialized
        return true
    }

    package func cancel() {
        guard case let .subscribed(_, subscriber, subscription, _) = state else {
            return
        }
        subscriber.cancel()
        subscription.cancel()
    }

    package func subscribe<S>(
        subscriber: S,
        to upstream: Upstream
    ) where S: Cancellable, S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
        let shouldRequest: Bool
        if case let .subscribed(oldUpstream, oldSubscriber, oldSubscription, _) = state {
            if compareValues(oldUpstream, upstream) {
                shouldRequest = false
            } else {
                oldSubscriber.cancel()
                oldSubscription.cancel()
                shouldRequest = true
            }
        } else {
            shouldRequest = true
        }
        guard shouldRequest else {
            return
        }
        let id = subscriptionID.generate()
        let connection = Connection(parent: self, downstream: subscriber, subscriptionID: id)
        state = .requestedSubscription(to: upstream, subscriber: .init(subscriber), subscriptionID: id)
        upstream.subscribe(connection)
    }
}
