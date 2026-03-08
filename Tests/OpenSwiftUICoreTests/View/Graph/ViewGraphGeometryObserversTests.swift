//
//  ViewGraphGeometryObserversTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Foundation
import Testing

private struct TestMeasurer: ViewGraphGeometryMeasurer {
    typealias Proposal = CGSize
    typealias Size = CGFloat

    static var mockValue: CGFloat?

    static func measure(given proposal: CGSize, in graph: ViewGraph) -> CGFloat {
        mockValue ?? max(proposal.width, proposal.height)
    }

    static func measure(proposal: CGSize, layoutComputer: LayoutComputer, insets: EdgeInsets) -> CGFloat {
        mockValue ?? max(proposal.width, proposal.height)
    }

    static var invalidValue: CGFloat = .nan
}

struct ViewGraphGeometryObserversTests {
    fileprivate typealias Observers = ViewGraphGeometryObservers<TestMeasurer>

    #if canImport(Darwin)
    @MainActor
    @Test
    func observeCallback() async throws {
        await confirmation(expectedCount: 1) { confirm in
            var observers = Observers()
            observers.addObserver(for: CGSize(width: 10, height: 20)) { oldSize, newSize in
                confirm()
                #expect(oldSize.isApproximatelyEqual(to: 20.0))
                #expect(newSize.isApproximatelyEqual(to: 30.0))
            }
            let emptyViewGraph = ViewGraph(rootViewType: EmptyView.self)
            _ = observers.needsUpdate(graph: emptyViewGraph)
            TestMeasurer.mockValue = 30.0
            defer { TestMeasurer.mockValue = nil }
            _ = observers.needsUpdate(graph: emptyViewGraph)
            observers.notify()
        }
    }
    #endif

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
