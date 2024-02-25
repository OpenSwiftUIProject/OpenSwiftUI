// TODO & WIP

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
    
    //    private static let shared = OGGraphCreate()

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
        var isRemoved: Bool
        var isHiddenForReuse: Bool
        @Attribute
        var time: Time
        @Attribute
        var environment: EnvironmentValues
        @Attribute
        var phase: _GraphInputs.Phase
        @Attribute
        var hostPreferenceKeys: PreferenceKeys
        @Attribute
        var transaction: Transaction
        var inputs: _GraphInputs
        
        init() {
            fatalError("TODO")
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
