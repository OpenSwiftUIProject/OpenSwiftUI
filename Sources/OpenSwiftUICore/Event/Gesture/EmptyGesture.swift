//
//  EmptyGesture.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - EmptyGesture [6.5.4]

package struct EmptyGesture<Value>: PrimitiveGesture {
    package init() {}

    nonisolated package static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Value> {
        let phase = inputs.intern(GesturePhase<Value>.failed, id: .failedValue)
        return _GestureOutputs(phase: phase)
    }
}
