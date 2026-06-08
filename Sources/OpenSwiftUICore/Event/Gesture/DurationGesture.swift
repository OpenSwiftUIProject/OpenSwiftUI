//
//  DurationGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C4CC4B4F23572B057F5F0CA55A7B1301 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - Gesture + duration

extension Gesture {
    package func duration(
        minimum: Double = 0,
        maximum: Double = .infinity
    ) -> ModifierGesture<DurationGesture<Value>, Self> {
        modifier(DurationGesture(minimumDuration: minimum, maximumDuration: maximum))
    }
}

// MARK: - DurationGesture

package struct DurationGesture<BodyValue>: GestureModifier {
    package var minimumDuration: Double

    package var maximumDuration: Double

    package var trackFromEventStart: Bool

    package init(
        minimumDuration: Double = 0,
        maximumDuration: Double = .infinity,
        trackFromEventStart: Bool = false
    ) {
        self.minimumDuration = minimumDuration
        self.maximumDuration = maximumDuration
        self.trackFromEventStart = trackFromEventStart
    }

    package static func _makeGesture(
        modifier: _GraphValue<DurationGesture<BodyValue>>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<BodyValue>
    ) -> _GestureOutputs<Double> {
        let outputs = body(inputs)
        let phase = Attribute(DurationPhase(
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

    package typealias Value = Double
}

// MARK: - DurationPhase

private struct DurationPhase<BodyValue>: ResettableGestureRule {
    @Attribute var modifier: DurationGesture<BodyValue>
    @Attribute var childPhase: GesturePhase<BodyValue>
    @Attribute var time: Time
    @Attribute var resetSeed: UInt32
    var useGestureGraph: Bool
    var start: Time?
    var lastResetSeed: UInt32

    typealias PhaseValue = Double
    typealias Value = GesturePhase<Double>

    mutating func resetPhase() {
        start = nil
    }

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        let elapsed: Double?
        if let start {
            elapsed = time - start
        } else {
            let childPhase = childPhase
            if childPhase.isActive || modifier.trackFromEventStart {
                start = time
                elapsed = .zero
            } else {
                elapsed = nil
            }
        }
        let nextPhase: GesturePhase<Double>
        defer { value = nextPhase }
        switch childPhase {
        case .possible:
            nextPhase = .possible(elapsed)
        case .active:
            let elapsed = elapsed!
            if modifier.minimumDuration > elapsed {
                nextPhase = .possible(elapsed)
            } else if modifier.maximumDuration > elapsed {
                nextPhase = .active(elapsed)
            } else {
                nextPhase = .failed
                return
            }
        case .ended:
            let elapsed = elapsed!
            if modifier.minimumDuration > elapsed || modifier.maximumDuration <= elapsed {
                nextPhase = .failed
                return
            } else {
                nextPhase = .ended(elapsed)
            }
            return
        case .failed:
            nextPhase = .failed
            return
        }
        if let start {
            let deadline: Time
            if let elapsed, modifier.minimumDuration > elapsed {
                deadline = start + modifier.minimumDuration
            } else {
                deadline = start + modifier.maximumDuration
            }
            if useGestureGraph {
                let gestureGraph = GestureGraph.current
                gestureGraph.nextUpdateTime = min(gestureGraph.nextUpdateTime, deadline)
            } else {
                ViewGraph.current.nextUpdate.gestures.at(deadline)
            }
        }
    }
}
