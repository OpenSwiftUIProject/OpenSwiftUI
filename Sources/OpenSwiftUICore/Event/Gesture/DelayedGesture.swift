//
//  DelayedGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 6BD2EA000179DFF5C40EA49FDDB323CC (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - Gesture + delayed

extension Gesture {
    package func delayed(
        by duration: Double,
        filter: @escaping (Value) -> Bool = { _ in true }
    ) -> ModifierGesture<DelayedGesture<Self.Value>, Self> {
        modifier(DelayedGesture(duration: duration, filter: filter))
    }
}

// MARK: - DelayedGesture

package struct DelayedGesture<BodyValue>: GestureModifier {
    package var duration: Double

    package var filter: (BodyValue) -> Bool

    package static func _makeGesture(
        modifier: _GraphValue<DelayedGesture<BodyValue>>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<BodyValue>
    ) -> _GestureOutputs<BodyValue> {
        let outputs = body(inputs)
        let phase = Attribute(DelayedPhase(
            modifier: modifier.value,
            childPhase: outputs.phase,
            time: inputs.viewInputs.time,
            resetSeed: inputs.resetSeed,
            useGestureGraph: inputs.options.contains(.gestureGraph),
            start: nil,
            lastResetSeed: .zero
        ))
        return outputs.withPhase(phase)
    }

    package typealias Value = BodyValue
}

// MARK: - DelayedPhase

private struct DelayedPhase<BodyValue>: ResettableGestureRule {
    @Attribute var modifier: DelayedGesture<BodyValue>
    @Attribute var childPhase: GesturePhase<BodyValue>
    @Attribute var time: Time
    @Attribute var resetSeed: UInt32
    var useGestureGraph: Bool
    var start: Time?
    var lastResetSeed: UInt32

    typealias PhaseValue = BodyValue
    typealias Value = GesturePhase<BodyValue>

    mutating func resetPhase() {
        start = nil
    }

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        let delayedModifier = modifier
        guard delayedModifier.duration > .zero, !CoreTesting.isRunning else {
            value = childPhase
            return
        }
        let currentPhase = childPhase
        let delayedValue: BodyValue
        switch currentPhase {
        case let .possible(value?):
            delayedValue = value
        case let .active(value):
            delayedValue = value
        case .possible(nil), .ended, .failed:
            value = currentPhase
            return
        }
        guard delayedModifier.filter(delayedValue) else {
            value = currentPhase
            return
        }
        let currentTime = time
        let startTime = start ?? currentTime
        self.start = startTime
        guard delayedModifier.duration > currentTime - startTime else {
            value = currentPhase
            return
        }

        let deadline = startTime + delayedModifier.duration
        if useGestureGraph {
            let gestureGraph = GestureGraph.current
            gestureGraph.nextUpdateTime = min(gestureGraph.nextUpdateTime, deadline)
        } else {
            ViewGraph.current.nextUpdate.gestures.at(deadline)
        }
        value = .possible(delayedValue)
    }
}
