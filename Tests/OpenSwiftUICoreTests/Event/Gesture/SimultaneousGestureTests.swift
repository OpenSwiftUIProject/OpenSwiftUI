//
//  SimultaneousGestureTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct SimultaneousGestureTests {
    @Test(arguments: [(1, 2), (2, 1)])
    func usesLargerRequiredTapCount(first: Int, second: Int) {
        let gesture = TapGesture(count: first).simultaneously(with: TapGesture(count: second))
        #expect(requiredTapCount(of: gesture) == 2)
    }

    @Test
    func preservesRequiredTapCountWhenSecondGestureSuppliesNone() {
        let gesture = TapGesture(count: 2).simultaneously(with: EventListener<TappableEvent>())
        #expect(requiredTapCount(of: gesture) == 2)
    }

    private func requiredTapCount<G: Gesture>(of gesture: G) -> Int? {
        let graph = ViewGraph(rootViewType: EmptyView.self)
        return graph.rootSubgraph.apply {
            var inputs = _GestureInputs(
                _ViewInputs(withoutGeometry: graph.graphInputs),
                viewSubgraph: graph.rootSubgraph,
                events: Attribute(value: [:]),
                time: graph.graphInputs.time,
                resetSeed: Attribute(value: 0),
                inheritedPhase: Attribute(value: .failed),
                gesturePreferenceKeys: Attribute(value: PreferenceKeys())
            )
            inputs.preferences.requiresRequiredTapCount = true
            let outputs = G._makeGesture(gesture: _GraphValue(Attribute(value: gesture)), inputs: inputs)
            return outputs.preferences.requiredTapCount?.value
        }
    }
}
