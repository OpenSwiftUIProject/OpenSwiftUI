//
//  DefaultLayoutViewResponderTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct DefaultLayoutViewResponderTests {
    @Test
    func childRepeatGestureTimesOutWhileViewTimeIsFixed() {
        let graph = ViewGraph(rootViewType: EmptyView.self)
        graph.rootSubgraph.apply {
            let layout = DefaultLayoutViewResponder(inputs: _ViewInputs(withoutGeometry: graph.graphInputs))
            let child = RepeatingResponder()
            layout.children = [child]
            let event = MouseEvent(
                timestamp: .zero,
                binding: EventBinding(responder: child),
                button: .primary,
                phase: .began,
                location: .zero,
                globalLocation: .zero,
                modifiers: []
            )
            Update.ensure {
                defer { graph.resetEvents() }
                let events = [EventID(type: MouseEvent.self, serial: 0): event]
                #expect(graph.sendEvents(events, rootNode: layout, at: .zero).isPossible)
                #expect(graph.sendEvents([:], rootNode: layout, at: Time(seconds: 0.2)).isPossible)
                #expect(graph.sendEvents([:], rootNode: layout, at: Time(seconds: 1)).isFailed)
                #expect(graph.data.time == .zero)
            }
        }
    }
}

private final class RepeatingResponder: ViewResponder {
    override func makeGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
        let repeatGesture = Attribute(value: RepeatGesture<Void>(count: 2, maximumDelay: 0.35))
        return RepeatGesture._makeGesture(modifier: _GraphValue(repeatGesture), inputs: inputs) { inputs in
            _GestureOutputs(phase: Attribute(FirstTap(resetSeed: inputs.resetSeed)))
        }
    }

    private struct FirstTap: Rule {
        @Attribute var resetSeed: UInt32

        var value: GesturePhase<Void> {
            resetSeed == 0 ? .ended(()) : .possible(nil)
        }
    }
}
