internal import OpenGraphShims

public struct _GraphInputs {
    var customInputs: PropertyList
    var time: Attribute<Time>
    var cachedEnvironment: MutableBox<CachedEnvironment>
    var phase: Attribute<_GraphInputs.Phase>
    var transaction: Attribute<Transaction>
    var changedDebugProperties: _ViewDebug.Properties
    var options: _GraphInputs.Options
    #if canImport(Darwin) // FIXME: See #39
    var mergedInputs: Set<OGAttribute>
    #endif
    
    #if canImport(Darwin)
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
    #else // FIXME: See #39
    init(customInputs: PropertyList = PropertyList(),
         time: Attribute<Time>,
         cachedEnvironment: MutableBox<CachedEnvironment>,
         phase: Attribute<Phase>,
         transaction: Attribute<Transaction>,
         changedDebugProperties: _ViewDebug.Properties = [],
         options: _GraphInputs.Options = []/*,
         mergedInputs: Set<OGAttribute> = []*/) {
        self.customInputs = customInputs
        self.time = time
        self.cachedEnvironment = cachedEnvironment
        self.phase = phase
        self.transaction = transaction
        self.changedDebugProperties = changedDebugProperties
        self.options = options
        /* self.mergedInputs = mergedInputs */
    }
    #endif
    
    @inline(__always)
    func detechedEnvironmentInputs() -> Self {
        var newInputs = self
        newInputs.cachedEnvironment = MutableBox(cachedEnvironment.wrappedValue)
        return newInputs
    }
    
    subscript<Input: GraphInput>(_ type: Input.Type) -> Input.Value {
        get { customInputs[type] }
        set { customInputs[type] = newValue }
    }
}

extension _GraphInputs {
    struct Phase: Equatable {
        var value: UInt32
    }
}

extension _GraphInputs {
    struct Options: OptionSet {
        let rawValue: UInt32
    }
}

extension _GraphInputs {
    typealias ConstantID = Int
}
