//
//  EmptyGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - EmptyGesture

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
