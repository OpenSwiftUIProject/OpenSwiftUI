//
//  LayoutGestureTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct LayoutGestureTests {
    @Test
    func emptyLayoutFailsWithoutCreatingChildren() {
        withFixture { fixture in
            #expect(fixture.outputs.phase.value.isFailed)
        }
    }

    @Test
    func rebindingDeliversAnUnboundEventToThePreviousChild() {
        withFixture { fixture in
            let first = TestResponder("first")
            let second = TestResponder("second")
            let descendant = ViewResponder()
            descendant.parent = first
            fixture.setChildren([first, second])

            fixture.send(to: descendant)
            #expect(fixture.outputs.phase.value.isActive)
            #expect(first.events[fixture.eventID]?.binding?.responder === descendant)
            #expect(second.makeCount == 0)

            fixture.send(to: second)
            #expect(fixture.outputs.phase.value.isActive)
            #expect(first.events.count == 1)
            #expect(first.events[fixture.eventID]?.binding == nil)
            #expect(second.events[fixture.eventID]?.binding?.responder === second)
            #expect(first.makeCount == 1)
            #expect(second.makeCount == 1)
        }
    }

    @Test
    func reorderingPreservesChildGesturesAndPreferenceOrder() {
        withFixture { fixture in
            let first = TestResponder("first")
            let second = TestResponder("second")
            fixture.setChildren([first, second])
            fixture.send(to: [first, second])
            #expect(fixture.outputs.phase.value.isActive)
            #expect(fixture.outputs[TestPreference.self]?.value == ["first", "second"])

            fixture.setChildren([second, first])
            #expect(fixture.outputs.phase.value.isActive)
            #expect(fixture.outputs[TestPreference.self]?.value == ["second", "first"])
            #expect(first.makeCount == 1)
            #expect(second.makeCount == 1)
            #expect(first.resetCount == 0)
            #expect(second.resetCount == 0)
        }
    }

    @Test
    func removingChildrenResetsOnlyParticipatingGestures() {
        withFixture { fixture in
            let first = TestResponder("first")
            let unused = TestResponder("unused")
            let removed = TestResponder("removed")
            fixture.setChildren([first, unused, removed])
            fixture.send(to: [first, removed])
            #expect(fixture.outputs.phase.value.isActive)

            fixture.setChildren([first])
            let unusedResets = unused.resetCount
            let removedResets = removed.resetCount
            #expect(fixture.outputs.phase.value.isActive)
            #expect(fixture.outputs[TestPreference.self]?.value == ["first"])
            #expect(first.makeCount == 1)
            #expect(first.resetCount == 0)
            #expect(unused.resetCount - unusedResets == 0)
            #expect(removed.resetCount - removedResets == 1)
        }
    }

    @Test
    func emptyEventsClearChildInputWithoutCallingTheBindingHook() {
        withFixture { fixture in
            let child = TestResponder("child")
            fixture.setChildren([child])
            var calls = 0
            fixture.gesture.value.onBindings = { _, _ in calls += 1 }
            fixture.send(to: child)
            #expect(fixture.outputs.phase.value.isActive)
            #expect(calls == 1)

            fixture.send(to: [])
            #expect(fixture.outputs.phase.value.isActive)
            #expect(child.events.isEmpty)
            #expect(child.makeCount == 1)
            #expect(calls == 1)
        }
    }

    @Test
    func proxyRebindingAdvancesThePreviousChildSeedWithoutRecreatingIt() {
        withFixture { fixture in
            let first = TestResponder("first")
            let second = TestResponder("second")
            fixture.setChildren([first, second])
            _ = fixture.host.eventBindingManager.rebindEvent(fixture.eventID, to: first)
            fixture.send(to: first)
            #expect(fixture.outputs.phase.value.isActive)

            let eventID = fixture.eventID
            fixture.gesture.value.onBindings = { events, proxy in
                #expect(proxy.count == 2)
                #expect(proxy[0].binds(EventBinding(responder: first)))
                #expect(!proxy[1].binds(EventBinding(responder: first)))
                #expect(proxy[1].containsGlobalLocation(CGPoint(x: 5, y: 5)))
                #expect(!proxy[1].containsGlobalLocation(CGPoint(x: 20, y: 20)))
                var event = events[eventID]!
                let change = proxy.bindChild(index: 1, event: event, id: eventID)
                #expect(change?.from?.responder === first)
                #expect(change?.to?.responder === second)
                #expect(proxy.bindChild(index: 1, event: event, id: eventID) == nil)
                event.binding = change?.to
                events[eventID] = event
            }
            fixture.send(to: first)
            #expect(fixture.outputs.phase.value.isActive)
            #expect(first.events[fixture.eventID]?.binding == nil)
            #expect(first.resetSeed == 1)
            #expect(first.makeCount == 1)
            #expect(first.resetCount == 0)
            #expect(second.events[fixture.eventID]?.binding?.responder === second)
            #expect(second.resetSeed == 0)
        }
    }

    @Test
    func terminalPhaseIsReturnedBeforeChildReset() {
        withFixture { fixture in
            let child = TestResponder("child")
            child.phase = .ended(())
            fixture.setChildren([child])
            fixture.send(to: child)

            #expect(fixture.outputs.phase.value.isEnded)
            #expect(child.resetCount == 1)

            child.phase = .active(())
            fixture.send(to: child)
            #expect(fixture.outputs.phase.value.isActive)
            #expect(child.makeCount == 2)
            #expect(child.resetSeed == 1)
        }
    }

    @Test
    func resetSeedWrapsAndRecreatesTheChild() {
        withFixture { fixture in
            let child = TestResponder("child")
            fixture.resetSeed.value = .max
            fixture.setChildren([child])
            fixture.send(to: child)
            #expect(fixture.outputs.phase.value.isActive)
            #expect(child.resetSeed == .max)

            fixture.resetSeed.value = 0
            #expect(fixture.outputs.phase.value.isActive)
            #expect(child.resetSeed == 1)
            #expect(child.makeCount == 2)
            #expect(child.resetCount == 1)
        }
    }

    @Test
    func preferencesUseTheFirstParticipatingValueWithoutReducingTheDefault() {
        withFixture { fixture in
            let first = TestResponder("first")
            let second = TestResponder("second")
            fixture.setChildren([first, second])
            #expect(fixture.outputs[TestPreference.self]?.value == ["default"])

            fixture.send(to: second)
            #expect(fixture.outputs[TestPreference.self]?.value == ["second"])
            #expect(first.makeCount == 0)

            fixture.resetSeed.value = 1
            fixture.events.value = [:]
            #expect(fixture.outputs[TestPreference.self]?.value == ["default"])
        }
    }

    @Test
    func debugOutputPreservesTerminalChildDataAfterReset() {
        withFixture(debugOutput: true) { fixture in
            let child = TestResponder("child")
            child.phase = .ended(())
            fixture.setChildren([child])
            fixture.send(to: child)
            #expect(fixture.outputs.phase.value.isEnded)
            #expect(child.resetCount == 1)

            let data = fixture.outputs.debugData!.value
            #expect(data.kind == .combiner)
            #expect(data.type == TestGesture.self)
            #expect(data.phase.isEnded)
            #expect(data.frame == CGRect(x: 13, y: 24, width: 30, height: 40))
            #expect(data.children.count == 1)
            #expect(data.children[0].phase.isEnded)
            #expect(data.children[0].properties[0].0 == "name")
            #expect(data.children[0].properties[0].1 == "child")
        }
    }

    @Test(arguments: [
        ({ @Sendable in [] }, "failed"),
        ({ @Sendable in [.failed, .failed] }, "failed"),
        ({ @Sendable in [.possible(nil), .failed] }, ""),
        ({ @Sendable in [.possible(()), .failed] }, "possible(some)"),
        ({ @Sendable in [.possible(()), .possible(())] }, "possible(some)"),
        ({ @Sendable in [.possible(()), .possible(nil)] }, ""),
        ({ @Sendable in [.possible(nil), .possible(())] }, ""),
        ({ @Sendable in [.active(()), .possible(nil)] }, "active"),
        ({ @Sendable in [.possible(nil), .active(())] }, "active"),
        ({ @Sendable in [.ended(()), .possible(nil)] }, "active"),
        ({ @Sendable in [.possible(nil), .ended(())] }, "active"),
        ({ @Sendable in [.ended(()), .failed] }, "ended"),
        ({ @Sendable in [.failed, .ended(())] }, "ended"),
        ({ @Sendable in [.ended(()), .ended(())] }, "ended"),
        ({ @Sendable in [.ended(()), .active(())] }, "active"),
    ] as [(@Sendable () -> [GesturePhase<Void>], String)])
    func mergesParticipatingPhases(makePhases: @Sendable () -> [GesturePhase<Void>], expected: String) {
        withFixture { fixture in
            let children = makePhases().enumerated().map { index, phase in
                let child = TestResponder(String(index))
                child.phase = phase
                return child
            }
            fixture.setChildren(children)
            fixture.send(to: children)
            #expect(fixture.outputs.phase.value.descriptionWithoutValue == expected)
        }
    }

    private func withFixture(debugOutput: Bool = false, _ body: (Fixture) -> Void) {
        let graph = ViewGraph(rootViewType: EmptyView.self)
        graph.rootSubgraph.apply {
            body(Fixture(graph: graph, debugOutput: debugOutput))
        }
    }
}

private final class Fixture {
    let host: TestHost
    let responder = MultiViewResponder()
    let events = Attribute(value: [EventID: any EventType]())
    let resetSeed = Attribute(value: UInt32.zero)
    let gesture: Attribute<TestGesture>
    let outputs: _GestureOutputs<Void>
    let eventID = EventID(type: TestEvent.self, serial: 0)
    private var timestamp = Time.zero

    init(graph: ViewGraph, debugOutput: Bool) {
        host = TestHost(viewGraph: graph)
        graph.delegate = host
        gesture = Attribute(value: TestGesture(responder: responder))
        var viewInputs = _ViewInputs(withoutGeometry: graph.graphInputs)
        if debugOutput {
            var transform = ViewTransform()
            transform.appendCoordinateSpace(name: "root")
            transform.appendTranslation(CGSize(width: -10, height: -20))
            viewInputs.transform = Attribute(value: transform)
            viewInputs.position = Attribute(value: CGPoint(x: 3, y: 4))
            viewInputs.size = Attribute(value: ViewSize.fixed(CGSize(width: 30, height: 40)))
        }
        var inputs = _GestureInputs(
            viewInputs,
            viewSubgraph: graph.rootSubgraph,
            events: events,
            time: Attribute(value: Time.zero),
            resetSeed: resetSeed,
            inheritedPhase: Attribute(value: .failed),
            gesturePreferenceKeys: Attribute(value: PreferenceKeys())
        )
        inputs.preferences.add(TestPreference.self)
        inputs.options.setValue(debugOutput, for: .includeDebugOutput)
        outputs = TestGesture._makeGesture(gesture: _GraphValue(gesture), inputs: inputs)
    }

    func setChildren(_ children: [ViewResponder]) {
        responder.children = children
        gesture.value.revision += 1
    }

    func send(to responder: ViewResponder) {
        send(to: [responder])
    }

    func send(to responders: [ViewResponder]) {
        timestamp += 1
        events.value = Dictionary(uniqueKeysWithValues: responders.enumerated().map { index, responder in
            let event: any EventType = TestEvent(
                phase: .active,
                timestamp: timestamp,
                binding: EventBinding(responder: responder)
            )
            return (EventID(type: TestEvent.self, serial: index), event)
        })
    }
}

private struct TestGesture: LayoutGesture {
    var responder: MultiViewResponder
    var revision = 0
    var onBindings: ((inout [EventID: any EventType], LayoutGestureChildProxy) -> Void)?

    func updateEventBindings(_ events: inout [EventID: any EventType], proxy: LayoutGestureChildProxy) {
        onBindings?(&events, proxy)
    }

    typealias Value = Void
    typealias Body = Never
}

private struct TestEvent: EventType {
    var phase: EventPhase
    var timestamp: Time
    var binding: EventBinding?
}

private enum TestPreference: PreferenceKey {
    static var defaultValue: [String] { ["default"] }

    static func reduce(value: inout [String], nextValue: () -> [String]) {
        value.append(contentsOf: nextValue())
    }
}

private final class TestResponder: ViewResponder {
    let name: String
    var phase: GesturePhase<Void> = .active(())
    var events: [EventID: any EventType] = [:]
    var resetSeed: UInt32 = 0
    var makeCount = 0
    var resetCount = 0

    init(_ name: String) {
        self.name = name
        super.init()
    }

    override func makeGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
        makeCount += 1
        var outputs = _GestureOutputs(phase: Attribute(Phase(
            responder: self,
            events: inputs.events,
            resetSeed: inputs.resetSeed
        )))
        outputs[TestPreference.self] = Attribute(value: [name])
        if inputs.options.contains(.includeDebugOutput) {
            outputs.debugData = Attribute(value: GestureDebug.Data(
                kind: .primitive,
                type: TestGesture.self,
                children: .init(),
                phase: phase,
                attribute: outputs.phase.identifier,
                resetSeed: 0,
                frame: .zero,
                properties: .init(("name", name))
            ))
        }
        return outputs
    }

    override func containsGlobalPoints(
        _ points: [PlatformPoint],
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ContainsPointsResult {
        #expect(cacheKey == nil)
        #expect(options.isEmpty)
        var mask: BitVector64 = []
        for (index, point) in points.enumerated() {
            mask[index] = CGRect(x: 0, y: 0, width: 10, height: 10).contains(point)
        }
        return ContainsPointsResult(mask: mask, priority: 0, children: [])
    }

    override func resetGesture() {
        resetCount += 1
    }

    private struct Phase: Rule {
        let responder: TestResponder
        @Attribute var events: [EventID: any EventType]
        @Attribute var resetSeed: UInt32

        var value: GesturePhase<Void> {
            responder.events = events
            responder.resetSeed = resetSeed
            return responder.phase
        }
    }
}

private final class TestHost: ViewRendererHost, EventGraphHost {
    let viewGraph: ViewGraph
    let eventBindingManager = EventBindingManager()
    var propertiesNeedingUpdate: ViewRendererHostProperties = []
    var renderingPhase: ViewRenderingPhase = .none
    var externalUpdateCount = 0
    var currentTimestamp = Time.zero

    init(viewGraph: ViewGraph) {
        self.viewGraph = viewGraph
    }

    func `as`<T>(_ type: T.Type) -> T? { self as? T }
    func updateViewGraph<T>(body: (ViewGraph) -> T) -> T { body(viewGraph) }
    func requestUpdate(after: Double) {}
    func updateRootView() {}
    func updateEnvironment() {}
    func updateSize() {}
    func updateSafeArea() {}
    func updateContainerSize() {}

    var responderNode: ResponderNode? { nil }
    var focusedResponder: ResponderNode? { nil }
    var nextGestureUpdateTime: Time { .infinity }
    func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {}
    func sendEvents(
        _ events: [EventID: any EventType],
        rootNode: ResponderNode,
        at time: Time
    ) -> GesturePhase<Void> { .failed }
    func resetEvents() {}
    func gestureCategory() -> GestureCategory? { nil }
}
