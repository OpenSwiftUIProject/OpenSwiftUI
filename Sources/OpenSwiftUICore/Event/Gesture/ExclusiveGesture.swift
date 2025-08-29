//
//  ExclusiveGesture.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: C6A5F4DE707A20D3CFD8B7768E28573B (SwiftUICore)

import OpenAttributeGraphShims

@available(OpenSwiftUI_v1_0, *)
extension Gesture {
    /// Combines two gestures exclusively to create a new gesture where only one
    /// gesture succeeds, giving precedence to the first gesture.
    ///
    /// - Parameter other: A gesture you combine with your gesture, to create a
    ///   new, combined gesture.
    ///
    /// - Returns: A gesture that's the result of combining two gestures where
    ///   only one of them can succeed. OpenSwiftUI gives precedence to the first
    ///   gesture.
    @inlinable
    public func exclusively<Other>(before other: Other) -> ExclusiveGesture<Self, Other> where Other: Gesture {
        return ExclusiveGesture(self, other)
    }
}

/// A gesture that consists of two gestures where only one of them can succeed.
///
/// The `ExclusiveGesture` gives precedence to its first gesture.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct ExclusiveGesture<First, Second>: PrimitiveGesture, Gesture where First: Gesture, Second: Gesture {
    /// The value of an exclusive gesture that indicates which of two gestures
    /// succeeded.
    @frozen
    public enum Value {
        /// The first of two gestures succeeded.
        case first(First.Value)

        /// The second of two gestures succeeded.
        case second(Second.Value)
    }

    /// The first of two gestures.
    public var first: First

    /// The second of two gestures.
    public var second: Second

    /// Creates a gesture from two gestures where only one of them succeeds.
    ///
    /// - Parameters:
    ///   - first: The first of two gestures. This gesture has precedence over
    ///     the other gesture.
    ///   - second: The second of two gestures.
    @inlinable
    public init(_ first: First, _ second: Second) {
        (self.first, self.second) = (first, second)
    }

    nonisolated public static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Value> {
        var inputs = inputs
        let outputs1 = First.makeDebuggableGesture(
            gesture: gesture[offset: { .of(&$0.first) }],
            inputs: inputs
        )
        inputs.inheritedPhase = Attribute(ExclusiveState(state: inputs.inheritedPhase, phase: outputs1.phase))
        let outputs2 = Second.makeDebuggableGesture(
            gesture: gesture[offset: { .of(&$0.second) }],
            inputs: inputs
        )
        let phase = Attribute(ExclusivePhase<First, Second>(
            phase1: outputs1.phase,
            phase2: outputs2.phase
        ))
        var outputs = _GestureOutputs(phase: phase)
        outputs.wrapDebugOutputs(
            Self.self,
            kind: .combiner,
            inputs: inputs,
            combiningOutputs: (outputs1, outputs2)
        )
        for key in inputs.preferences.keys {
            func project<K>(_ key: K.Type) where K: PreferenceKey {
                outputs[anyKey: key] = Attribute(ExclusivePreference<First, Second, K>(
                    value1: .init(base: AnyOptionalAttribute(outputs1[anyKey: key])),
                    value2: .init(base: AnyOptionalAttribute(outputs2[anyKey: key])),
                    phase1: outputs1.phase,
                    phase2: outputs2.phase
                )).identifier
            }
            project(key)
        }
        return outputs

    }
}

@available(OpenSwiftUI_v1_0, *)
extension ExclusiveGesture.Value: Sendable where First.Value: Sendable, Second.Value: Sendable {}

@available(*, unavailable)
extension ExclusiveGesture: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension ExclusiveGesture: PrimitiveDebuggableGesture {}

@available(OpenSwiftUI_v1_0, *)
extension ExclusiveGesture.Value: Equatable where First.Value: Equatable, Second.Value: Equatable {}

extension ExclusiveGesture.Value: Hashable where First.Value: Hashable, Second.Value: Hashable {}

private struct ExclusivePreference<First, Second, Key>: Rule where First: Gesture, Second: Gesture, Key: PreferenceKey {
    @OptionalAttribute var value1: Key.Value?
    @OptionalAttribute var value2: Key.Value?
    @Attribute var phase1: GesturePhase<First.Value>
    @Attribute var phase2: GesturePhase<Second.Value>

    typealias Value = Key.Value

    var value: Value {
        switch (phase1, phase2) {
        case (.active, _), (.ended, _), (.possible(.some), _), (.possible(.none), .failed): value1 ?? Key.defaultValue
        case (_, .active), (_, .ended), (_, .possible(.some)), (.failed, .possible(.none)): value2 ?? Key.defaultValue
        case (.possible(.none), .possible(.none)): mergedValue()
        case (.failed, .failed): Key.defaultValue
        }
    }

    @inline(__always)
    func mergedValue() -> Key.Value {
        if let value1, let value2 {
            var result = value1
            Key.reduce(value: &result) { value2 }
            return result
        } else {
            return value1 ?? value2 ?? Key.defaultValue
        }
    }
}

private struct ExclusivePhase<First, Second>: Rule where First: Gesture, Second: Gesture {
    @Attribute var phase1: GesturePhase<First.Value>
    @Attribute var phase2: GesturePhase<Second.Value>

    typealias Value = GesturePhase<ExclusiveGesture<First, Second>.Value>

    var value: Value {
        switch (phase1, phase2) {
        case let (.active(value1), _):
            .active(.first(value1))
        case let (.possible, .active(value2)):
            .active(.second(value2))
        case let (.possible(.some(value1)), _):
            .possible(.first(value1))
        case let (.possible, .possible(.some(value2))):
            .possible(.second(value2))
        case (.possible, _):
            .possible(nil)
        case let (.ended(value1), _):
            .ended(.first(value1))
        case let (.failed, .active(value2)):
            .active(.second(value2))
        case let (.failed, .possible(.some(value2))):
            .possible(.second(value2))
        case let (.failed, .ended(value2)):
            .ended(.second(value2))
        case (.failed, _):
            .failed
        }
    }
}

private struct ExclusiveState<V>: Rule {
    @Attribute var state: _GestureInputs.InheritedPhase
    @Attribute var phase: GesturePhase<V>

    typealias Value = _GestureInputs.InheritedPhase

    var value: Value {
        var result = state
        if !phase.isFailed {
            result.subtract(.failed)
        }
        if phase.isActive {
            result.insert(.active)
        }
        return result
    }
}
