//
//  ExclusiveGestureTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag), .tags(.aigc))
struct ExclusiveGestureTests {
    @Test
    func failedFirstKeepsSecondWaitingBetweenTaps() {
        withPhases { first, second, phase in
            first.value = .failed
            #expect(phase.value == .possible(nil))
            second.value = .possible(2)
            #expect(phase.value == .possible(.second(2)))
            second.value = .possible(nil)
            #expect(phase.value == .possible(nil))
            second.value = .ended(2)
            #expect(phase.value == .ended(.second(2)))
        }
    }

    @Test
    func firstKeepsPrecedenceAndBothFailedTerminate() {
        withPhases { first, second, phase in
            first.value = .active(1)
            second.value = .active(2)
            #expect(phase.value == .active(.first(1)))
            first.value = .ended(1)
            #expect(phase.value == .ended(.first(1)))
            first.value = .failed
            second.value = .failed
            #expect(phase.value == .failed)
        }
    }

    private func withPhases(_ body: (Attribute<GesturePhase<Int>>, Attribute<GesturePhase<Int>>,
                                    Attribute<GesturePhase<ExclusiveGesture<PhaseGesture, PhaseGesture>.Value>>) -> Void) {
        let graph = ViewGraph(rootViewType: EmptyView.self)
        graph.rootSubgraph.apply {
            let first = Attribute(value: GesturePhase<Int>.possible(nil))
            let second = Attribute(value: GesturePhase<Int>.possible(nil))
            let inputs = _GestureInputs(
                _ViewInputs(withoutGeometry: graph.graphInputs), viewSubgraph: graph.rootSubgraph,
                events: Attribute(value: [:]), time: Attribute(value: Time.zero),
                resetSeed: Attribute(value: UInt32.zero), inheritedPhase: Attribute(value: .failed),
                gesturePreferenceKeys: Attribute(value: PreferenceKeys())
            )
            let gesture = ExclusiveGesture(PhaseGesture(phase: first), PhaseGesture(phase: second))
            let outputs = type(of: gesture)._makeGesture(gesture: _GraphValue(Attribute(value: gesture)), inputs: inputs)
            body(first, second, outputs.phase)
        }
    }
}

private struct PhaseGesture: PrimitiveGesture {
    var phase: Attribute<GesturePhase<Int>>

    static func _makeGesture(gesture: _GraphValue<Self>, inputs: _GestureInputs) -> _GestureOutputs<Int> {
        _GestureOutputs(phase: gesture.value.value.phase)
    }

    typealias Value = Int
    typealias Body = Never
}
