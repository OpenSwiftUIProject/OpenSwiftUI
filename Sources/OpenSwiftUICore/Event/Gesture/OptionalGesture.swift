//
//  OptionalGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: AA5A5D08CE822AD3F841F82D9B77CD0F (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - Optional + Gesture

@available(OpenSwiftUI_v1_0, *)
extension Optional: Gesture where Wrapped: Gesture {
    private struct Child: Rule {
        @Attribute var gesture: Wrapped?

        typealias Value = AnyGesture<Wrapped.Value>

        var value: AnyGesture<Wrapped.Value> {
            gesture.map { AnyGesture($0) } ?? AnyGesture(Empty())
        }
    }

    private struct Empty: PrimitiveGesture {
        typealias Value = Wrapped.Value

        nonisolated static func _makeGesture(
            gesture: _GraphValue<Self>,
            inputs: _GestureInputs
        ) -> _GestureOutputs<Wrapped.Value> {
            _GestureOutputs(phase: Attribute(value: GesturePhase<Wrapped.Value>.failed))
        }

        typealias Body = Never
    }

    public typealias Value = Wrapped.Value

    nonisolated public static func _makeGesture(
        gesture: _GraphValue<Optional<Wrapped>>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Wrapped.Value> {
        let child = Attribute(Child(gesture: gesture.value))
        return AnyGesture<Wrapped.Value>.makeDebuggableGesture(
            gesture: _GraphValue(child),
            inputs: inputs
        )
    }

    public typealias Body = Never
}

@available(OpenSwiftUI_v1_0, *)
extension Optional: PrimitiveGesture where Wrapped: Gesture {}
