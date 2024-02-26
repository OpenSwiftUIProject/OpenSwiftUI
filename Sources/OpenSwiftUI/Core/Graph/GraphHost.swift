//
//  GraphHost.swift
//  OpenSwiftUI
//
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 30C09FF16BC95EC5173809B57186CAC3

internal import OpenGraphShims

class GraphHost {
    var data: Data
    var isInstantiated: Bool
//    var hostPreferenceValues: OptionalAttribute<PreferenceList>
//    var lastHostPreferencesSeed: VersionSeed
//    var pendingTransactions: [AsyncTransaction]
//    var inTransaction: Bool
//    var continuations: [() -> ()]
//    var mayDeferUpdate: Bool
//    var removedState: RemovedState
    
    // FIXME
    static var isUpdating = false
    
    private static let sharedGraph = OGGraph()

    // MARK: - non final methods
    
    init(data: Data) {
        self.data = data
        isInstantiated = false
        // TODO
    }
    
    func invalidate() {
        // TODO
    }
    
    var graphDelegate: GraphDelegate? { nil }
    var parentHost: GraphHost? { nil }
    func instantiateOutputs() {}
    func uninstantiateOutputs() {}
    func timeDidChange() {}
    func isHiddenForReuseDidChange() {}
    
    // MARK: - final methods
    
    final func instantiate() {
        guard !isInstantiated else {
            return
        }
        graphDelegate?.updateGraph { _ in }
        instantiateOutputs()
        isInstantiated = true
    }
}

// MARK: - GraphHost.Data

extension GraphHost {
    struct Data {
        var graph: OGGraph?
        var globalSubgraph: OGSubgraph
        var rootSubgraph: OGSubgraph
        var isRemoved = false
        var isHiddenForReuse = false
        @Attribute var time: Time
        @Attribute var environment: EnvironmentValues
        @Attribute var phase: _GraphInputs.Phase
        @Attribute var hostPreferenceKeys: PreferenceKeys
        @Attribute var transaction: Transaction
        var inputs: _GraphInputs
        
        init() {
            let graph = OGGraph(shared: GraphHost.sharedGraph)
            let globalSubgraph = OGSubgraph(graph: graph)
            OGSubgraph.current = globalSubgraph
            let time = Attribute(value: Time.zero)
            let environment = Attribute(value: EnvironmentValues())
            let phase = Attribute(value: _GraphInputs.Phase(value: 0))
            let hostPreferenceKeys = Attribute(value: PreferenceKeys())
            let transaction = Attribute(value: Transaction())
            let cachedEnvironment = MutableBox(CachedEnvironment(environment))
            let rootSubgrph = OGSubgraph(graph: graph)
            globalSubgraph.addChild(rootSubgrph)
            OGSubgraph.current = nil
            self.graph = graph
            self.globalSubgraph = globalSubgraph
            self.rootSubgraph = rootSubgrph
            _time = time
            _environment = environment
            _phase = phase
            _hostPreferenceKeys = hostPreferenceKeys
            _transaction = transaction
            inputs = _GraphInputs(
                time: time,
                cachedEnvironment: cachedEnvironment,
                phase: phase,
                transaction: transaction
            )
        }
    }
}

// MARK: - GraphHost.RemovedState

extension GraphHost {
    // TODO
    struct RemovedState: OptionSet {
        let rawValue: UInt8
    }
}
