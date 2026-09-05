//
//  GraphHostTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import Testing

@MainActor
struct GraphHostTests {
    #if canImport(Darwin)
    @Test
    func dataRestoresCurrentSubgraph() {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        let oldCurrent = Subgraph.current
        Subgraph.current = subgraph
        defer { Subgraph.current = oldCurrent }

        var data = GraphHost.Data()
        #expect(Subgraph.current === subgraph)
        data.invalidate()
    }

    @Test
    func transactionSeedWraps() {
        let host = GraphHost(data: .init())
        host.data.transactionSeed = .max
        host.startTransactionUpdate(id: 42)
        #expect(host.data.transactionSeed == 0)
        #expect(host.inTransaction)
        host.finishTransactionUpdate(in: host.globalSubgraph, id: 42)
        #expect(!host.inTransaction)
    }

    @Test
    func immediateUpdateRequestSurvivesDeferredMutation() {
        let host = GraphHost(data: .init())
        host.asyncTransaction(mutation: CustomGraphMutation({}), mayDeferUpdate: false)
        #expect(!host.mayDeferUpdate)
        host.asyncTransaction(mutation: CustomGraphMutation({}), mayDeferUpdate: true)
        #expect(!host.mayDeferUpdate)
        host.flushTransactions()
        #expect(host.mayDeferUpdate)
    }

    @Test
    func inheritedRemovalUsesHiddenForReuse() {
        let parent = GraphHost(data: .init())
        let child = ChildHost(data: .init())
        child.parent = parent

        parent.removedState = .unattached
        child.updateRemovedState()
        #expect(!child.data.isRemoved)
        #expect(!child.data.isHiddenForReuse)

        parent.removedState = .hiddenForReuse
        child.updateRemovedState()
        #expect(child.data.isRemoved)
        #expect(child.data.isHiddenForReuse)

        parent.removedState = []
        child.updateRemovedState()
        #expect(!child.data.isRemoved)
        #expect(!child.data.isHiddenForReuse)
    }

    @Test(arguments: [false, true])
    func uninstantiateReplacesRoot(immediately: Bool) {
        Update.perform {
            let host = GraphHost(data: .init())
            host.instantiate()
            let oldRoot = host.rootSubgraph
            host.uninstantiate(immediately: immediately)
            #expect(!host.isInstantiated)
            #expect(host.rootSubgraph !== oldRoot)
            #expect(oldRoot.isValid == !immediately)
            Update.dispatchActions()
            #expect(!oldRoot.isValid)
            host.instantiate()
            #expect(host.isInstantiated)
        }
    }

    private final class ChildHost: GraphHost {
        var parent: GraphHost?
        override var parentHost: GraphHost? { parent }
    }
    #endif

    @Test
    func setTimeTest() {
        #if canImport(Darwin)
        let graphHost = GraphHost(data: .init())
        #expect(graphHost.data.time.seconds == 0.0)

        graphHost.setTime(Time.zero)
        #expect(graphHost.data.time.seconds == 0.0)

        graphHost.setTime(Time.infinity)
        #expect(graphHost.data.time.seconds == Time.infinity.seconds)
        
        let timeNow = Time.systemUptime
        graphHost.setTime(timeNow)
        #expect(graphHost.data.time.seconds == timeNow.seconds)
        #endif
    }
}
