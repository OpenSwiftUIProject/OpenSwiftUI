//
//  ProgressView+Foundation.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3E94A30D8C602D81EB55934DA2DC2E22 (SwiftUI)

#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
import OpenCombineFoundation
#else
import Combine
#endif
import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - Progress + UI State

extension Foundation.Progress {
    fileprivate struct UIState {
        var fractionCompleted: Double
        var isIndeterminate: Bool
        var localizedDescription: String
        var localizedAdditionalDescription: String
    }

    fileprivate var uiState: UIState {
        UIState(
            fractionCompleted: fractionCompleted,
            isIndeterminate: isIndeterminate,
            localizedDescription: localizedDescription,
            localizedAdditionalDescription: localizedAdditionalDescription
        )
    }

    #if !OPENSWIFTUI_OPENCOMBINE
    fileprivate typealias UIStatePublisher = Publishers.Map<
        Publishers.CombineLatest4<
            NSObject.KeyValueObservingPublisher<Foundation.Progress, Int64>,
            NSObject.KeyValueObservingPublisher<Foundation.Progress, Int64>,
            NSObject.KeyValueObservingPublisher<Foundation.Progress, String>,
            NSObject.KeyValueObservingPublisher<Foundation.Progress, String>
        >,
        UIState
    >

    fileprivate var uiStatePublisher: UIStatePublisher {
        Publishers.CombineLatest4(
            publisher(
                for: \.completedUnitCount,
                options: [.initial, .new]
            ),
            publisher(
                for: \.totalUnitCount,
                options: [.initial, .new]
            ),
            publisher(
                for: \.localizedDescription,
                options: [.initial, .new]
            ),
            publisher(
                for: \.localizedAdditionalDescription,
                options: [.initial, .new]
            )
        ).map { [unowned self] _ in
            uiState
        }
    }
    #else
    // TODO: Implement NSObject.KeyValueObservingPublisher in OpenCombine
    fileprivate typealias UIStatePublisher = AnyPublisher<UIState, Never>

    fileprivate var uiStatePublisher: UIStatePublisher {
        // [AI] OpenCombineFoundation does not provide KVO publishers. Sample
        // Progress while the graph-owned subscription is active instead.
        Foundation.Timer.publish(
            every: 1.0 / 30.0,
            on: .main,
            in: .common
        )
        .autoconnect()
        .map { [unowned self] _ in
            uiState
        }
        .eraseToAnyPublisher()
    }
    #endif

    fileprivate struct UIStateSubscriber: Subscriber, Cancellable {
        @Binding var viewState: UIState?
        var combineIdentifier = CombineIdentifier()

        func respond(to state: UIState) {
            func update() {
                viewState = state
            }

            if Thread.isMainThread {
                Update.enqueueAction(reason: nil, update)
            } else {
                update()
            }
        }

        func receive(subscription: any Subscription) {
            subscription.request(.unlimited)
        }

        func receive(_ input: UIState) -> Subscribers.Demand {
            respond(to: input)
            return .none
        }

        func receive(completion _: Subscribers.Completion<Never>) {
            _openSwiftUIEmptyStub()
        }

        func cancel() {
            _openSwiftUIEmptyStub()
        }
    }
}

// MARK: - FoundationProgressView

struct FoundationProgressView: View {
    var progress: Foundation.Progress
    @State private var state: Foundation.Progress.UIState?

    var body: Body {
        Body(progress: progress, state: $state)
    }

    struct Body: MultiView, PrimitiveView, View {
        var progress: Foundation.Progress

        @Binding
        fileprivate var state: Foundation.Progress.UIState?

        nonisolated static func _makeViewList(
            view: _GraphValue<Self>,
            inputs: _ViewListInputs
        ) -> _ViewListOutputs {
            let value = Attribute(
                BodyAttribute(
                    view: view.value,
                    subscription: .init()
                )
            )
            return BodyAttribute.Value._makeViewList(
                view: _GraphValue(value),
                inputs: inputs
            )
        }

        private struct BodyAttribute: StatefulRule {
            @Attribute var view: Body
            var subscription: SubscriptionLifetime<Foundation.Progress.UIStatePublisher>

            mutating func updateValue() {
                let subscriber = Foundation.Progress.UIStateSubscriber(viewState: view.$state)
                subscription.subscribe(
                    subscriber: subscriber,
                    to: view.progress.uiStatePublisher
                )
                value = Value(state: view.state ?? view.progress.uiState)
            }

            struct Value: View {
                var state: Foundation.Progress.UIState

                var body: some View {
                    ResolvedProgressView(
                        value: .absolute(
                            fractionCompleted: state.isIndeterminate ? nil : state.fractionCompleted,
                            alwaysIndeterminate: false
                        )
                    )
                    .optionalViewAlias(ProgressViewStyleConfiguration.CurrentValueLabel.self) {
                        state.localizedAdditionalDescription.isEmpty ? nil : Text(state.localizedAdditionalDescription)
                    }
                    .optionalViewAlias(ProgressViewStyleConfiguration.Label.self) {
                        state.localizedDescription.isEmpty ? nil : Text(state.localizedDescription)
                    }
                }
            }
        }
    }
}
