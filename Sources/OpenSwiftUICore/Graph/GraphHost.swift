//
//  GraphHost.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP
//  ID: 30C09FF16BC95EC5173809B57186CAC3 (RELEASE_2021)
//  ID: F9F204BD2F8DB167A76F17F3FB1B3335 (RELEASE_2024)

internal import COpenSwiftUICore
package import OpenGraphShims
import Foundation

// MARK: - GraphDelegate

@_spi(ForOpenSwiftUIOnly)
public protocol GraphDelegate: AnyObject {
    func updateGraph<T>(body: (GraphHost) -> T) -> T
    func graphDidChange()
    func preferencesDidChange()
    func beginTransaction()
}

@_spi(ForOpenSwiftUIOnly)
extension GraphDelegate {
    public func beginTransaction() {
        onMainThread {
            // TODO: RunLoop.addObserver
        }
    }
}

private var blockedGraphHosts: [Unmanaged<GraphHost>] = []

// MARK: - GraphHost

@_spi(ForOpenSwiftUIOnly)
open class GraphHost: CustomReflectable {
    private static let sharedGraph: Graph = {
        let graph = Graph()
        // TODO
        return graph
    }()

    
    // MARK: - GraphHost.Data
    
    package struct Data {
        package var graph: Graph?
        package var globalSubgraph: Subgraph
        package var rootSubgraph: Subgraph
        package var isRemoved: Bool
        package var isHiddenForReuse: Bool
        @Attribute package var time: Time
        @Attribute package var environment: EnvironmentValues
        @Attribute package var phase: _GraphInputs.Phase
        @Attribute package var hostPreferenceKeys: PreferenceKeys
        @Attribute package var transaction: Transaction
        @Attribute package var updateSeed: UInt32
        @Attribute package var transactionSeed: UInt32
        package var inputs: _GraphInputs
        
        package init() {
            let graph = Graph(shared: GraphHost.sharedGraph)
            let globalSubgraph = Subgraph(graph: graph)
            Subgraph.current = globalSubgraph
            let time = Attribute(value: Time.zero)
            let environment = Attribute(value: EnvironmentValues())
            let phase = Attribute(value: _GraphInputs.Phase())
            let hostPreferenceKeys = Attribute(value: PreferenceKeys())
            let transaction = Attribute(value: Transaction())
            let updateSeed = Attribute(value: UInt32.zero)
            let transactionSeed = Attribute(value: UInt32.zero)
            let inputs = _GraphInputs(
                time: time,
                phase: phase,
                environment: environment,
                transaction: transaction
            )
            
            let rootSubgrph = Subgraph(graph: graph)
            globalSubgraph.addChild(rootSubgrph)
            Subgraph.current = nil
            
            self.graph = graph
            self.globalSubgraph = globalSubgraph
            self.rootSubgraph = rootSubgrph
            isRemoved = false
            isHiddenForReuse = false
            _time = time
            _environment = environment
            _phase = phase
            _hostPreferenceKeys = hostPreferenceKeys
            _transaction = transaction
            _updateSeed = updateSeed
            _transactionSeed = transactionSeed
            self.inputs = inputs
        }
        
        package mutating func invalidate() {
            guard let graph else { return }
            Update.begin()
            globalSubgraph.invalidate()
            graph.context = nil
            graph.invalidate()
            self.graph = nil
            Update.end()
        }
    }
    
    package final var data: Data
    package final var isValid: Bool { data.graph != nil }
    package final var graph: Graph { data.graph! }
    package final var graphInputs: _GraphInputs { data.inputs }
    package final var globalSubgraph: Subgraph { data.globalSubgraph }
    package final var rootSubgraph: Subgraph { data.rootSubgraph }
    private var constants: [ConstantKey: AnyAttribute] = [:]
    private(set) package final var isInstantiated: Bool = false
    package final var hostPreferenceValues: WeakAttribute<PreferenceList> = WeakAttribute()
    package final var lastHostPreferencesSeed: VersionSeed = .invalid
    private final var pendingTransactions: [AsyncTransaction] = []
    package final var inTransaction: Bool = false
    package final var continuations: [() -> Void] = []
    private(set) package final var mayDeferUpdate: Bool = true
    
    // MARK: - GraphHost.RemovedState
    
    package struct RemovedState: OptionSet {
        package let rawValue: UInt8
        
        package init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        package static let unattached = RemovedState(rawValue: 1 << 0)
        package static let hiddenForReuse = RemovedState(rawValue: 1 << 1)
    }
    
    package final var removedState: RemovedState = [] {
        didSet {
            updateRemovedState()
        }
    }
    
    package static var currentHost: GraphHost {
        #if canImport(Darwin)
        if let currentAttribute = AnyAttribute.current {
            currentAttribute.graph.graphHost()
        } else if let currentSubgraph = Subgraph.current {
            currentSubgraph.graph.graphHost()
        } else {
            fatalError("no current graph host")
        }
        #else
        fatalError("Compiler issue on Linux. See #39")
        #endif
    }
    
    package init(data: Data) {
        mainThreadPrecondition()
        self.data = data
        // FIXME: API needs to be updated in OG
        Graph.setUpdateCallback(graph) { [weak self] in
            guard let self,
                  let graphDelegate
            else { return }
            graphDelegate.updateGraph { _ in }
        }
        #if canImport(Darwin)
        Graph.setInvalidationCallback(graph) { [weak self] attribute in
            guard let self else { return }
            graphInvalidation(from: attribute)
        }
        #endif
        graph.setGraphHost(self)
    }
    
    deinit {
        invalidate()
        blockedGraphHosts.removeAll { $0.takeUnretainedValue() === self }
    }
    
    package final func invalidate() {
        if isInstantiated {
            globalSubgraph.willInvalidate(isInserted: false)
            isInstantiated = false
        }
        if let graph = data.graph {
            Update.begin()
            globalSubgraph.invalidate()
            graph.context = nil
            graph.invalidate()
            data.graph = nil
            Update.end()
        }
    }
    
    package static var isUpdating: Bool {
        sharedGraph.counter(for: ._7) != 0
    }
    
    package final var isUpdating: Bool {
        guard let graph = data.graph else { return false }
        return graph.counter(for: ._6) != 0
    }
    
    package final func setNeedsUpdate(mayDeferUpdate: Bool) {
        self.mayDeferUpdate = self.mayDeferUpdate && mayDeferUpdate
        // Blocked by OGGraphSetNeedsUpdate
        // data.graph?.setNeedsUpdate()
    }

    // MARK: - GraphHost.ConstantID
    
    package enum ConstantID: Int8, Hashable {
        case defaultValue
        case implicitRoot
        case trueValue
        case defaultValue3D
        case failedValue
        case placeholder
    }
    
    package final func intern<T>(_ value: T, for type: Any.Type = T.self, id: ConstantID) -> Attribute<T> {
        if let attribute = constants[ConstantKey(type: type , id: id)] {
            return Attribute(identifier: attribute)
        } else {
            let result = globalSubgraph.apply { Attribute(value: value) }
            constants[ConstantKey(type: type, id: id)] = result.identifier
            return result
        }
    }
    
    public final var customMirror: Mirror { Mirror(self, children: []) }
    
    open var graphDelegate: GraphDelegate? { nil }
    open var parentHost: GraphHost? { nil }
    open func instantiateOutputs() {}
    open func uninstantiateOutputs() {}
    open func timeDidChange() {}
    open func isHiddenForReuseDidChange() {}
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension GraphHost: Sendable {}

@_spi(ForOpenSwiftUIOnly)
extension GraphHost {
    package final func updateRemovedState() {
        print("TODO")
    }
}

// MARK: - ConstantKey

private struct ConstantKey: Hashable {
    static func == (lhs: ConstantKey, rhs: ConstantKey) -> Bool {
        lhs.type == rhs.type && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type))
        hasher.combine(id.rawValue)
    }
    
    var type: Any.Type
    var id: GraphHost.ConstantID
}

private let waitingForPreviewThunks = EnvironmentHelper.bool(for: "XCODE_RUNNING_FOR_PREVIEWS")

@_spi(ForOpenSwiftUIOnly)
package extension GraphHost {
    
//    static func globalTransaction<Mutation: GraphMutation>(
//        _ transaction: Transaction,
//        mutation: Mutation,
//        hostProvider: TransactionHostProvider
//    ) {
//        fatalError("TODO")
//    }
    
    private static func flushGlobalTransactions() {
        fatalError("TODO")
    }
    
    private static var pendingGlobalTransactions: [GlobalTransaction] = []
    
    // MARK: - data
    
    final func setTime(_ time: Time) {
        guard data.time != time else {
            return
        }
        data.time = time
        timeDidChange()
    }
    
    final var environment: EnvironmentValues { data.environment }
    
    final func setEnvironment(_ environment: EnvironmentValues) {
        data.environment = environment
    }
    
    final func setPhase(_ phase: _GraphInputs.Phase) {
//        data.phase = phase
    }
    
    // TODO: _ArchivedViewHost.reset()
    final func incrementPhase() {
        // data.phase.value += 2
        graphDelegate?.graphDidChange()
    }
    
    final func preferenceValues() -> PreferenceList {
        instantiateIfNeeded()
        return hostPreferenceValues.value ?? PreferenceList()
    }
    
    final func preferenceValue<Key: HostPreferenceKey>(_ key: Key.Type) -> Key.Value {
        if data.hostPreferenceKeys.contains(key) {
            return preferenceValues()[key].value
        } else {
            defer { removePreference(key) }
            addPreference(key)
            return preferenceValues()[key].value
        }
    }

    final func addPreference<Key: HostPreferenceKey>(_ key: Key.Type) {
        OGGraph.withoutUpdate {
            data.hostPreferenceKeys.add(key)
        }
    }

    final func removePreference<Key: HostPreferenceKey>(_ key: Key.Type) {
        OGGraph.withoutUpdate {
            data.hostPreferenceKeys.remove(key)
        }
    }

    final func updatePreferences() -> Bool {
        let seed = hostPreferenceValues.value?.seed ?? .empty
        let lastSeed = lastHostPreferencesSeed
        let didUpdate = seed.isInvalid || lastSeed.isInvalid /*|| (seed != lastSeed)*/
        lastHostPreferencesSeed = seed
        return didUpdate
    }
    
//    final func updateRemovedState() {
//        fatalError("TODO")
//    }
    
    // MARK: - instantiate and uninstantiate
    
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
    
    final func uninstantiate(immediately _: Bool) {
        guard isInstantiated else {
            return
        }
        // TODO:
    }
    
    final func graphInvalidation(from attribute: AnyAttribute?) {
        #if canImport(Darwin)
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
                style: .deferred,
                mayDeferUpdate: true
            )
        }
        #endif
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
        while !host.inTransaction {
            guard let parent = host.parentHost else {
                asyncTransaction(
                    Transaction(),
                    mutation: CustomGraphMutation(body),
                    style: .deferred,
                    mayDeferUpdate: true
                )
                return
            }
            host = parent
        }
        host.continuations.append(body)
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
        if !mutations.isEmpty, mutations[mutations.count - 1].combine(with: mutation) {
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

// MARK: - GlobalTransaction

private final class GlobalTransaction {
    let hostProvider: TransactionHostProvider

    init(transaction _: Transaction, hostProvider: TransactionHostProvider) {
        self.hostProvider = hostProvider
    }
}

package protocol TransactionHostProvider {
    var mutationHost: GraphHost? { get }
}

// MARK: - Graph + Extension

extension Graph {
    package func graphHost() -> GraphHost {
        unsafeBitCast(context, to: GraphHost.self)
    }
    
    fileprivate final func setGraphHost(_ graphHost: GraphHost) {
        context = UnsafeRawPointer(Unmanaged.passUnretained(graphHost).toOpaque())
    }
}
