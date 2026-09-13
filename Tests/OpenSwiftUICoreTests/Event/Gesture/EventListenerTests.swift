//
//  EventListenerTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct EventListenerTests {
    @Test
    func emptyAndUnboundEventsRemainPossible() {
        withFixture(TappableEvent.self) { fixture in
            #expect(fixture.phase == .possible(nil))
            fixture.send(.began, bound: false)
            #expect(fixture.phase == .possible(nil))
        }
    }

    @Test(arguments: [false, true])
    func beganAndActiveEventsStartRecognition(active: Bool) {
        withFixture(TappableEvent.self, allowsIncomplete: true) { fixture in
            fixture.send(active ? .active : .began)
            #expect(fixture.phase.isActive)
            #expect(fixture.phase.unwrapped?.phase == (active ? .active : .began))
        }
    }

    @Test
    func durationStartsOnBeganBeforeImmediateEnd() {
        withFixture(TappableEvent.self) { fixture in
            let outputs = DurationGesture<TappableEvent>._makeGesture(
                modifier: _GraphValue(Attribute(value: DurationGesture<TappableEvent>(maximumDuration: 1))),
                inputs: fixture.inputs,
                body: { _ in fixture.outputs }
            )
            fixture.send(.began, time: 10)
            let phase = outputs.phase.value
            #expect(phase == .active(0))
            guard phase.isActive else { return }

            fixture.send(.ended, time: 10.125)
            #expect(outputs.phase.value == .ended(0.125))
        }
    }

    @Test(arguments: [false, true])
    func midstreamStartRequiresPermission(allowsIncomplete: Bool) {
        withFixture(TappableEvent.self, allowsIncomplete: allowsIncomplete) { fixture in
            fixture.send(.active)
            #expect(fixture.phase.isActive == allowsIncomplete)
            #expect(fixture.phase.isFailed == !allowsIncomplete)
        }
    }

    @Test
    func terminalPhasePersistsUntilReset() {
        withFixture(TappableEvent.self, allowsIncomplete: true) { fixture in
            fixture.send(.active)
            #expect(fixture.phase.isActive)
            fixture.send(.ended, time: 2)
            #expect(fixture.phase.isEnded)

            fixture.send(.began, id: 1, time: 3)
            #expect(fixture.phase.isEnded)
            #expect(fixture.phase.unwrapped?.timestamp == Time(seconds: 2))

            fixture.resetSeed.value += 1
            #expect(fixture.phase.isActive)
            #expect(fixture.phase.unwrapped?.timestamp == Time(seconds: 3))
        }
    }

    @Test(arguments: [false, true])
    func matchingOtherEventUsesIgnorePolicy(ignoresOtherEvents: Bool) {
        withFixture(TappableEvent.self, ignoresOtherEvents: ignoresOtherEvents, allowsIncomplete: true) { fixture in
            fixture.send(.active)
            #expect(fixture.phase.isActive)
            fixture.send(.began, id: 1, time: 2)
            if ignoresOtherEvents {
                #expect(fixture.phase.isActive)
                #expect(fixture.phase.unwrapped?.timestamp == Time(seconds: 2))

                fixture.send(.active, bound: false, time: 3)
                #expect(fixture.phase.isFailed)
            } else {
                #expect(fixture.phase.isFailed)
            }
        }
    }

    @Test
    func ignoredMidstreamConflictStillSelectsAConvertibleEvent() {
        withFixture(TappableEvent.self, ignoresOtherEvents: true) { fixture in
            fixture.send(.began)
            #expect(fixture.phase.isActive)
            fixture.send(.active, id: 1, time: 2)
            #expect(fixture.phase.isActive)
            #expect(fixture.phase.unwrapped?.timestamp == Time(seconds: 2))
        }
    }

    @Test(arguments: [false, true])
    func unexpectedEventUsesIgnorePolicyOnlyWhileTracking(ignoresOtherEvents: Bool) {
        withFixture(TappableEvent.self, ignoresOtherEvents: ignoresOtherEvents, allowsIncomplete: true) { fixture in
            fixture.send(.active)
            let previous = fixture.phase
            fixture.events.value = [
                EventID(type: UnsupportedEvent.self, serial: 1): UnsupportedEvent(
                    phase: .began,
                    timestamp: Time(seconds: 2),
                    binding: fixture.binding
                )
            ]
            if ignoresOtherEvents {
                #expect(fixture.phase == previous)
            } else {
                #expect(fixture.phase.isFailed)
            }
        }
    }

    @Test
    func unexpectedFirstEventFailsEvenWhenOtherEventsAreIgnored() {
        withFixture(TappableEvent.self, ignoresOtherEvents: true) { fixture in
            fixture.events.value = [
                EventID(type: UnsupportedEvent.self, serial: 1): UnsupportedEvent(
                    phase: .began,
                    timestamp: .zero,
                    binding: fixture.binding
                )
            ]
            #expect(fixture.phase.isFailed)
        }
    }

    @Test(arguments: [false, true])
    func multipleMatchingEventsUseIgnorePolicy(ignoresOtherEvents: Bool) {
        withFixture(TappableEvent.self, ignoresOtherEvents: ignoresOtherEvents) { fixture in
            fixture.events.value = Dictionary(uniqueKeysWithValues: (0..<2).map { serial in
                let event: any EventType = TestEvent(
                    phase: .began,
                    timestamp: .zero,
                    binding: fixture.binding
                )
                return (EventID(type: TestEvent.self, serial: serial), event)
            })
            #expect(fixture.phase.isActive == ignoresOtherEvents)
            #expect(fixture.phase.isFailed == !ignoresOtherEvents)
        }
    }

    @Test(arguments: [false, true])
    func losingTheTrackedBindingFails(ignoresOtherEvents: Bool) {
        withFixture(TappableEvent.self, ignoresOtherEvents: ignoresOtherEvents, allowsIncomplete: true) { fixture in
            fixture.send(.active)
            #expect(fixture.phase.isActive)
            fixture.send(.active, bound: false, time: 2)
            #expect(fixture.phase.isFailed)
        }
    }

    @Test
    func missingTrackedEventPreservesPreviousValue() {
        withFixture(TappableEvent.self, allowsIncomplete: true) { fixture in
            fixture.send(.active)
            let previous = fixture.phase
            fixture.events.value = [:]
            #expect(fixture.phase == previous)

            fixture.send(.active, id: 1, bound: false, time: 2)
            #expect(fixture.phase == previous)
        }
    }

    @Test
    func failedEventEndsRecognition() {
        withFixture(TappableEvent.self, allowsIncomplete: true) { fixture in
            fixture.send(.active)
            #expect(fixture.phase.isActive)
            fixture.send(.failed, time: 2)
            #expect(fixture.phase.isFailed)
            fixture.send(.active, time: 3)
            #expect(fixture.phase.isFailed)
        }
    }

    @Test(arguments: [false, true])
    func convertsLocationsBeforeProjectingTheEvent(preconverted: Bool) {
        withFixture(LocationEvent.self, preconverted: preconverted) { fixture in
            fixture.events.value = [
                EventID(type: SpatialInput.self, serial: 0): SpatialInput(
                    phase: .began,
                    timestamp: .zero,
                    binding: fixture.binding,
                    globalLocation: CGPoint(x: 31, y: 47),
                    location: CGPoint(x: 2, y: 3),
                    radius: 1
                )
            ]
            #expect(fixture.phase.isActive)
            #expect(fixture.phase.unwrapped?.location == (
                preconverted ? CGPoint(x: 2, y: 3) : CGPoint(x: 21, y: 27)
            ))
        }
    }

    @Test
    func usesTheSourceEventPhaseForTheProjectedValue() {
        withFixture(ChangedPhaseEvent.self) { fixture in
            fixture.send(.began)
            #expect(fixture.phase.isActive)
            #expect(fixture.phase.unwrapped?.phase == .ended)
        }
    }

    private func withFixture<E: EventType>(
        _ eventType: E.Type,
        ignoresOtherEvents: Bool = false,
        allowsIncomplete: Bool = false,
        preconverted: Bool = true,
        _ body: (Fixture<E>) -> Void
    ) {
        let graph = ViewGraph(rootViewType: EmptyView.self)
        graph.rootSubgraph.apply {
            body(Fixture(
                graph: graph,
                ignoresOtherEvents: ignoresOtherEvents,
                allowsIncomplete: allowsIncomplete,
                preconverted: preconverted
            ))
        }
    }
}

private final class Fixture<E: EventType> {
    let events = Attribute(value: [EventID: any EventType]())
    let resetSeed = Attribute(value: UInt32.zero)
    let time = Attribute(value: Time.zero)
    let binding = EventBinding(responder: ViewResponder())
    let inputs: _GestureInputs
    let outputs: _GestureOutputs<E>

    var phase: GesturePhase<E> { outputs.phase.value }

    init(graph: ViewGraph, ignoresOtherEvents: Bool, allowsIncomplete: Bool, preconverted: Bool) {
        var viewInputs = _ViewInputs(withoutGeometry: graph.graphInputs)
        viewInputs.position = Attribute(value: CGPoint(x: 10, y: 20))
        var transform = ViewTransform()
        transform.appendCoordinateSpace(name: "root")
        viewInputs.transform = Attribute(value: transform)
        var inputs = _GestureInputs(
            viewInputs,
            viewSubgraph: graph.rootSubgraph,
            events: events,
            time: time,
            resetSeed: resetSeed,
            inheritedPhase: Attribute(value: .failed),
            gesturePreferenceKeys: Attribute(value: PreferenceKeys())
        )
        inputs.options.setValue(preconverted, for: .preconvertedEventLocations)
        inputs.options.setValue(allowsIncomplete, for: .allowsIncompleteEventSequences)
        self.inputs = inputs
        outputs = EventListener<E>._makeGesture(
            gesture: _GraphValue(Attribute(value: EventListener<E>(ignoresOtherEvents: ignoresOtherEvents))),
            inputs: inputs
        )
    }

    func send(_ phase: EventPhase, id: Int = 0, bound: Bool = true, time seconds: Double = 1) {
        let timestamp = Time(seconds: seconds)
        time.value = timestamp
        events.value = [
            EventID(type: TestEvent.self, serial: id): TestEvent(
                phase: phase,
                timestamp: timestamp,
                binding: bound ? binding : nil
            )
        ]
    }
}

private struct TestEvent: TappableEventType {
    var phase: EventPhase
    var timestamp: Time
    var binding: EventBinding?
}

private struct UnsupportedEvent: EventType {
    var phase: EventPhase
    var timestamp: Time
    var binding: EventBinding?
}

private struct SpatialInput: SpatialEventType {
    var phase: EventPhase
    var timestamp: Time
    var binding: EventBinding?
    var globalLocation: CGPoint
    var location: CGPoint
    var radius: CGFloat
}

private struct LocationEvent: EventType {
    var phase: EventPhase
    var timestamp: Time
    var binding: EventBinding?
    var location: CGPoint

    init?(_ event: any EventType) {
        guard let event = event as? any SpatialEventType else { return nil }
        phase = event.phase
        timestamp = event.timestamp
        binding = event.binding
        location = event.location
    }
}

private struct ChangedPhaseEvent: EventType {
    var phase: EventPhase
    var timestamp: Time
    var binding: EventBinding?

    init?(_ event: any EventType) {
        phase = .ended
        timestamp = event.timestamp
        binding = event.binding
    }
}
