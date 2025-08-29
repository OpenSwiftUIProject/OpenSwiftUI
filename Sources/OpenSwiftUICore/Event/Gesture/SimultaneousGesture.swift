//
//  SimultaneousGesture.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: FD72499B2A88A75B09DC7635754CA91F (SwiftUICore)

import OpenAttributeGraphShims

@available(OpenSwiftUI_v1_0, *)
extension Gesture {
    /// Combines a gesture with another gesture to create a new gesture that
    /// recognizes both gestures at the same time.
    ///
    /// - Parameter other: A gesture that you want to combine with your gesture
    ///   to create a new, combined gesture.
    ///
    /// - Returns: A gesture with two simultaneous gestures.
    @inlinable
    public func simultaneously<Other>(with other: Other) -> SimultaneousGesture<Self, Other> where Other: Gesture {
        return SimultaneousGesture(self, other)
    }
}

/// A gesture containing two gestures that can happen at the same time with
/// neither of them preceding the other.
///
/// A simultaneous gesture is a container-event handler that evaluates its two
/// child gestures at the same time. Its value is a struct with two optional
/// values, each representing the phases of one of the two gestures.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct SimultaneousGesture<First, Second>: PrimitiveGesture, Gesture where First: Gesture, Second: Gesture {
    /// The value of a simultaneous gesture that indicates which of its two
    /// gestures receives events.
    @frozen
    public struct Value {
        /// The value of the first gesture.
        public var first: First.Value?

        /// The value of the second gesture.
        public var second: Second.Value?
    }

    /// The first of two gestures that can happen simultaneously.
    public var first: First

    /// The second of two gestures that can happen simultaneously.
    public var second: Second

    /// Creates a gesture with two gestures that can receive updates or succeed
    /// independently of each other.
    ///
    /// - Parameters:
    ///   - first: The first of two gestures that can happen simultaneously.
    ///   - second: The second of two gestures that can happen simultaneously.
    @inlinable
    public init(_ first: First, _ second: Second) {
        (self.first, self.second) = (first, second)
    }

    nonisolated public static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Value> {
        let outputs1 = First.makeDebuggableGesture(
            gesture: gesture[offset: { .of(&$0.first) }],
            inputs: inputs
        )
        let outputs2 = Second.makeDebuggableGesture(
            gesture: gesture[offset: { .of(&$0.second) }],
            inputs: inputs
        )
        let phase = Attribute(SimultaneousPhase<First, Second>(
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
                outputs[anyKey: key] = Attribute(SimultaneousPreference<First, Second, K>(
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
extension SimultaneousGesture.Value: Sendable where First.Value: Sendable, Second.Value: Sendable {}

@available(*, unavailable)
extension SimultaneousGesture: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension SimultaneousGesture: PrimitiveDebuggableGesture {}

@available(OpenSwiftUI_v1_0, *)
extension SimultaneousGesture.Value: Equatable where First.Value: Equatable, Second.Value: Equatable {}

extension SimultaneousGesture.Value: Hashable where First.Value: Hashable, Second.Value: Hashable {}

private struct SimultaneousPhase<First, Second>: Rule where First: Gesture, Second: Gesture {
    @Attribute var phase1: GesturePhase<First.Value>
    @Attribute var phase2: GesturePhase<Second.Value>

    typealias Value = GesturePhase<SimultaneousGesture<First, Second>.Value>

    var value: Value {
        switch (phase1, phase2) {
        case (.active, _), (_, .active): .active(.init(first: phase1.unwrapped, second: phase2.unwrapped))
        case (.possible, _), (_, .possible): .possible(nil)
        case let (.ended(first), .ended(second)): .ended(.init(first: first, second: second))
        case let (.ended(first), .failed): .ended(.init(first: first, second: nil))
        case let (.failed, .ended(second)): .ended(.init(first: nil, second: second))
        case (.failed, .failed): .failed
        }
    }
}

private struct SimultaneousPreference<First, Second, Key>: Rule where First: Gesture, Second: Gesture, Key: PreferenceKey {
    @OptionalAttribute var value1: Key.Value?
    @OptionalAttribute var value2: Key.Value?
    @Attribute var phase1: GesturePhase<First.Value>
    @Attribute var phase2: GesturePhase<Second.Value>

    typealias Value = Key.Value

    var value: Value {
        switch (phase1, phase2) {
        case (.ended, .failed): value1 ?? Key.defaultValue
        case (.failed, .ended): value2 ?? Key.defaultValue
        case (.failed, .failed): Key.defaultValue
        default: mergedValue() ?? Key.defaultValue
        }
    }

    func mergedValue() -> Value? {
        var result: Value? = nil
        if !phase1.isFailed {
            result = value1
        }
        if !phase2.isFailed {
            if var value = result, let value2 {
                Key.reduce(value: &value) { value2 }
            } else {
                result = value2
            }
        }
        return result
    }
}
