//
//  GraphHost.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Blocked by transactions
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
    #if canImport(Darwin)
    private var constants: [ConstantKey: AnyAttribute] = [:]
    #endif
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
        graph.context = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
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
        #if canImport(Darwin)
        if let attribute = constants[ConstantKey(type: type , id: id)] {
            return Attribute(identifier: attribute)
        } else {
            let result = globalSubgraph.apply { Attribute(value: value) }
            constants[ConstantKey(type: type, id: id)] = result.identifier
            return result
        }
        #else
        fatalError("See #39")
        #endif
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
    package final func graphInvalidation(from src: AnyAttribute?) {
        #if canImport(Darwin)
        guard let src else {
            graphDelegate?.graphDidChange()
            return
        }
        let host = src.graph.graphHost()
        let transaction = host.data.transaction
        mayDeferUpdate = mayDeferUpdate && host.mayDeferUpdate
        guard !transaction.isEmpty else {
            graphDelegate?.graphDidChange()
            return
        }
        emptyTransaction(transaction)
        #endif
    }
    
    package final func instantiate() {
        guard !isInstantiated else {
            return
        }
        graphDelegate?.updateGraph { _ in }
        instantiateOutputs()
        isInstantiated = true
    }
    
    package final func uninstantiate(immediately: Bool) {
        guard isInstantiated else {
            return
        }
        fatalError("TODO")
    }
    
    package final func uninstantiate() {
        uninstantiate(immediately: false)
    }

    package final func instantiateIfNeeded() {
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
    
    package final func setTime(_ time: Time) {
        guard data.time != time else {
            return
        }
        data.time = time
        timeDidChange()
    }
    
    package final var environment: EnvironmentValues {
        data.environment
    }
    
    package final func setEnvironment(_ environment: EnvironmentValues) {
        data.environment = environment
    }
    
    package final func setPhase(_ phase: _GraphInputs.Phase) {
        data.phase = phase
    }
    
    // TODO: _ArchivedViewHost.reset()
    package final func incrementPhase() {
        data.phase.resetSeed &+= 1
        graphDelegate?.graphDidChange()
    }
    
    package final func updateRemovedState() {
        fatalError("TODO")
    }
    
    // MARK: - GraphHost + Transaction
    
    package final func asyncTransaction<T>(
        _ transaction: Transaction = .init(),
        id transactionID: Transaction.ID = Transaction.id,
        mutation: T,
        style: _GraphMutation_Style = .deferred,
        mayDeferUpdate: Bool = true
    ) where T: GraphMutation {
        fatalError("TODO")
    }
    
    package final func asyncTransaction(
        _ transaction: Transaction = .init(),
        id transactionID: Transaction.ID = Transaction.id,
        _ body: @escaping () -> Void
    ) {
        asyncTransaction(transaction, id: transactionID, mutation: CustomGraphMutation(body))
    }
    
    package final func asyncTransaction<T>(
        _ transaction: Transaction = .init(),
        id transactionID: Transaction.ID = Transaction.id,
        invalidating attribute: WeakAttribute<T>,
        style: _GraphMutation_Style = .deferred,
        mayDeferUpdate: Bool = true
    ) {
        #if canImport(Darwin)
        // Blocked by WeakAttribute.base API in OpenGraph
        // asyncTransaction(transaction, id: transactionID, mutation: InvalidatingGraphMutation(attribute: attribute.base), style: style, mayDeferUpdate: mayDeferUpdate)
        #endif
    }
    
    package final func emptyTransaction(_ transaction: Transaction = .init()) {
        asyncTransaction(transaction, mutation: EmptyGraphMutation())
    }
    
    package final func continueTransaction(_ body: @escaping () -> Void) {
        Update.assertIsLocked()
        var host = self
        while !host.inTransaction {
            guard let parent = host.parentHost else {
                Update.enqueueAction(body)
                return
            }
            host = parent
        }
        host.continuations.append(body)
    }
    
    package final var hasPendingTransactions: Bool { !pendingTransactions.isEmpty }

    package final func flushTransactions() {
        guard isValid, hasPendingTransactions else {
            return
        }
        let transactions = pendingTransactions
        pendingTransactions = []
        for _ in transactions {
            instantiateIfNeeded()
            fatalError("TODO")
        }
        graphDelegate?.graphDidChange()
        mayDeferUpdate = true
    }

    package final func runTransaction(_ transaction: Transaction? = nil, do body: () -> Void) {
        fatalError("TODO")
    }
    
    package final func runTransaction() {
        fatalError("TODO")
    }
    
    package final var needsTransaction: Bool {
        fatalError("TODO")
    }
    
    package final func startTransactionUpdate() {
        fatalError("TODO")
    }

    package final func finishTransactionUpdate(in subgraph: Subgraph, postUpdate: (_ again: Bool) -> Void = { _ in }) {
        fatalError("TODO")
    }
}

@_spi(ForOpenSwiftUIOnly)
extension GraphHost {
    private static var pendingGlobalTransactions: [GlobalTransaction] = []

    private static func flushGlobalTransactions() {
        fatalError("TODO")
    }
    
    package static func globalTransaction<T>(
        _ transaction: Transaction = .init(),
        id transactionID: Transaction.ID = Transaction.id,
        mutation: T,
        hostProvider: any TransactionHostProvider
    ) where T: GraphMutation {
        fatalError("TODO")
    }
}

@_spi(ForOpenSwiftUIOnly)
extension GraphHost {
    package final func addPreference<K>(_ key: K.Type) where K: HostPreferenceKey {
        Graph.withoutUpdate {
            data.hostPreferenceKeys.add(key)
        }
    }
    
    package final func removePreference<K>(_ key: K.Type) where K: HostPreferenceKey {
        Graph.withoutUpdate {
            data.hostPreferenceKeys.remove(key)
        }
    }
    
    package final func preferenceValues() -> PreferenceList {
        instantiateIfNeeded()
        return hostPreferenceValues.value ?? PreferenceList()
    }
    
    package final func preferenceValue<K>(_ key: K.Type) -> K.Value where K: HostPreferenceKey {
        if data.hostPreferenceKeys.contains(key) {
            return preferenceValues()[key].value
        } else {
            defer { removePreference(key) }
            addPreference(key)
            return preferenceValues()[key].value
        }
    }
    
    package final func updatePreferences() -> Bool {
        let seed = hostPreferenceValues.value?.seed ?? .empty
        let lastSeed = lastHostPreferencesSeed
        let didUpdate = !seed.isInvalid || lastSeed.isInvalid || (seed.value != lastSeed.value)
        lastHostPreferencesSeed = seed
        return didUpdate
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

// MARK: - GraphMutation

package protocol GraphMutation {
    typealias Style = _GraphMutation_Style
    func apply()
    mutating func combine<T>(with other: T) -> Bool where T: GraphMutation
}

package enum _GraphMutation_Style {
    case immediate
    case deferred
}

package struct CustomGraphMutation: GraphMutation {
    let body: () -> Void
    package init(_ body: @escaping () -> Void) {
        self.body = body
    }
    package func apply() { body() }
    package func combine<T>(with other: T) -> Bool where T : GraphMutation { false }
}

#if canImport(Darwin)
struct InvalidatingGraphMutation: GraphMutation {
    let attribute: AnyWeakAttribute
    
    func apply() {
        attribute.attribute?.invalidateValue()
    }
    
    func combine(with mutation: some GraphMutation) -> Bool {
        guard let mutation = mutation as? InvalidatingGraphMutation else {
            return false
        }
        return mutation.attribute == attribute
    }
}
#endif

private struct EmptyGraphMutation: GraphMutation {
    package init() {}
    package func apply() {}
    package func combine<T>(with other: T) -> Bool where T: GraphMutation {
        T.self == EmptyGraphMutation.self
    }
}

// MARK: - TransactionHostProvider [TODO]

package protocol TransactionHostProvider: AnyObject {
    var mutationHost: GraphHost? { get }
}

// MARK: - AsyncTransaction [TODO]

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

// MARK: - GlobalTransaction [TODO]

private final class GlobalTransaction {
    let hostProvider: TransactionHostProvider

    init(transaction _: Transaction, hostProvider: TransactionHostProvider) {
        self.hostProvider = hostProvider
    }
}

// MARK: - Graph + Extension

extension Graph {
    package func graphHost() -> GraphHost {
        unsafeBitCast(context, to: GraphHost.self)
    }
}

// MARK: - Preview

private var blockedGraphHosts: [Unmanaged<GraphHost>] = []
private let waitingForPreviewThunks = EnvironmentHelper.bool(for: "XCODE_RUNNING_FOR_PREVIEWS")

public func __previewThunksHaveFinishedLoading() {
    fatalError("TODO")
}
