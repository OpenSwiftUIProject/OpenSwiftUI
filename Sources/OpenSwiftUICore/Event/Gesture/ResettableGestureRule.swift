//
//  ResettableGestureRule.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import OpenGraphShims

// MARK: - ResettableGestureRule [6.5.4]

package protocol ResettableGestureRule: StatefulRule {
    associatedtype PhaseValue = Void
    var phaseValue: GesturePhase<PhaseValue> { get }
    var resetSeed: UInt32 { get }
    var lastResetSeed: UInt32 { get set }
    mutating func resetPhase()
}

extension ResettableGestureRule {
    package mutating func resetPhase() {}

    package mutating func resetIfNeeded() -> Bool {
        defer { lastResetSeed = resetSeed }
        guard lastResetSeed == resetSeed else {
            resetPhase()
            return true
        }
        guard hasValue else {
            return true
        }
        return !phaseValue.isTerminal
    }
}

extension ResettableGestureRule where Value == GesturePhase<PhaseValue> {
    package var phaseValue: GesturePhase<PhaseValue> { value }
}

extension ResettableGestureRule where PhaseValue == Value.PhaseValue, Value: DebuggableGesturePhase {
    package var phaseValue: GesturePhase<PhaseValue> { value.phase }
}
