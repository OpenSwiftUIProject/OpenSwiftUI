//
//  AttributeInvalidatingSubscriber.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation
import OpenAttributeGraphShims
#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif

// MARK: - AttributeInvalidatingSubscriber

class AttributeInvalidatingSubscriber<Upstream> where Upstream: Publisher {
    typealias Input = Upstream.Output

    typealias Failure = Upstream.Failure

    // MARK: - StateType

    enum StateType {
        case subscribed(any Subscription)
        case unsubscribed
        case complete
    }

    weak var host: GraphHost?

    let attribute: WeakAttribute<()>

    var state: StateType

    init(host: GraphHost, attribute: WeakAttribute<()>) {
        self.host = host
        self.attribute = attribute
        self.state = .unsubscribed
    }

    private func invalidateAttribute() {
        let style: GraphMutation.Style
        if !Thread.isMainThread {
            Log.runtimeIssues("Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.")
            style = .immediate
        } else if Update.threadIsUpdating, isLinkedOnOrAfter(.v4) {
            Log.runtimeIssues("Publishing changes from within view updates is not allowed, this will cause undefined behavior.")
            style = .deferred
        } else {
            style = .immediate
        }
        Update.perform {
            guard let host else { return }
            host.asyncTransaction(
                .current,
                invalidating: attribute,
                style: style
            )
        }
    }
}

// MARK: - AttributeInvalidatingSubscriber + Subscriber

extension AttributeInvalidatingSubscriber: Subscriber {
    func receive(subscription: any Subscription) {
        guard case .unsubscribed = state else {
            subscription.cancel()
            return
        }
        state = .subscribed(subscription)
        subscription.request(.unlimited)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if case .subscribed = state {
            invalidateAttribute()
        }
        return .none
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        guard case .subscribed = state else {
            return
        }
        state = .complete
        invalidateAttribute()
    }
}

// MARK: - AttributeInvalidatingSubscriber + Cancellable

extension AttributeInvalidatingSubscriber: Cancellable {
    func cancel() {
        if case let .subscribed(subscription) = state {
            subscription.cancel()
        }
        state = .unsubscribed
    }
}

// MARK: - AttributeInvalidatingSubscriber + CustomCombineIdentifierConvertible

extension AttributeInvalidatingSubscriber: CustomCombineIdentifierConvertible {}
