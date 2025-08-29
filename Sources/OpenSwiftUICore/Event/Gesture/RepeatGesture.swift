//
//  RepeatGesture.swift
//  OpenSwiftUICore
//
//  Status: Unimplmented
//  ID: BECD07FC80B4CA0BF429B041392E806A (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - RepeatGesture [6.5.4]

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
        _openSwiftUIUnimplementedFailure()
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

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        _openSwiftUIUnimplementedFailure()
    }
}
