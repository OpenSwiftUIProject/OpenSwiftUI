// TODO & WIP

internal import OpenGraphShims

class GraphHost {
    
//    var data: Data
//    var isInstantiated: Swift.Bool
//    var hostPreferenceValues: OptionalAttribute<PreferenceList>
//    var lastHostPreferencesSeed: VersionSeed
//    var pendingTransactions: [SwiftUI.(AsyncTransaction in _30C09FF16BC95EC5173809B57186CAC3)]
//    var inTransaction: Bool
//    var continuations: [() -> ()]
//    var mayDeferUpdate: Bool
//    var removedState: RemovedState
    
    static var isUpdating = false

    
//    private static let shared = OGGraphCreate()
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
    }
}

// MARK: - GraphHost.RemovedState

extension GraphHost {
    // TODO
    struct RemovedState: OptionSet {
        let rawValue: UInt8
    }
}
