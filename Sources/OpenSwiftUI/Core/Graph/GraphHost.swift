//
//  GraphHost.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 30C09FF16BC95EC5173809B57186CAC3

internal import COpenSwiftUI
internal import OpenGraphShims

private let waitingForPreviewThunks = EnvironmentHelper.value(for: "XCODE_RUNNING_FOR_PREVIEWS") != 0
private var blockedGraphHosts: [Unmanaged<GraphHost>] = []

class GraphHost {
    // MARK: - Properties
    
    private(set) var data: Data
    private(set) var isInstantiated = false
    private(set) var hostPreferenceValues: OptionalAttribute<PreferenceList>
    private(set) var lastHostPreferencesSeed: VersionSeed = .invalid
    private var pendingTransactions: [AsyncTransaction] = []
    private(set) var inTransaction = false
    private(set) var continuations: [() -> Void] = []
    private(set) var mayDeferUpdate = true
    private(set) var removedState: RemovedState = []

    // MARK: - static properties and methods
    
    static var currentHost: GraphHost {
        if let currentAttribute = OGAttribute.current {
            currentAttribute.graph.graphHost()
        } else if let currentSubgraph = OGSubgraph.current {
            currentSubgraph.graph.graphHost()
        } else {
            fatalError("no current graph host")
        }
    }
    
    static var isUpdating: Bool {
        sharedGraph.counter(for: ._7) != 0
    }
    
    static func globalTransaction<Mutation: GraphMutation>(
        _ transaction: Transaction,
        mutation: Mutation,
        hostProvider: TransactionHostProvider
    ) {
        fatalError("TODO")
    }
    
    private static func flushGlobalTransactions() {
        fatalError("TODO")
    }
    
    private static let sharedGraph = OGGraph()
    private static var pendingGlobalTransactions: [GlobalTransaction] = []
    
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
        blockedGraphHosts.removeAll { $0.takeUnretainedValue() === self }
    }
    
    final var graph: OGGraph { data.graph! }
    final var graphInputs: _GraphInputs { data.inputs }
    final var environment: EnvironmentValues { data.environment }
    final var isValid: Bool { data.graph != nil }
    final var isUpdating: Bool {
        guard let graph = data.graph else {
            return false
        }
        return graph.counter(for: ._6) != 0
    }
    
    final func instantiate() {
        guard !isInstantiated else {
            return
        }
        graphDelegate?.updateGraph { _ in }
        instantiateOutputs()
        isInstantiated = true
    }
    
    final func instantiateIfNeeded() {
        guard !isInstantiated else {
            return
        }
        if waitingForPreviewThunks {
            if !blockedGraphHosts.contains(where: { $0.takeUnretainedValue() === self }) {
                blockedGraphHosts.append(.passUnretained(self))
            }
        } else {
            instantiate()
        }
    }
    
    final func uninstantiate(immediately: Bool) {
        guard isInstantiated else {
            return
        }
        // TODO
    }
        
    final func graphInvalidation(from attribute: OGAttribute?) {
        guard let attribute else {
            graphDelegate?.graphDidChange()
            return
        }
        let host = attribute.graph.graphHost()
        let transaction = host.data.transaction
        mayDeferUpdate = mayDeferUpdate ? host.mayDeferUpdate : false
        if transaction.isEmpty {
            graphDelegate?.graphDidChange()
        } else {
            asyncTransaction(
                transaction,
                mutation: EmptyGraphMutation(), 
                style: ._1,
                mayDeferUpdate: true
            )
        }
    }
    
    // MARK: - Transaction
        
    final var hasPendingTransactions: Bool { !pendingTransactions.isEmpty }

    final func asyncTransaction<Mutation: GraphMutation>(
        _ transaction: Transaction,
        mutation: Mutation,
        style: _GraphMutation_Style,
        mayDeferUpdate: Bool
    ) {
        // TODO
    }
    
    final func flushTransactions() {
        guard isValid else {
            return
        }
        guard !pendingTransactions.isEmpty else {
            return
        }
        let transactions = pendingTransactions
        pendingTransactions = []
        for _ in transactions {
            instantiateIfNeeded()
            // TODO
        }
        graphDelegate?.graphDidChange()
        mayDeferUpdate = true
    }
    
    final func continueTransaction(_ body: @escaping () -> Void) {
        var host = self
        while(!host.inTransaction) {
            guard let parent = host.parentHost else {
                asyncTransaction(
                    Transaction(),
                    mutation: CustomGraphMutation(body: body),
                    style: ._1,
                    mayDeferUpdate: true
                )
                return
            }
            host = parent
        }
        host.continuations.append(body)
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

// MARK: - GlobalTransaction

private final class GlobalTransaction {
    let hostProvider: TransactionHostProvider

    init(transaction _: Transaction, hostProvider: TransactionHostProvider) {
        self.hostProvider = hostProvider
    }
}
