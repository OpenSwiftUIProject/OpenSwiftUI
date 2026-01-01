//
//  ViewGraphGeometryObserversTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Foundation
import Testing

private struct TestMeasurer: ViewGraphGeometryMeasurer {
    typealias Proposal = CGSize
    typealias Size = CGFloat

    static func measure(given proposal: CGSize, in graph: ViewGraph) -> CGFloat {
        max(proposal.width, proposal.height)
    }

    static func measure(proposal: CGSize, layoutComputer: LayoutComputer, insets: EdgeInsets) -> CGFloat {
        max(proposal.width, proposal.height)
    }

    static var invalidValue: CGFloat = .nan
}

struct ViewGraphGeometryObserversTests {
    fileprivate typealias Observers = ViewGraphGeometryObservers<TestMeasurer>

    @MainActor
    @Test
    func observeCallback() async throws {
        // TODO: when the callback got called.
        await confirmation(expectedCount: 0) { confirm in
            var observers = Observers()
            observers.addObserver(for: CGSize(width: 10, height: 20)) { _, _ in
                confirm()
            }
            let emptyViewGraph = ViewGraph(rootViewType: EmptyView.self)
            _ = observers.needsUpdate(graph: emptyViewGraph)
        }
    }

    @Test
    func addObserverExclusiveRemovesExisting() {
        var observers = Observers()
        observers.addObserver(for: CGSize(width: 10, height: 20)) { _, _ in }
        observers.addObserver(for: CGSize(width: 30, height: 40), exclusive: true) { _, _ in }
        #expect(observers.resetObserver(for: CGSize(width: 10, height: 20)) == false)
        #expect(observers.resetObserver(for: CGSize(width: 30, height: 40)) == true)
    }

    @Test
    func addObserverNonExclusiveKeepsExisting() {
        var observers = Observers()
        observers.addObserver(for: CGSize(width: 10, height: 20)) { _, _ in }
        observers.addObserver(for: CGSize(width: 30, height: 40), exclusive: false) { _, _ in }
        #expect(observers.resetObserver(for: CGSize(width: 10, height: 20)) == true)
        #expect(observers.resetObserver(for: CGSize(width: 30, height: 40)) == true)
    }
}
