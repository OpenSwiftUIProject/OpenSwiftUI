//
//  ContentPathObserverTests.swift
//  OpenSwiftUICoreTests

@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
@testable import OpenSwiftUICore
import Testing

struct ContentPathObserverTests {
    @Test
    func unfinishedObserverIsRetainedUntilFinished() {
        var observers = ContentPathObservers()
        let observer = TestContentPathObserver()
        // The test observer does not inspect its parent. Avoid constructing a
        // ViewResponder, whose public initializer requires a live ViewGraph.
        let parentObject: AnyObject = ResponderNode()
        let parent = unsafeBitCast(parentObject, to: ViewResponder.self)
        let transform = (old: ViewTransform(), new: ViewTransform())

        observers.addObserver(observer)
        observers.notifyPathChanged(for: parent, changes: [], transform: transform)
        #expect(observer.callCount == 1)

        observers.notifyPathChanged(for: parent, changes: [], transform: transform)
        #expect(observer.callCount == 2)

        observers.notifyPathChanged(for: parent, changes: [], transform: transform)
        #expect(observer.callCount == 2)
    }
}

private final class TestContentPathObserver: ContentPathObserver {
    private(set) var callCount = 0

    func respondersDidChange(for parent: ViewResponder) {}

    func contentPathDidChange(
        for parent: ViewResponder,
        changes: ContentPathChanges,
        transform: (old: ViewTransform, new: ViewTransform),
        finished: inout Bool
    ) {
        callCount += 1
        finished = callCount >= 2
    }
}
