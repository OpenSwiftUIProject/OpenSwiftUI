//
//  RepeatGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: BECD07FC80B4CA0BF429B041392E806A (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - RepeatGesture

extension Gesture {
    package func repeatCount(
        _ count: Int,
        maximumDelay: Double = 0.35
    ) -> ModifierGesture<RepeatGesture<Value>, Self> {
        modifier(RepeatGesture(count: count, maximumDelay: maximumDelay))
    }
}

package struct RepeatGesture<Value>: GestureModifier {
    package var count: Int
    package var maximumDelay: Double

    package init(count: Int, maximumDelay: Double = 0.35) {
        self.count = count
        self.maximumDelay = maximumDelay
    }

    package static func _makeGesture(
        modifier: _GraphValue<RepeatGesture<Value>>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<Value>
    ) -> _GestureOutputs<Value> {
        let resetDelta = Attribute(value: UInt32.zero)
        let resetSeed = Attribute(RepeatResetSeed(
            resetSeed: inputs.resetSeed,
            delta: resetDelta
        ))
        var childInputs = inputs
        childInputs.resetSeed = resetSeed
        let outputs = body(childInputs)
        let phase = Attribute(RepeatPhase(
            modifier: modifier.value,
            phase: outputs.phase,
            time: inputs.viewInputs.time,
            resetSeed: inputs.resetSeed,
            resetDelta: resetDelta,
            useGestureGraph: inputs.options.contains(.gestureGraph),
            deadline: nil,
            index: .zero,
            lastResetSeed: .zero
        ))
        return outputs.withPhase(phase)
    }
}

private struct RepeatPhase<V>: ResettableGestureRule {
    @Attribute var modifier: RepeatGesture<V>
    @Attribute var phase: GesturePhase<V>
    @Attribute var time: Time
    @Attribute var resetSeed: UInt32
    @Attribute var resetDelta: UInt32
    var useGestureGraph: Bool
    var deadline: Time?
    var index: UInt32
    var lastResetSeed: UInt32

    typealias PhaseValue = V
    typealias Value = GesturePhase<V>

    mutating func resetPhase() {
        deadline = nil
        index = .zero
    }

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        if let deadline, deadline < time {
            value = .failed
            return
        }
        switch phase {
        case .possible:
            value = phase
        case let .active(value):
            deadline = nil
            let repeatLimit = modifier.count - 1
            if repeatLimit > Int(index) {
                self.value = .possible(value)
            } else {
                self.value = phase
            }
        case let .ended(wrapped):
            index &+= 1
            if modifier.count > Int(index) {
                deadline = time + modifier.maximumDelay
                value = .possible(wrapped)
                GraphHost.currentHost.continueTransaction { [_resetDelta, index] in
                    _resetDelta.value = index
                }
            } else {
                deadline = nil
                value = phase
            }
        case .failed:
            value = phase
        }
        guard let deadline else {
            return
        }
        if useGestureGraph {
            let gestureGraph = GestureGraph.current
            gestureGraph.nextUpdateTime = min(gestureGraph.nextUpdateTime, deadline)
        } else {
            ViewGraph.current.nextUpdate.gestures.at(deadline)
        }
    }
}

private struct RepeatResetSeed: Rule {
    @Attribute var resetSeed: UInt32
    @Attribute var delta: UInt32

    var value: UInt32 {
        resetSeed &+ delta
    }
}
