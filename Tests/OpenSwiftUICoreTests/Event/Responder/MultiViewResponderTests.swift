//
//  MultiViewResponderTests.swift
//  OpenSwiftUICoreTests
//
//  Author: GPT-6 Astra

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct MultiViewResponderTests {
    @Test
    func unchangedChildrenKeepObserverUntilNextChange() {
        withViewGraph {
            let parent = MultiViewResponder()
            let first = TestResponder("first")
            let second = TestResponder("second")
            let observer = TestContentPathObserver()

            parent.addObserver(observer)
            parent.children = []
            #expect(observer.changeCount == 0)

            parent.children = [first, second]
            #expect(observer.changeCount == 1)

            parent.addObserver(observer)
            parent.children = [first, second]
            #expect(observer.changeCount == 1)

            parent.children = [second, first]
            #expect(observer.changeCount == 2)
            #expect(parent.children.map(ObjectIdentifier.init) == [
                ObjectIdentifier(second), ObjectIdentifier(first),
            ])
            #expect(first.parent === parent)
            #expect(second.parent === parent)
            #expect(first.resetCount == 0)
            #expect(second.resetCount == 0)
        }
    }

    @Test
    func insertingChildrenPreservesExistingParents() {
        withViewGraph {
            let parent = MultiViewResponder()
            let first = TestResponder("first")
            let second = TestResponder("second")
            let inserted = TestResponder("inserted")
            let appended = TestResponder("appended")
            parent.children = [first, second]

            parent.children = [inserted, second, first, appended]

            #expect(parent.children.map(ObjectIdentifier.init) == [
                ObjectIdentifier(inserted), ObjectIdentifier(second),
                ObjectIdentifier(first), ObjectIdentifier(appended),
            ])
            #expect(first.parent === parent)
            #expect(second.parent === parent)
            #expect(inserted.parent === parent)
            #expect(appended.parent === parent)
            #expect(first.resetCount == 0)
            #expect(second.resetCount == 0)
        }
    }

    @Test
    func removalCallbacksSeeReorderedChildrenBeforeTruncation() {
        withViewGraph {
            let parent = MultiViewResponder()
            let first = TestResponder("first")
            let second = TestResponder("second")
            let retained = TestResponder("retained")
            parent.children = [first, second, retained]
            let parentID = ObjectIdentifier(parent)
            let reorderedIDs = [
                ObjectIdentifier(retained), ObjectIdentifier(second), ObjectIdentifier(first),
            ]
            var callbacks: [String] = []
            for child in [first, second] {
                child.onReset = { responder in
                    callbacks.append("reset \(responder.name)")
                    #expect(responder.parent.map(ObjectIdentifier.init) == parentID)
                    #expect(responder.parent?.children.map(ObjectIdentifier.init) == reorderedIDs)
                }
            }
            let observer = TestContentPathObserver { updatedParent in
                callbacks.append("changed")
                #expect(updatedParent.children.map(ObjectIdentifier.init) == [ObjectIdentifier(retained)])
                #expect(first.parent == nil)
                #expect(second.parent == nil)
            }
            parent.addObserver(observer)

            parent.children = [retained]

            #expect(callbacks == ["reset second", "reset first", "changed"])
            #expect(observer.changeCount == 1)
            #expect(parent.children.map(ObjectIdentifier.init) == [ObjectIdentifier(retained)])
            #expect(first.parent == nil)
            #expect(second.parent == nil)
            #expect(retained.parent === parent)
            #expect(retained.resetCount == 0)
        }
    }

    @Test
    func removalDoesNotDetachChildFromAnotherParent() {
        withViewGraph {
            let parent = MultiViewResponder()
            let otherParent = MultiViewResponder()
            let moved = TestResponder("moved")
            let retained = TestResponder("retained")
            parent.children = [moved, retained]
            otherParent.children = [moved]

            parent.children = [retained]

            #expect(parent.children.map(ObjectIdentifier.init) == [ObjectIdentifier(retained)])
            #expect(otherParent.children.map(ObjectIdentifier.init) == [ObjectIdentifier(moved)])
            #expect(moved.parent === otherParent)
            #expect(retained.parent === parent)
            #expect(moved.resetCount == 0)
            #expect(retained.resetCount == 0)
        }
    }

    @Test
    func clearingChildrenDetachesEachChildOnce() {
        withViewGraph {
            let parent = MultiViewResponder()
            let first = TestResponder("first")
            let second = TestResponder("second")
            parent.children = [first, second]
            let observer = TestContentPathObserver { updatedParent in
                #expect(updatedParent.children.isEmpty)
                #expect(first.parent == nil)
                #expect(second.parent == nil)
            }
            parent.addObserver(observer)

            parent.children = []

            #expect(parent.children.isEmpty)
            #expect(first.parent == nil)
            #expect(second.parent == nil)
            #expect(first.resetCount == 1)
            #expect(second.resetCount == 1)
            #expect(observer.changeCount == 1)
        }
    }

    private func withViewGraph(_ body: () -> Void) {
        let graph = ViewGraph(rootViewType: EmptyView.self)
        let host = TestEventGraphHost(graph: graph)
        graph.delegate = host
        withExtendedLifetime(host) {
            graph.rootSubgraph.apply(body)
        }
    }
}

private final class TestResponder: ViewResponder {
    let name: String
    private(set) var resetCount = 0
    var onReset: ((TestResponder) -> Void)?

    init(_ name: String) {
        self.name = name
        super.init()
    }

    override func resetGesture() {
        resetCount += 1
        onReset?(self)
    }
}

private final class TestContentPathObserver: ContentPathObserver {
    private(set) var changeCount = 0
    let onChange: (ViewResponder) -> Void

    init(onChange: @escaping (ViewResponder) -> Void = { _ in }) {
        self.onChange = onChange
    }

    func respondersDidChange(for parent: ViewResponder) {
        changeCount += 1
        onChange(parent)
    }

    func contentPathDidChange(
        for parent: ViewResponder,
        changes: ContentPathChanges,
        transform: (old: ViewTransform, new: ViewTransform),
        finished: inout Bool
    ) {}
}

private final class TestEventGraphHost: ViewGraphDelegate, EventGraphHost {
    let graph: ViewGraph
    let eventBindingManager = EventBindingManager()

    init(graph: ViewGraph) {
        self.graph = graph
        eventBindingManager.host = self
    }

    func `as`<T>(_ type: T.Type) -> T? { self as? T }

    func updateViewGraph<T>(body: (ViewGraph) -> T) -> T { body(graph) }

    func requestUpdate(after: Double) {}

    func graphDidChange() {}

    func preferencesDidChange() {}

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
