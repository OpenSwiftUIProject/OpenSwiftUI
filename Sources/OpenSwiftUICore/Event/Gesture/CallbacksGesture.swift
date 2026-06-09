//
//  CallbacksGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E484392718A4E902E7DCD559BC215BF0 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - GestureCallbacks

package protocol GestureCallbacks {
    associatedtype StateType = Void

    static var initialState: StateType { get }

    associatedtype Value

    func dispatch(phase: GesturePhase<Value>, state: inout StateType) -> (() -> Void)?

    func cancel(state: StateType) -> (() -> Void)?
}

extension GestureCallbacks where StateType: GestureStateProtocol {
    package static var initialState: StateType {
        StateType()
    }
}

extension GestureCallbacks where StateType == Void {
    package static var initialState: Void {
        ()
    }
}

extension GestureCallbacks {
    package func cancel(state: StateType) -> (() -> Void)? {
        nil
    }
}

// MARK: - CallbacksGesture

package struct CallbacksGesture<Callbacks>: GestureModifier where Callbacks: GestureCallbacks {
    package var callbacks: Callbacks

    package init(callbacks: Callbacks) {
        self.callbacks = callbacks
    }

    package static func _makeGesture(
        modifier: _GraphValue<Self>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<Callbacks.Value>
    ) -> _GestureOutputs<Callbacks.Value> {
        let outputs = body(inputs)
        let phase = Attribute(CallbacksPhase(
            modifier: modifier.value,
            phase: outputs.phase,
            resetSeed: inputs.resetSeed,
            useGestureGraph: inputs.options.contains(.gestureGraph),
            state: Callbacks.initialState,
            cancel: nil,
            lastResetSeed: .zero
        ))
        defer { phase.setFlags([.transactional, .removable], mask: .all) }
        return outputs.withPhase(phase)
    }

    package typealias BodyValue = Callbacks.Value

    package typealias Value = Callbacks.Value
}

// MARK: - FullGestureCallbacks

package struct FullGestureCallbacks<T>: GestureCallbacks where T: Equatable {
    package typealias Value = T

    package struct StateType: GestureStateProtocol {
        var active: Bool
        var oldPhase: GesturePhase<T>?

        package init() {
            active = false
            oldPhase = nil
        }
    }

    package var possible: ((Value?) -> Void)?
    package var changed: ((Value) -> Void)?
    package var ended: ((Value) -> Void)?
    package var failed: (() -> Void)?

    package init(
        possible: ((Value?) -> Void)? = nil,
        changed: ((Value) -> Void)? = nil,
        ended: ((Value) -> Void)? = nil,
        failed: (() -> Void)? = nil
    ) {
        self.possible = possible
        self.changed = changed
        self.ended = ended
        self.failed = failed
    }

    package func dispatch(
        phase: GesturePhase<Value>,
        state: inout StateType
    ) -> (() -> Void)? {
        guard state.oldPhase.map({ $0 != phase }) ?? true else {
            return nil
        }
        state.oldPhase = phase

        switch phase {
        case let .possible(value):
            state.active = false
            return {
                possible?(value)
            }
        case let .active(value):
            state.active = true
            guard let changed else {
                return nil
            }
            return {
                withAnimation(nil) {
                    changed(value)
                }
            }
        case let .ended(value):
            return bind(ended, value)
        case .failed:
            return failed
        }
    }

    package func cancel(state: StateType) -> (() -> Void)? {
        failed
    }
}

package typealias FullCallbacksGesture<T> = ModifierGesture<CallbacksGesture<FullGestureCallbacks<T.Value>>, T> where T: Gesture, T.Value: Equatable

// MARK: - Gesture + Callback

@available(OpenSwiftUI_v1_0, *)
extension Gesture {
    package func callbacks<Callbacks>(
        _ callbacks: Callbacks
    ) -> ModifierGesture<CallbacksGesture<Callbacks>, Self> where Callbacks: GestureCallbacks, Value == Callbacks.Value {
        modifier(CallbacksGesture(callbacks: callbacks))
    }

    /// Adds an action to perform when the gesture ends.
    ///
    /// - Important: The action is only performed if the gesture ends successfully.
    ///   Use a `@GestureState` property to track state that is reset
    ///   regardless of how the gesture ends.
    ///
    /// - Parameter action: The action to perform when this gesture ends. The
    ///   `action` closure's parameter contains the final value of the gesture.
    ///
    /// - Returns: A gesture that triggers `action` when the gesture ends.
    nonisolated public func onEnded(@_inheritActorContext _ action: @escaping (Value) -> Void) -> _EndedGesture<Self> {
        _EndedGesture(_body: callbacks(EndedCallbacks(ended: action)))
    }

    package func onFailed(_ action: @escaping () -> Void) -> ModifierGesture<CallbacksGesture<FailedCallbacks<Value>>, Self> {
        callbacks(FailedCallbacks(failed: action))
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Gesture where Value: Equatable {

    /// Adds an action to perform when the gesture's value changes.
    ///
    /// - Parameter action: The action to perform when this gesture's value
    ///   changes. The `action` closure's parameter contains the gesture's new
    ///   value.
    ///
    /// - Returns: A gesture that triggers `action` when this gesture's value
    ///   changes.
    public func onChanged(@_inheritActorContext _ action: @escaping (Value) -> Void) -> _ChangedGesture<Self> {
        _ChangedGesture(_body: callbacks(ChangedCallbacks(changed: action)))
    }

    package func callbacks(
        possible: ((Value?) -> Void)? = nil,
        changed: ((Value) -> Void)? = nil,
        ended: ((Value) -> Void)? = nil,
        failed: (() -> Void)? = nil
    ) -> FullCallbacksGesture<Self> {
        callbacks(FullGestureCallbacks(
            possible: possible,
            changed: changed,
            ended: ended,
            failed: failed
        ))
    }
}

// MARK: - _EndedGesture

@available(OpenSwiftUI_v1_0, *)
public struct _EndedGesture<Content>: PrimitiveGesture where Content: Gesture {
    fileprivate var _body: _Body

    fileprivate init(_body: _Body) {
        self._body = _body
    }

    fileprivate typealias _Body = ModifierGesture<CallbacksGesture<EndedCallbacks<Content.Value>>, Content>

    nonisolated public static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Content.Value> {
        _Body.makeDebuggableGesture(
            gesture: gesture[offset: { .of(&$0._body) }],
            inputs: inputs
        )
    }
}

@available(*, unavailable)
extension _EndedGesture: Sendable {}

// MARK: - _ChangedGesture

public struct _ChangedGesture<Content>: PrimitiveGesture where Content: Gesture, Content.Value: Equatable {
    fileprivate var _body: _Body

    fileprivate init(_body: _Body) {
        self._body = _body
    }

    fileprivate typealias _Body = ModifierGesture<CallbacksGesture<ChangedCallbacks<Content.Value>>, Content>

    nonisolated public static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Content.Value> {
        var inputs = inputs
        inputs.options.formUnion(.hasChangedCallbacks)
        return _Body.makeDebuggableGesture(
            gesture: gesture[offset: { .of(&$0._body) }],
            inputs: inputs
        )
    }
}

@available(*, unavailable)
extension _ChangedGesture: Sendable {}

// MARK: - FailedCallbacks

package struct FailedCallbacks<Value>: GestureCallbacks {
    package let failed: () -> Void

    package func dispatch(
        phase: GesturePhase<Value>,
        state: inout Void
    ) -> (() -> Void)? {
        guard case .failed = phase else {
            return nil
        }
        return failed
    }

    package func cancel(state: Void) -> (() -> Void)? {
        failed
    }

    package typealias StateType = Void
}

// MARK: - ChangedCallbacks

private struct ChangedCallbacks<Value>: GestureCallbacks where Value: Equatable {
    package let changed: (Value) -> Void

    package struct StateType: GestureStateProtocol {
        var oldValue: Value?

        package init() {
            oldValue = nil
        }
    }

    package func dispatch(
        phase: GesturePhase<Value>,
        state: inout StateType
    ) -> (() -> Void)? {
        guard case let .active(value) = phase else {
            return nil
        }
        let hasChanged = state.oldValue.map { $0 != value } ?? true
        guard hasChanged else {
            return nil
        }
        state.oldValue = value
        return {
            withAnimation(nil) {
                changed(value)
            }
        }
    }
}

// MARK: - EndedCallbacks

private struct EndedCallbacks<Value>: GestureCallbacks {
    package let ended: (Value) -> Void

    package func dispatch(
        phase: GesturePhase<Value>,
        state: inout Void
    ) -> (() -> Void)? {
        guard case let .ended(value) = phase else {
            return nil
        }
        return {
            ended(value)
        }
    }

    package typealias StateType = Void
}

// MARK: - CallbacksPhase

private struct CallbacksPhase<Callbacks>: ResettableGestureRule, RemovableAttribute where Callbacks: GestureCallbacks {
    @Attribute var modifier: CallbacksGesture<Callbacks>
    @Attribute var phase: GesturePhase<Callbacks.Value>
    @Attribute var resetSeed: UInt32
    var useGestureGraph: Bool
    var state: Callbacks.StateType
    var cancel: ((Callbacks.StateType) -> (() -> Void)?)?
    var lastResetSeed: UInt32

    typealias PhaseValue = Callbacks.Value
    typealias Value = GesturePhase<Callbacks.Value>

    mutating func resetPhase() {
        if let action = cancel?(state) {
            Update.enqueueAction(reason: nil, action)
        }
        state = Callbacks.initialState
        cancel = nil
    }

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        let (newPhase, phaseChanged) = $phase.changedValue()
        guard phaseChanged else {
            if !hasValue {
                value = newPhase
            }
            return
        }
        let callbacks = modifier.callbacks
        if let action = callbacks.dispatch(phase: newPhase, state: &state) {
            if useGestureGraph {
                GestureGraph.current.enqueueAction(action)
            } else {
                Update.enqueueAction(reason: nil, action)
            }
        }
        value = newPhase
        if newPhase.isTerminal {
            cancel = nil
        } else {
            cancel = { state in
                callbacks.cancel(state: state)
            }
        }
    }

    static func willRemove(attribute: AnyAttribute) {
        let phasePointer = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: Self.self)
        phasePointer.pointee.resetPhase()
    }

    static func didReinsert(attribute: AnyAttribute) {
        _openSwiftUIEmptyStub()
    }
}
