//
//  GraphHost.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 30C09FF16BC95EC5173809B57186CAC3 (SwiftUI)
//  ID: F9F204BD2F8DB167A76F17F3FB1B3335 (SwiftUICore)

import OpenSwiftUI_SPI
package import OpenAttributeGraphShims
import Foundation
import Synchronization

// MARK: - GraphDelegate

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public protocol GraphDelegate: AnyObject {
    func updateGraph<T>(body: (GraphHost) -> T) -> T
    func graphDidChange()
    func preferencesDidChange()
    func beginTransaction()
}

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
extension GraphDelegate {
    public func beginTransaction() {
        onMainThread { [weak self] in
            RunLoop.addObserver {
                Update.ensure {
                    guard let self else { return }
                    self.updateGraph { host in
                        host.flushTransactions()
                    }
                }
            }
        }
    }
}

// MARK: - GraphHost

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
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
            let oldCurrent = Subgraph.current
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
            let rootSubgraph = Subgraph(graph: graph)
            globalSubgraph.addChild(rootSubgraph)
            Subgraph.current = oldCurrent
            self.graph = graph
            self.globalSubgraph = globalSubgraph
            self.rootSubgraph = rootSubgraph
            self.isRemoved = false
            self.isHiddenForReuse = false
            self._time = time
            self._environment = environment
            self._phase = phase
            self._hostPreferenceKeys = hostPreferenceKeys
            self._transaction = transaction
            self._updateSeed = updateSeed
            self._transactionSeed = transactionSeed
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
    package final var hostPreferenceValues: WeakAttribute<PreferenceValues> = WeakAttribute()
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
        if let currentAttribute = AnyAttribute.current {
            currentAttribute.graph.graphHost()
        } else if let currentSubgraph = Subgraph.current {
            currentSubgraph.graph.graphHost()
        } else {
            preconditionFailure("no current graph host")
        }
    }
    
    package init(data: Data) {
        mainThreadPrecondition()
        self.data = data
        graph.onUpdate { [weak self] in
            guard let self,
                  let graphDelegate
            else { return }
            graphDelegate.updateGraph { _ in }
        }
        graph.onInvalidation { [weak self] attribute in
            guard let self else { return }
            graphInvalidation(from: attribute)
        }
        graph.context = address(of: self)
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
        data.invalidate()
    }
    
    package static var isUpdating: Bool {
        sharedGraph.counter(for: .threadUpdating) != 0
    }
    
    package final var isUpdating: Bool {
        guard isValid else { return false }
        return graph.counter(for: .contextThreadUpdating) != 0
    }
    
    package final func setNeedsUpdate(mayDeferUpdate: Bool, values: ViewRendererHostProperties) {
        self.mayDeferUpdate = self.mayDeferUpdate && mayDeferUpdate
        if let graph = data.graph {
            CustomEventTrace.setNeedsUpdate(values: values)
            graph.setNeedsUpdate()
        }
    }

    // MARK: - GraphHost.ConstantID
    
    package enum ConstantID: Int8, Hashable {
        case defaultValue
        case implicitViewRoot
        case trueValue
        case defaultValue3D
        case failedValue
        case placeholder
        case preferenceKeyDefault
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
    open func instantiateOutputs() { _openSwiftUIEmptyStub() }
    open func uninstantiateOutputs() { _openSwiftUIEmptyStub() }
    open func timeDidChange() { _openSwiftUIEmptyStub() }
    open func isHiddenForReuseDidChange() { _openSwiftUIEmptyStub() }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension GraphHost: Sendable {}

@_spi(ForOpenSwiftUIOnly)
extension GraphHost {
    package final func graphInvalidation(from src: AnyAttribute?) {
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
    }
    
    package final func instantiate() {
        guard !isInstantiated else {
            return
        }
        graphDelegate?.updateGraph { _ in
            _openSwiftUIEmptyStub()
        }
        instantiateOutputs()
        isInstantiated = true
    }
    
    package final func uninstantiate(immediately: Bool) {
        guard isInstantiated else {
            return
        }
        data.inputs.resetCaches()
        uninstantiateOutputs()
        rootSubgraph.willRemove()
        if !data.isRemoved {
            globalSubgraph.removeChild(rootSubgraph)
        }
        rootSubgraph.willInvalidate(isInserted: false)
        if immediately {
            rootSubgraph.invalidate()
        } else {
            Update.enqueueAction(reason: nil) { [rootSubgraph] in
                rootSubgraph.invalidate()
            }
        }
        data.rootSubgraph = Subgraph(graph: graph)
        if !data.isRemoved {
            globalSubgraph.addChild(rootSubgraph)
        }
        isInstantiated = false
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
    
    package final func incrementPhase() {
        data.phase.resetSeed.unsafeIncrement()
        graphDelegate?.graphDidChange()
    }
    
    package final func updateRemovedState() {
        let isRemoved: Bool
        let removedState: RemovedState
        
        if self.removedState.isEmpty {
            if let parentHost {
                let state = parentHost.removedState
                isRemoved = state.contains(.hiddenForReuse)
                removedState = state
            } else {
                isRemoved = false
                removedState = []
            }
        } else {
            isRemoved = true
            removedState = self.removedState
        }
        let isHiddenForReuse = removedState.contains(.hiddenForReuse)
        
        if isRemoved != data.isRemoved {
            if isRemoved {
                rootSubgraph.willRemove()
                globalSubgraph.removeChild(rootSubgraph)
            } else {
                globalSubgraph.addChild(rootSubgraph)
                rootSubgraph.didReinsert()
            }
            data.isRemoved = isRemoved
        }
        if isHiddenForReuse != data.isHiddenForReuse {
            data.isHiddenForReuse = isHiddenForReuse
            isHiddenForReuseDidChange()
        }
    }
    
    // MARK: - GraphHost + Transaction
    
    @discardableResult
    package final func asyncTransaction<T>(
        _ transaction: Transaction = .init(),
        id transactionID: Transaction.ID = Transaction.id,
        mutation: T,
        style: GraphMutation.Style = .deferred,
        mayDeferUpdate: Bool = true
    ) -> UInt32 where T: GraphMutation {
        Update.locked {
            guard isValid else {
                return 0
            }
            let shouldDeferUpdate = switch style {
                case .immediate: isUpdating
                case .deferred: true
            }
            self.mayDeferUpdate = self.mayDeferUpdate && mayDeferUpdate
            if hasPendingTransactions {
                let count = pendingTransactions.count
                if pendingTransactions[count-1].transactionID == transactionID,
                   pendingTransactions[count-1].transaction.mayConcatenate(with: transaction) {
                    pendingTransactions[count-1].append(mutation)
                    CustomEventTrace.transactionAppend(to: pendingTransactions[count-1].traceID)
                    if !shouldDeferUpdate {
                        let lastTransaction = pendingTransactions.removeLast()
                        flushTransactions()
                        pendingTransactions.append(lastTransaction)
                    }
                    return pendingTransactions.last?.traceID ?? 0
                }
                if !shouldDeferUpdate {
                    flushTransactions()
                }
            } else {
                graphDelegate?.beginTransaction()
            }
            let asyncTransaction = AsyncTransaction(
                transaction: transaction,
                transactionID: transactionID,
                mutations: [mutation]
            )
            CustomEventTrace.transactionEnqueue(asyncTransaction.traceID)
            pendingTransactions.append(asyncTransaction)
            return asyncTransaction.traceID
        }
    }
    
    @discardableResult
    package final func asyncTransaction(
        _ transaction: Transaction = .init(),
        id transactionID: Transaction.ID = Transaction.id,
        _ body: @escaping () -> Void
    ) -> UInt32 {
        asyncTransaction(
            transaction,
            id: transactionID,
            mutation: CustomGraphMutation(body)
        )
    }
    
    @discardableResult
    package final func asyncTransaction<T>(
        _ transaction: Transaction = .init(),
        id transactionID: Transaction.ID = Transaction.id,
        invalidating attribute: WeakAttribute<T>,
        style: GraphMutation.Style = .deferred,
        mayDeferUpdate: Bool = true
    ) -> UInt32 {
        asyncTransaction(
            transaction,
            id: transactionID,
            mutation: InvalidatingGraphMutation(attribute: .init(attribute)),
            style: style,
            mayDeferUpdate: mayDeferUpdate
        )
    }
    
    @discardableResult
    package final func emptyTransaction(_ transaction: Transaction = .init()) -> UInt32 {
        asyncTransaction(transaction, mutation: EmptyGraphMutation())
    }

    package final func continueTransaction(_ body: @escaping () -> Void) {
        Update.assertIsLocked()
        var host = self
        while !host.inTransaction {
            guard let parent = host.parentHost else {
                Update.enqueueAction(reason: nil) {
                    let id = host.asyncTransaction { body() }
                    CustomEventTrace.transactionContinueAsNewTransaction(id)
                }
                return
            }
            host = parent
        }
        CustomEventTrace.transactionContinueAsContinuation(host)
        host.continuations.append(body)
    }
    
    package final var hasPendingTransactions: Bool {
        !pendingTransactions.isEmpty
    }

    package final func flushTransactions() {
        guard isValid, hasPendingTransactions else {
            return
        }
        let oldPendingTransactions = pendingTransactions
        pendingTransactions = []
        for pendingTransaction in oldPendingTransactions {
            let transaction = pendingTransaction.transaction
            let mutations = pendingTransaction.mutations
            runTransaction(transaction, do: {
                withTransaction(transaction) {
                    for mutation in mutations {
                        mutation.apply()
                    }
                }
            }, id: pendingTransaction.traceID)
        }
        graphDelegate?.graphDidChange()
        mayDeferUpdate = true
    }

    package final func runTransaction(
        _ transaction: Transaction? = nil,
        do body: () -> Void,
        id: UInt32? = nil
    ) {
        instantiateIfNeeded()
        if let transaction, !transaction.isEmpty {
            data.transaction = transaction
        }
        startTransactionUpdate(id: id)
        body()
        finishTransactionUpdate(in: globalSubgraph, id: id)
        if let transaction, !transaction.isEmpty {
            data.transaction = .init()
        }
    }
    
    package final func runTransaction() {
        runTransaction(nil, do: {}, id: nil)
    }
    
    package final var needsTransaction: Bool {
        globalSubgraph.isDirty(flags: .transactional)
    }
    
    package final func startTransactionUpdate(
        id: UInt32? = nil
    ) {
        inTransaction = true
        if let id {
            CustomEventTrace.transactionBegin(id)
        }
        data.transactionSeed.unsafeIncrement()
    }

    package final func finishTransactionUpdate(
        in subgraph: Subgraph,
        postUpdate: (_ again: Bool) -> Void = { _ in },
        id: UInt32? = nil
    ) {
        var counter = 0
        repeat {
            let oldContinuations = continuations
            continuations = []
            for continuation in oldContinuations {
                continuation()
            }
            counter &+= 1
            subgraph.update(flags: .transactional)
            postUpdate(!continuations.isEmpty)
        } while counter != 8 && !continuations.isEmpty
        if let id {
            CustomEventTrace.transactionEnd(id)
        }
        inTransaction = false
    }
}

@_spi(ForOpenSwiftUIOnly)
extension GraphHost {
    private static var pendingGlobalTransactions: [GlobalTransaction] = []

    private static func flushGlobalTransactions() {
        guard !pendingGlobalTransactions.isEmpty else { return }
        let transactions = pendingGlobalTransactions
        pendingGlobalTransactions = []
        for transaction in transactions {
            let base = transaction.base
            if let host = transaction.hostProvider.mutationHost {
                host.runTransaction(base.transaction, do: base.apply, id: base.traceID)
                host.graphDelegate?.graphDidChange()
            } else {
                base.apply()
            }
        }
    }
    
    package static func globalTransaction<T>(
        _ transaction: Transaction = .init(),
        id transactionID: Transaction.ID = Transaction.id,
        mutation: T,
        hostProvider: any TransactionHostProvider
    ) where T: GraphMutation {
        Update.locked {
            let count = pendingGlobalTransactions.count
            if count != 0 {
                let didAppend = withUnsafeMutablePointer(to: &pendingGlobalTransactions[count - 1]) { last in
                    guard last.pointee.hostProvider === hostProvider,
                          last.pointee.base.transactionID == transactionID,
                          last.pointee.base.transaction.mayConcatenate(with: transaction)
                    else { return false }
                    last.pointee.base.append(mutation)
                    return true
                }
                if didAppend { return }
            }
            if count == 0 {
                onMainThread {
                    RunLoop.addObserver(flushGlobalTransactions)
                }
            }
            let base = AsyncTransaction(
                transaction: transaction,
                transactionID: transactionID,
                mutations: [mutation]
            )
            pendingGlobalTransactions.append(GlobalTransaction(hostProvider: hostProvider, base: base))
        }
    }
}

// MARK: GraphHost + preference

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
    
    package final func preferenceValues() -> PreferenceValues {
        instantiateIfNeeded()
        return hostPreferenceValues.value ?? PreferenceValues()
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
        let didUpdate = !seed.matches(lastHostPreferencesSeed)
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

// MARK: GraphMutation.Style

package enum _GraphMutation_Style {
    case immediate
    case deferred
}

// MARK: - CustomGraphMutation

package struct CustomGraphMutation: GraphMutation {
    let body: () -> Void
    package init(_ body: @escaping () -> Void) {
        self.body = body
    }
    package func apply() { body() }
    package func combine<T>(with other: T) -> Bool where T: GraphMutation { false }
}

// MARK: - InvalidatingGraphMutation

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

// MARK: - EmptyGraphMutation

private struct EmptyGraphMutation: GraphMutation {
    package init() {}
    package func apply() {}
    package func combine<T>(with other: T) -> Bool where T: GraphMutation {
        T.self == EmptyGraphMutation.self
    }
}

// MARK: - TransactionHostProvider

package protocol TransactionHostProvider: AnyObject {
    var mutationHost: GraphHost? { get }
}

// MARK: - AsyncTransaction

private struct AsyncTransaction {
    let transaction: Transaction

    let transactionID: Transaction.ID

    let traceID: UInt32

    var mutations: [GraphMutation]

    private static var nextTraceID: UInt32 = 1

    init(transaction: Transaction, transactionID: Transaction.ID, mutations: [GraphMutation]) {
        self.transaction = transaction
        self.transactionID = transactionID
        let oldValue = withUnsafeMutablePointer(to: &Self.nextTraceID) { pointer in
            pointer.withMemoryRebound(to: Atomic<UInt32>.self, capacity: 1) { atomic in
                atomic.pointee.wrappingAdd(2, ordering: .relaxed).oldValue
            }
        }
        let nextValue = UInt32(Int64(Int32(bitPattern: oldValue)) + 2)
        self.traceID = nextValue / 2 + 1
        self.mutations = mutations
    }

    mutating func append<T>(_ mutation: T) where T: GraphMutation {
        // NOTE: use ``Array.subscript/_modify`` instead of ``Array.last/getter`` to mutate inline
        guard mutations.isEmpty || !mutations[mutations.count - 1].combine(with: mutation) else {
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

private struct GlobalTransaction {
    let hostProvider: TransactionHostProvider
    var base: AsyncTransaction
}

// MARK: - Graph + GraphHost

extension Graph {
    package func graphHost() -> GraphHost {
        Unmanaged<GraphHost>.fromOpaque(context!).takeUnretainedValue()
    }
}

// MARK: - Preview

private var blockedGraphHosts: [Unmanaged<GraphHost>] = []
// NOTE: In SwiftUI, PreviewsInjection.framework's DYLDDynamicProductLoader calls
// SwiftUI.__previewThunksHaveFinishedLoading() via a library-specific GOT binding after
// all preview dylibs are dlopen'd. This unblocks graph instantiation for waiting hosts.
// Since the binding targets SwiftUI specifically (two-level namespace), OpenSwiftUI's
// version is never called. We disable the blocking to allow graph instantiation in Preview.
// TODO: Re-enable when OpenSwiftUI implements its own preview thunk registration system.
private var waitingForPreviewThunks = false // EnvironmentHelper.bool(for: "XCODE_RUNNING_FOR_PREVIEWS")

@available(OpenSwiftUI_v1_0, *)
public func __previewThunksHaveFinishedLoading() {
    guard waitingForPreviewThunks else { return }
    waitingForPreviewThunks = false
    let hosts = blockedGraphHosts
    blockedGraphHosts = []
    for host in hosts {
        let graphHost = host.takeUnretainedValue()
        if let graphDelegate = graphHost.graphDelegate {
            graphDelegate.graphDidChange()
        }
    }
}
