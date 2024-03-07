//
//  GraphHost.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 30C09FF16BC95EC5173809B57186CAC3

internal import COpenSwiftUI
internal import OpenGraphShims

class GraphHost {
    var data: Data
    var isInstantiated = false
    var hostPreferenceValues: OptionalAttribute<PreferenceList>
    var lastHostPreferencesSeed: VersionSeed = .invalid
    private var pendingTransactions: [AsyncTransaction] = []
    var inTransaction = false
    var continuations: [() -> Void] = []
    var mayDeferUpdate = true
    var removedState: RemovedState = []
    
    // FIXME
    static var isUpdating = false
    
    private static let sharedGraph = OGGraph()

    // MARK: - inheritable methods
    
    init(data: Data) {
        if !Thread.isMainThread {
            Log.runtimeIssues("calling into OpenSwiftUI on a non-main thread is not supported")
        }
        hostPreferenceValues = OptionalAttribute()
        self.data = data
        OGGraph.setUpdateCallback(graph) { [weak self] in
            guard let self,
                  let graphDelegate
            else { return }
            graphDelegate.updateGraph { _ in }
        }
        OGGraph.setInvalidationCallback(graph) { [weak self] attribute in
            guard let self else { return }
            graphInvalidation(from: attribute)
        }
        graph.setGraphHost(self)
    }
    
    func invalidate() {
        if isInstantiated {
            data.globalSubgraph.willInvalidate(isInserted: false)
            isInstantiated = false
        }
        if let graph = data.graph {
            data.globalSubgraph.invalidate()
            graph.context = nil
            graph.invalidate()
            data.graph = nil
        }
    }
    
    var graphDelegate: GraphDelegate? { nil }
    var parentHost: GraphHost? { nil }
    func instantiateOutputs() {}
    func uninstantiateOutputs() {}
    func timeDidChange() {}
    func isHiddenForReuseDidChange() {}
    
    // MARK: - final methods
    
    deinit {
        invalidate()
        // TODO
    }
    
    final var graph: OGGraph { data.graph! }

    final func instantiate() {
        guard !isInstantiated else {
            return
        }
        graphDelegate?.updateGraph { _ in }
        instantiateOutputs()
        isInstantiated = true
    }
    
    final func graphInvalidation(from attribute: OGAttribute?) {
        // TODO
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

// MARK: - AsyncTransaction

private final class AsyncTransaction {
    let transaction: Transaction
    var mutations: [GraphMutation] = []
    
    init(_ transaction: Transaction) {
        self.transaction = transaction
    }
    
    func append<Mutation: GraphMutation>(_ mutation: Mutation) {
        // ``GraphMutation/combine`` is mutating function
        // So we use ``Array.subscript/_modify`` instead of ``Array.last/getter`` to mutate inline
        if !mutations.isEmpty, mutations[mutations.count-1].combine(with: mutation) {
            return
        }
        mutations.append(mutation)
    }
    
    func apply() {
        withTransaction(transaction) {
            for mutation in mutations {
                mutation.apply()
            }
        }
    }
}

// MARK: - OGGraph + Extension

extension OGGraph {
    final func graphHost() -> GraphHost {
        context!.assumingMemoryBound(to: GraphHost.self).pointee
    }
    
    fileprivate final func setGraphHost(_ graphHost: GraphHost) {
        context = UnsafeRawPointer(Unmanaged.passUnretained(graphHost).toOpaque())
    }
}
