//
//  StateContainerGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: EA62389F5A6356B5DBAFB6A6AFC6ECC7 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - GestureStateProtocol

package protocol GestureStateProtocol {
    init()
}

extension GestureStateProtocol {
    package static func gesture<T, U>(
        content: T,
        _ body: @escaping (inout Self, GesturePhase<T.Value>) -> GesturePhase<U>
    ) -> ModifierGesture<StateContainerGesture<Self, T.Value, U>, T> where T: Gesture {
        content.modifier(StateContainerGesture(body))
    }
}

// MARK: - StateContainerGesture

package struct StateContainerGesture<StateType, BodyValue, Value>: GestureModifier where StateType: GestureStateProtocol {
    package var body: (inout StateType, GesturePhase<BodyValue>) -> GesturePhase<Value>

    package init(_ body: @escaping (inout StateType, GesturePhase<BodyValue>) -> GesturePhase<Value>) {
        self.body = body
    }

    package static func _makeGesture(
        modifier: _GraphValue<Self>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<BodyValue>
    ) -> _GestureOutputs<Value> {
        let outputs = body(inputs)
        let phase = Attribute(StateContainerPhase(
            modifier: modifier.value,
            childPhase: outputs.phase,
            resetSeed: inputs.resetSeed,
            state: StateType(),
            lastResetSeed: .zero
        ))
        return outputs.withPhase(phase)
    }
}

// MARK: - StateContainerPhase

private struct StateContainerPhase<StateType, ResultValue, BodyValue>: ResettableGestureRule, CustomStringConvertible where StateType: GestureStateProtocol {
    @Attribute var modifier: StateContainerGesture<StateType, BodyValue, ResultValue>
    @Attribute var childPhase: GesturePhase<BodyValue>
    @Attribute var resetSeed: UInt32
    var state: StateType
    var lastResetSeed: UInt32

    typealias PhaseValue = ResultValue
    typealias Value = GesturePhase<ResultValue>

    mutating func resetPhase() {
        state = StateType()
    }

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        value = modifier.body(&state, childPhase)
    }

    var description: String {
        "State → \(StateType.self)"
    }
}
