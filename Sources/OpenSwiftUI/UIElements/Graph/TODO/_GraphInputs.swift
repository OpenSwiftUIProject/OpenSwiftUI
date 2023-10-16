#if OPENSWIFTUI_USE_AG
@_implementationOnly import AttributeGraph
#else
@_implementationOnly import OpenGraph
#endif

public struct _GraphInputs {
//    var customInputs: PropertyList
    var time: Attribute<Time>
//    var cachedEnvironment: MutableBox<CachedEnvironment>
    var phase: Attribute<Phase>
//    var transaction: Attribute<Transaction>
    var changedDebugProperties: _ViewDebug.Properties
    var options: Options
    var mergedInputs: Set<OGAttribute>
}

extension _GraphInputs {
    struct Phase {
        let value: UInt32
    }
}

extension _GraphInputs {
    struct Options: OptionSet {
        let rawValue: UInt32
    }
}
