//
//  SubscriptionView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B7395C55465EE5362F6FA49ABBDDC4FB (SwiftUI)

#if OPENSWIFTUI_OPENCOMBINE
public import OpenCombine
#else
public import Combine
#endif
import Foundation
import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - SubscriptionView

/// A view that subscribes to a publisher with an action.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct SubscriptionView<PublisherType, Content>: PrimitiveView, View where PublisherType: Publisher, Content: View, PublisherType.Failure == Never {
    /// The content view.
    public var content: Content

    /// The `Publisher` that is being subscribed.
    public var publisher: PublisherType

    /// The `Action` executed when `publisher` emits an event.
    public var action: (PublisherType.Output) -> Void

    @inlinable
    public init(content: Content, publisher: PublisherType, action: @escaping (PublisherType.Output) -> Void) {
        self.content = content
        self.publisher = publisher
        self.action = action
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let subscriber = Attribute(
            Subscriber(
                view: view.value,
                subscriptionLifetime: .init()
            )
        )
        subscriber.flags = .transactional
        return Content.makeDebuggableView(
            view: view[offset: { .of(&$0.content) }],
            inputs: inputs
        )
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        let subscriber = Attribute(
            Subscriber(
                view: view.value,
                subscriptionLifetime: .init()
            )
        )
        subscriber.flags = .transactional
        return Content.makeDebuggableViewList(
            view: view[offset: { .of(&$0.content) }],
            inputs: inputs
        )
    }

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        Content._viewListCount(inputs: inputs)
    }

    // MARK: - Subscriber

    private struct Subscriber: StatefulRule {
        @Attribute var view: SubscriptionView
        var subscriptionLifetime: SubscriptionLifetime<PublisherType>
        var actionBox: MutableBox<(PublisherType.Output) -> Void> = .init { _ in }

        typealias Value = Void

        mutating func updateValue() {
            actionBox.value = view.action
            let subscriber = ActionDispatcherSubscriber<PublisherType.Output>(
                actionBox: actionBox,
                combineIdentifier: CombineIdentifier()
            )
            subscriptionLifetime.subscribe(subscriber: subscriber, to: view.publisher)
        }
    }
}

@available(*, unavailable)
extension SubscriptionView: Sendable {}

// MARK: - ActionDispatcherSubscriber

private struct ActionDispatcherSubscriber<V>: Subscriber, Cancellable  {
    var actionBox: MutableBox<(V) -> Void>
    var combineIdentifier: CombineIdentifier

    init(actionBox: MutableBox<(V) -> Void>, combineIdentifier: CombineIdentifier) {
        self.actionBox = actionBox
        self.combineIdentifier = combineIdentifier
    }

    typealias Input = V

    typealias Failure = Never

    func respond(to input: V) {
        if !Thread.isMainThread {
            Log.runtimeIssues("Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.")
        }
        onMainThread {
            actionBox.value(input)
        }
    }

    func receive(subscription: any Subscription) {
        subscription.request(.unlimited)
    }

    func receive(_ input: V) -> Subscribers.Demand {
        respond(to: input)
        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {
        _openSwiftUIEmptyStub()
    }

    func cancel() {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - View + onReceive

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Adds an action to perform when this view detects data emitted by the
    /// given publisher.
    ///
    /// - Parameters:
    ///   - publisher: The publisher to subscribe to.
    ///   - action: The action to perform when an event is emitted by
    ///     `publisher`. The event emitted by publisher is passed as a
    ///     parameter to `action`.
    ///
    /// - Returns: A view that triggers `action` when `publisher` emits an
    ///   event.
    @inlinable
    nonisolated public func onReceive<P>(
        _ publisher: P,
        perform action: @escaping (P.Output) -> Void
    ) -> some View where P: Publisher, P.Failure == Never {
        SubscriptionView(
            content: self,
            publisher: publisher,
            action: action
        )
    }
}
