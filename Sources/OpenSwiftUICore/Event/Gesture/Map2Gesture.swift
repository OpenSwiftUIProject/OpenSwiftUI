//
//  Map2Gesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: BE6C3883808EC258A2B6649DC967D317 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - Gesture + combining

extension Gesture {
    package func combined<G, T>(
        with other: G,
        body: @escaping (GesturePhase<Value>, GesturePhase<G.Value>) -> GesturePhase<T>
    ) -> some Gesture<T> where G: Gesture {
        modifier(Map2Gesture(content: other, body: body))
    }

    package func zip<G>(
        with other: G
    ) -> some Gesture<(Value, G.Value)> where G: Gesture {
        combined(with: other) { phase, otherPhase in
            phase.and(otherPhase)
        }
    }

    package func gated(
        by other: some Gesture
    ) -> some Gesture<Value> {
        combined(with: other) { phase, otherPhase in
            guard !otherPhase.isFailed else {
                return .failed
            }
            return phase
        }
    }

    package func enabled(
        by other: some Gesture
    ) -> some Gesture<Value> {
        combined(with: other) { phase, otherPhase in
            switch otherPhase {
            case .possible:
                return .possible(phase.unwrapped)
            case .active, .ended:
                return phase
            case .failed:
                return .failed
            }
        }
    }

    package func ended(
        by other: some Gesture,
        advanceImmediately: Bool = false
    ) -> some Gesture<Value> {
        combined(with: other) { phase, otherPhase in
            switch otherPhase {
            case .possible:
                if advanceImmediately || !(CoreTesting.isRunning || GestureContainerFeature.isEnabled) {
                    switch phase {
                    case let .ended(value):
                        return .active(value)
                    case .possible, .active, .failed:
                        return phase
                    }
                } else {
                    return phase.paused()
                }
            case .active, .ended:
                return phase
            case .failed:
                return .failed
            }
        }
    }
}

// MARK: - GesturePhase + combining

@_spi(ForSwiftUIOnly)
extension GesturePhase {
    @_spi(ForSwiftUIOnly)
    package func and<Other, Result>(
        _ phase: GesturePhase<Other>,
        value transform: (Wrapped, Other) -> Result
    ) -> GesturePhase<Result> {
        switch (self, phase) {
        case (.failed, _), (_, .failed):
            return .failed
        case (.possible, _), (_, .possible):
            return .possible(nil)
        case let (.ended(value), .ended(otherValue)):
            return .ended(transform(value, otherValue))
        case let (.active(value), .active(otherValue)),
             let (.active(value), .ended(otherValue)),
             let (.ended(value), .active(otherValue)):
            return .active(transform(value, otherValue))
        }
    }

    @_spi(ForSwiftUIOnly)
    package func and<Other>(
        _ phase: GesturePhase<Other>
    ) -> GesturePhase<(Wrapped, Other)> {
        and(phase) { ($0, $1) }
    }

    @_spi(ForSwiftUIOnly)
    package func and<Other>(
        _ phase: GesturePhase<Other>
    ) -> GesturePhase<Void> {
        and(phase) { _, _ in }
    }
}

// MARK: - Map2Gesture

struct Map2Gesture<InputValue, Content, OutputValue>: GestureModifier where Content: Gesture {
    var content: Content

    var body: (GesturePhase<InputValue>, GesturePhase<Content.Value>) -> GesturePhase<OutputValue>

    nonisolated static func _makeGesture(
        modifier: _GraphValue<Map2Gesture<InputValue, Content, OutputValue>>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<InputValue>
    ) -> _GestureOutputs<OutputValue> {
        let outputs1 = body(inputs)
        let outputs2 = Content.makeDebuggableGesture(
            gesture: modifier[offset: { .of(&$0.content) }],
            inputs: inputs
        )
        let phase = Attribute(Map2Phase(
            body: modifier[offset: { .of(&$0.body) }].value,
            phase1: outputs1.phase,
            phase2: outputs2.phase,
            resetSeed: inputs.resetSeed,
            lastResetSeed: .zero
        ))
        var outputs = _GestureOutputs(phase: phase)
        outputs.wrapDebugOutputs(
            Self.self,
            kind: .modifier,
            inputs: inputs,
            combiningOutputs: (outputs1, outputs2)
        )

        var firstOutputs = _ViewOutputs()
        firstOutputs.preferences = outputs1.preferences
        var secondOutputs = _ViewOutputs()
        secondOutputs.preferences = outputs2.preferences
        var visitor = PairwisePreferenceCombinerVisitor(outputs: (firstOutputs, secondOutputs))
        for key in inputs.preferences.keys {
            key.visitKey(&visitor)
        }
        outputs.preferences = visitor.result.preferences
        return outputs
    }

    typealias BodyValue = InputValue

    typealias Value = OutputValue
}

extension Map2Gesture: PrimitiveDebuggableGesture {}

// MARK: - Map2Phase

private struct Map2Phase<InputValue, ContentValue, OutputValue>: ResettableGestureRule, CustomStringConvertible {
    @Attribute var body: (GesturePhase<InputValue>, GesturePhase<ContentValue>) -> GesturePhase<OutputValue>
    @Attribute var phase1: GesturePhase<InputValue>
    @Attribute var phase2: GesturePhase<ContentValue>
    @Attribute var resetSeed: UInt32
    var lastResetSeed: UInt32

    typealias PhaseValue = OutputValue
    typealias Value = GesturePhase<OutputValue>

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        value = body(phase1, phase2)
    }

    var description: String {
        "Map2 → \(OutputValue.self)"
    }
}
