#if OPENSWIFTUI_ATTRIBUTEGRAPH
internal import AttributeGraph
#else
internal import OpenGraph
#endif

public struct _GraphInputs {
//    var customInputs: PropertyList
    var time: Attribute<Time>
//    var cachedEnvironment: MutableBox<CachedEnvironment>
    var phase: Attribute<Phase>
//    var transaction: Attribute<Transaction>
    var changedDebugProperties: _ViewDebug.Properties
    var options: Options
    // FIXME: Compile crash on Linux
    #if !os(Linux)
    var mergedInputs: Set<OGAttribute>
    #endif
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
