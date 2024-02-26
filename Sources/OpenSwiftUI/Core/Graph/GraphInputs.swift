internal import OpenGraphShims

// FIXME: Compile crash on non-Darwin platform
// https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/39
#if !canImport(Darwin)
typealias OGAttribute = UInt32
#endif

public struct _GraphInputs {
    var customInputs: PropertyList
    var time: Attribute<Time>
    var cachedEnvironment: MutableBox<CachedEnvironment>
    var phase: Attribute<_GraphInputs.Phase>
    var transaction: Attribute<Transaction>
    var changedDebugProperties: _ViewDebug.Properties
    var options: _GraphInputs.Options
    var mergedInputs: Set<OGAttribute>
    
    init(customInputs: PropertyList = PropertyList(),
         time: Attribute<Time>,
         cachedEnvironment: MutableBox<CachedEnvironment>,
         phase: Attribute<Phase>,
         transaction: Attribute<Transaction>,
         changedDebugProperties: _ViewDebug.Properties = [],
         options: _GraphInputs.Options = [],
         mergedInputs: Set<OGAttribute> = []) {
        self.customInputs = customInputs
        self.time = time
        self.cachedEnvironment = cachedEnvironment
        self.phase = phase
        self.transaction = transaction
        self.changedDebugProperties = changedDebugProperties
        self.options = options
        self.mergedInputs = mergedInputs
    }
    
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
