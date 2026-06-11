//
//  GestureStateTests.swift
//  OpenSwiftUITests

import Testing
import OpenSwiftUI

// MARK: - GestureStateTests

@MainActor
struct GestureStateTests {
    @Test
    func wrappedValue() {
        let state = GestureState(wrappedValue: 7)
        #expect(state.wrappedValue == 7)

        let optionalState = GestureState<Int?>()
        #expect(optionalState.wrappedValue == nil)
    }

    @Test
    func updatingCreatesGestureStateGesture() {
        let state = GestureState(wrappedValue: false)
        let gesture = TestGesture().updating(state) { value, state, _ in
            state = value > 0
        }

        #expect(gesture.state.wrappedValue == false)
    }
}

// MARK: - TestGesture

private struct TestGesture: Gesture {
    typealias Value = Int
    typealias Body = Never

    var body: Never {
        preconditionFailure("TestGesture.body should not be evaluated.")
    }

    nonisolated static func _makeGesture(
        gesture _: _GraphValue<TestGesture>,
        inputs _: _GestureInputs
    ) -> _GestureOutputs<Int> {
        preconditionFailure("TestGesture does not synthesize gesture outputs.")
    }
}
