internal import OpenGraphShims

public struct _GraphInputs {
    var customInputs: PropertyList
    var time: Attribute<Time>
    var cachedEnvironment: MutableBox<CachedEnvironment>
    var phase: Attribute<_GraphInputs.Phase>
    var transaction: Attribute<Transaction>
    var changedDebugProperties: _ViewDebug.Properties
    var options: _GraphInputs.Options
    // FIXME: Compile crash on Linux
    // https://github.com/apple/swift/issues/71086
    #if canImport(Darwin)
    var mergedInputs: Set<OGAttribute>
    #endif
    
    subscript<Input: GraphInput>(_ type: Input.Type) -> Input.Value {
        get { customInputs[type] }
        set { customInputs[type] = newValue }
    }
}

extension _GraphInputs {
    struct Phase: Equatable {
        let value: UInt32
    }
}

extension _GraphInputs {
    struct Options: OptionSet {
        let rawValue: UInt32
    }
}
