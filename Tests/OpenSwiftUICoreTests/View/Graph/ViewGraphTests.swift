//
//  ViewGraphTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import OpenSwiftUI_SPI
import Testing

@Suite(.tags(.aigc))
struct ViewGraphTests {
    @Test(arguments: [
        (100, 60, CGSize(width: 100, height: 60)),
        (nil, 60, CGSize(width: 22, height: 60)),
        (100, nil, CGSize(width: 100, height: 18)),
        (nil, nil, CGSize(width: 22, height: 18)),
        (2, 3, CGSize(width: 12, height: 8)),
        (.nan, 60, CGSize(width: 12, height: 60)),
        (100, .nan, CGSize(width: 100, height: 8)),
        (.nan, .nan, CGSize(width: 12, height: 8)),
    ] as [(CGFloat?, CGFloat?, CGSize)])
    func sizeThatFitsPreservesProposalDimensions(width: CGFloat?, height: CGFloat?, expected: CGSize) {
        Update.perform {
            let insets = EdgeInsets(top: 3, leading: 5, bottom: 5, trailing: 7)
            let proposal = _ProposedSize(width: width, height: height)
            for layoutComputer: LayoutComputer? in [nil, .defaultValue] {
                let result = ViewGraph.sizeThatFits(proposal, layoutComputer: layoutComputer, insets: insets)
                #expect(result == expected)
            }
        }
    }

    @MainActor
    @Suite(.disabled(if: attributeGraphVendor == .oag))
    struct GraphTests {
        @Test
        func initializationRestoresCurrentSubgraph() {
            Update.perform {
                let parent = makeGraph()
                let current = Subgraph.current
                parent.globalSubgraph.apply {
                    let child = makeGraph()
                    #expect(Subgraph.current === parent.globalSubgraph)
                    #expect(child.graph.viewGraph() === child)
                }
                #expect(Subgraph.current === current)
            }
        }

        @Test
        func requestedOutputsRebuildGraphOnlyWhenChanged() {
            Update.perform {
                let graph = makeGraph()
                graph.append(feature: DisplayListFeature())
                graph.instantiate()
                let root = graph.rootSubgraph
                graph.requestedOutputs = []
                #expect(graph.isInstantiated)
                #expect(graph.rootSubgraph === root)
                #expect(graph.$rootDisplayList == nil)

                graph.requestedOutputs.insert(.displayList)
                #expect(!graph.isInstantiated)
                #expect(graph.rootSubgraph !== root)
                graph.instantiate()
                #expect(graph.$rootDisplayList != nil)
                #expect(graph.displayList().0.items.count == 1)
            }
        }

        @Test(arguments: [false, true])
        func alignmentUsesSafeAreaInsets(rightToLeft: Bool) {
            Update.perform {
                let graph = makeGraph(outputs: .layout)
                var environment = EnvironmentValues()
                environment.layoutDirection = rightToLeft ? .rightToLeft : .leftToRight
                graph.setEnvironment(environment)
                graph.setSafeAreaInsets([
                    .init(regions: .container, insets: .init(top: 3, leading: 5, bottom: 5, trailing: 7)),
                    .init(regions: .keyboard, insets: .init(top: 2, leading: 11, bottom: 4, trailing: 13)),
                ])
                let size = CGSize(width: 100, height: 60)
                #expect(graph.sizeThatFits(.unspecified) == CGSize(width: 46, height: 24))
                #expect(graph.explicitAlignment(of: HorizontalAlignment.center, at: size) == nil)
                #expect(graph.explicitAlignment(of: VerticalAlignment.center, at: size) == nil)
                #expect(graph.alignment(of: HorizontalAlignment.center, at: size) == (rightToLeft ? 52 : 48))
                #expect(graph.alignment(of: VerticalAlignment.center, at: size) == 28)

                graph.globalSubgraph.apply {
                    graph.$rootLayoutComputer = Attribute(value: LayoutComputer(AlignmentEngine()))
                }
                #expect(graph.explicitAlignment(of: HorizontalAlignment.center, at: size) == (rightToLeft ? 27 : 23))
                #expect(graph.explicitAlignment(of: VerticalAlignment.center, at: size) == 14)
                #expect(graph.alignment(of: HorizontalAlignment.center, at: size) == 7)
                #expect(graph.alignment(of: VerticalAlignment.center, at: size) == 9)
            }
        }

        @Test(arguments: [false, true])
        func preferenceOutletsFollowReuseAndTeardown(initiallyHidden: Bool) throws {
            try Update.perform {
                let parent = makeGraph()
                let (bridge, value, hostValues) = try makeBridge(in: parent)
                let child = makeGraph()
                child.preferenceBridge = bridge
                child.removedState = initiallyHidden ? .hiddenForReuse : []
                child.append(feature: PreferenceFeature())
                child.instantiate()
                #expect(value.value == (initiallyHidden ? 0 : 42))
                #expect(hostValues.value[HostValueKey.self].value == (initiallyHidden ? 0 : 9))

                child.removedState = []
                #expect(value.value == 42)
                #expect(hostValues.value[HostValueKey.self].value == 9)
                child.removedState = .hiddenForReuse
                #expect(value.value == 0)
                #expect(hostValues.value[HostValueKey.self].value == 0)
                child.removedState = []
                #expect(value.value == 42)
                #expect(hostValues.value[HostValueKey.self].value == 9)

                child.uninstantiate(immediately: true)
                #expect(value.value == 0)
                #expect(hostValues.value[HostValueKey.self].value == 0)
            }
        }

        @Test
        func replacingPreferenceBridgeDisconnectsOldOutputs() throws {
            try Update.perform {
                let firstParent = makeGraph()
                let secondParent = makeGraph()
                let (first, firstValue, _) = try makeBridge(in: firstParent)
                let (second, secondValue, _) = try makeBridge(in: secondParent)
                let child = makeGraph()
                child.preferenceBridge = first
                child.append(feature: PreferenceFeature())
                child.instantiate()
                #expect(firstValue.value == 42)

                child.preferenceBridge = second
                #expect(!child.isInstantiated)
                #expect(child.parentHost === secondParent)
                #expect(firstValue.value == 0)
                #expect(secondValue.value == 0)
                child.instantiate()
                #expect(secondValue.value == 42)
                first.invalidate()
                #expect(child.preferenceBridge === second)
                child.invalidatePreferenceBridge()
                #expect(secondValue.value == 0)
                #expect(child.preferenceBridge == nil)
            }
        }

        @Test
        func graphDeinitRemovesPreferenceOutletsAndChild() throws {
            try Update.perform {
                let parent = makeGraph()
                let (bridge, value, hostValues) = try makeBridge(in: parent)
                var child: ViewGraph? = makeGraph()
                weak let weakChild = child
                child?.preferenceBridge = bridge
                child?.append(feature: PreferenceFeature())
                child?.instantiate()
                #expect(value.value == 42)
                child = nil
                #expect(weakChild == nil)
                #expect(value.value == 0)
                #expect(hostValues.value[HostValueKey.self].value == 0)
                bridge.removedStateDidChange()
                bridge.invalidate()
            }
        }

        @Test
        func environmentWithoutBridgePreservesExistingBridge() {
            Update.perform {
                let parent = makeGraph()
                let bridge = parent.globalSubgraph.apply { PreferenceBridge() }
                let child = makeGraph()
                var environment = EnvironmentValues()
                environment.preferenceBridge = bridge
                child.updatePreferenceBridge(environment: environment) {
                    Issue.record("An idle graph must update the bridge immediately")
                }
                child.instantiate()
                let root = child.rootSubgraph
                child.updatePreferenceBridge(environment: environment) {
                    Issue.record("An unchanged bridge must not queue an update")
                }
                child.updatePreferenceBridge(environment: EnvironmentValues()) {
                    Issue.record("An absent bridge must not queue an update")
                }
                #expect(child.preferenceBridge === bridge)
                #expect(child.rootSubgraph === root)
                #expect(child.isInstantiated)
            }
        }

        @Test
        func bridgeChangesDuringEvaluationAreDeferred() {
            Update.perform {
                let parent = makeGraph()
                let bridge = parent.globalSubgraph.apply { PreferenceBridge() }
                let child = makeGraph()
                var environment = EnvironmentValues()
                environment.preferenceBridge = bridge
                var callbacks = 0
                let probe = child.globalSubgraph.apply {
                    Attribute(BridgeUpdate(graph: child, environment: environment) {
                        #expect(!GraphHost.isUpdating)
                        callbacks += 1
                        child.updatePreferenceBridge(environment: environment) {
                            Issue.record("The deferred update must run outside graph evaluation")
                        }
                    })
                }
                #expect(probe.value)
                #expect(child.preferenceBridge == nil)
                #expect(callbacks == 0)
                Update.dispatchActions()
                #expect(callbacks == 1)
                #expect(child.preferenceBridge === bridge)
                child.invalidate()
            }
        }

        @Test
        func reuseNotifiesFeaturesAndDelegate() {
            Update.perform {
                let graph = makeGraph()
                let delegate = Delegate(graph: graph)
                graph.delegate = delegate
                graph.append(feature: ReuseFeature())
                graph.removedState = .hiddenForReuse
                #expect(graph[ReuseFeature.self]?.pointee.states == [true])
                #expect(delegate.changes == 0)
                graph.removedState = []
                #expect(delegate.changes == 1)
                graph.instantiate()
                delegate.changes = 0
                graph.removedState = .hiddenForReuse
                graph.removedState = []
                #expect(graph[ReuseFeature.self]?.pointee.states == [true, false, true, false])
                #expect(delegate.changes == 2)
                graph.requestImmediateUpdate()
                #expect(delegate.delays == [0])
            }
        }

        @Test
        func displayListReturnsTransformedContent() {
            Update.perform {
                let graph = makeGraph(outputs: .displayList)
                graph.append(feature: DisplayListFeature())
                graph.instantiate()
                let (list, _) = graph.displayList()
                #expect(list.items.count == 1)
                guard case .effect(.identity, _) = list.items.first?.value else {
                    Issue.record("Expected the root display list to contain the applied state transform")
                    return
                }
                #expect(list.features.isEmpty)
            }
        }

        private func makeGraph(outputs: ViewGraph.Outputs = []) -> ViewGraph {
            let graph = ViewGraph(rootViewType: EmptyView.self, requestedOutputs: outputs)
            graph.setRootView(EmptyView())
            return graph
        }

        private func makeBridge(in graph: ViewGraph) throws -> (PreferenceBridge, Attribute<Int>, Attribute<PreferenceValues>) {
            let (bridge, outputs) = graph.globalSubgraph.apply {
                graph.data.hostPreferenceKeys.add(HostValueKey.self)
                let bridge = PreferenceBridge()
                var inputs = _ViewInputs(
                    graph.graphInputs,
                    position: graph.$zeroPoint,
                    size: graph.$proposedSize,
                    transform: graph.$transform,
                    containerPosition: graph.$zeroPoint,
                    hostPreferenceKeys: graph.data.$hostPreferenceKeys
                )
                inputs.preferences.add(ValueKey.self)
                inputs.preferences.add(HostPreferencesKey.self)
                var outputs = PreferencesOutputs()
                bridge.wrapOutputs(&outputs, inputs: inputs)
                return (bridge, outputs)
            }
            return (bridge, try #require(outputs[ValueKey.self]), try #require(outputs.hostPreferenceValues))
        }
    }

    struct NextUpdateTests {
        typealias Update = ViewGraph.NextUpdate

        @Test
        func initialStateHasNoPendingUpdate() {
            let update = Update()
            #expect(update.time == .infinity)
            #expect(update.interval == 0)
            #expect(update.reasons.isEmpty)
        }

        @Test(arguments: [
            ([Double.nan], Double.infinity),
            ([3, 1, 2, .nan], 1),
            ([0.0, -0.0], 0.0),
            ([-0.0, 0.0], -0.0),
            ([3, -.infinity, 2], -.infinity),
        ] as [([Double], Double)])
        func atKeepsEarliestTime(requests: [Double], expected: Double) {
            var update = Update()
            update.interval(1 / 120, reason: 7)
            for request in requests {
                update.at(Time(seconds: request))
            }
            #expect(update.time.seconds.bitPattern == expected.bitPattern)
            #expect(update.interval == 1 / 120.0)
            #expect(update.reasons == [7])
        }

        @Test(arguments: [
            (-.infinity, Double.zero, Set<UInt32>()),
            (.nan, Double.zero, Set<UInt32>()),
            (0.0, Double.zero, Set<UInt32>()),
            (159.0, Double.zero, Set<UInt32>()),
            (Double(160).nextDown, Double.zero, Set<UInt32>()),
            (160.0, 1 / 80.0, [0x27_0000]),
            (319.0, 1 / 80.0, [0x27_0000]),
            (Double(320).nextDown, 1 / 80.0, [0x27_0000]),
            (320.0, 1 / 120.0, [0x27_0000]),
            (1000.0, 1 / 120.0, [0x27_0000]),
            (.infinity, 1 / 120.0, [0x27_0000]),
        ] as [(Double, Double, Set<UInt32>)])
        func maxVelocity(velocity: Double, expectedInterval: Double, expectedReasons: Set<UInt32>) {
            var update = Update()
            update.maxVelocity(velocity)
            #expect(update.interval == expectedInterval)
            #expect(update.reasons == expectedReasons)
        }

        @Test(arguments: [
            (0.05, nil, 0.05, Set<UInt32>()),
            (0.025, nil, 0.025, Set<UInt32>()),
            (0.025, 1 as UInt32?, 0.025, [1] as Set<UInt32>),
            (0.0, nil, Double.zero, Set<UInt32>()),
            (-0.0, 0, Double.zero, [0]),
            (.infinity, nil, Double.zero, Set<UInt32>()),
            (-.infinity, nil, Double.zero, Set<UInt32>()),
            (.nan, UInt32.max, Double.zero, [UInt32.max]),
            (-0.025, nil, -0.025, Set<UInt32>()),
            (.leastNonzeroMagnitude, nil, .leastNonzeroMagnitude, Set<UInt32>()),
        ] as [(Double, UInt32?, Double, Set<UInt32>)])
        func intervalWithReason(interval: Double, reason: UInt32?, expectedInterval: Double, expectedReasons: Set<UInt32>) {
            var update = Update()
            update.interval(interval, reason: reason)
            #expect(update.interval == expectedInterval)
            #expect(update.reasons == expectedReasons)
        }

        @Test(arguments: [0.025, 1 / 120.0])
        func nanIntervalPreservesExistingRequest(interval: Double) {
            var update = Update()
            update.interval(interval, reason: 1)
            update.interval(.nan, reason: 2)
            #expect(update.interval == interval)
            #expect(update.reasons == [1, 2])
        }

        @Test(arguments: [
            (1 / 30.0, Double.zero),
            ((1 / 60.0).nextUp, Double.zero),
            (1 / 60.0, 1 / 60.0),
            ((1 / 60.0).nextDown, (1 / 60.0).nextDown),
            (1 / 120.0, 1 / 120.0),
        ] as [(Double, Double)])
        func defaultIntervalSuppressesOnlySlowerRates(interval: Double, expected: Double) {
            for defaultFirst in [false, true] {
                var update = Update()
                let requests = defaultFirst ? [0, interval] : [interval, 0]
                for request in requests {
                    update.interval(request, reason: 1)
                }
                #expect(update.interval == expected)
                #expect(update.reasons == [1])
            }
        }

        @Test
        func requestsKeepFastestRateAndAccumulateReasons() {
            var update = Update()
            update.at(Time(seconds: 3))
            update.interval(0, reason: 0)
            update.maxVelocity(160)
            #expect(update.interval == 1 / 80.0)
            update.maxVelocity(320)
            #expect(update.interval == 1 / 120.0)
            update.interval(1 / 240, reason: 7)
            update.maxVelocity(160)
            update.interval(1 / 30, reason: 7)
            update.interval(.nan, reason: UInt32.max)
            #expect(update.interval == 1 / 240.0)
            #expect(update.time == Time(seconds: 3))
            #expect(update.reasons == [0, 7, UInt32.max, 0x27_0000])
        }
    }

    private struct AlignmentEngine: LayoutEngine {
        func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
            proposedSize.fixingUnspecifiedDimensions()
        }

        func explicitAlignment(_ key: AlignmentKey, at size: ViewSize) -> CGFloat? {
            #expect(size == .fixed(CGSize(width: 64, height: 46)))
            return key == HorizontalAlignment.center.key ? 7 : 9
        }
    }

    private struct ValueKey: PreferenceKey {
        static let defaultValue = 0

        static func reduce(value: inout Int, nextValue: () -> Int) {
            value += nextValue()
        }
    }

    private struct HostValueKey: PreferenceKey {
        static let defaultValue = 0

        static func reduce(value: inout Int, nextValue: () -> Int) {
            value += nextValue()
        }
    }

    private struct PreferenceFeature: ViewGraphFeature {
        func modifyViewOutputs(outputs: inout _ViewOutputs, inputs: _ViewInputs, graph: ViewGraph) {
            outputs[ValueKey.self] = Attribute(value: 42)
            var values = PreferenceValues()
            values[HostValueKey.self] = .init(value: 9, seed: .init(value: 1))
            outputs.preferences.hostPreferenceValues = Attribute(value: values)
        }
    }

    private struct ReuseFeature: ViewGraphFeature {
        var states: [Bool] = []

        mutating func isHiddenForReuseDidChange(graph: ViewGraph) {
            states.append(graph.data.isHiddenForReuse)
        }
    }

    private struct DisplayListFeature: ViewGraphFeature {
        func modifyViewOutputs(outputs: inout _ViewOutputs, inputs: _ViewInputs, graph: ViewGraph) {
            outputs.preferences.displayList = Attribute(value: DisplayList(.init(
                .effect(.state(StrongHash(of: 1)), DisplayList()),
                frame: CGRect(x: 0, y: 0, width: 10, height: 10),
                identity: .init(decodedValue: 1),
                version: .init(decodedValue: 1)
            )))
        }
    }

    private struct BridgeUpdate: Rule {
        let graph: ViewGraph
        let environment: EnvironmentValues
        let deferredUpdate: () -> Void

        var value: Bool {
            graph.updatePreferenceBridge(environment: environment, deferredUpdate: deferredUpdate)
            return GraphHost.isUpdating
        }
    }

    private final class Delegate: ViewGraphDelegate {
        unowned let graph: ViewGraph
        var changes = 0
        var delays: [Double] = []

        init(graph: ViewGraph) {
            self.graph = graph
        }

        func updateViewGraph<T>(body: (ViewGraph) -> T) -> T { body(graph) }
        func graphDidChange() { changes += 1 }
        func preferencesDidChange() {}
        func requestUpdate(after delay: Double) { delays.append(delay) }
    }
}
