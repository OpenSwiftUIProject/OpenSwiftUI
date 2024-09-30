//@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
//
//internal import OpenGraphShims
//
//public struct _GraphInputs {
//    var customInputs: PropertyList
//    var time: Attribute<Time>
//    var cachedEnvironment: MutableBox<CachedEnvironment>
//    var phase: Attribute<_GraphInputs.Phase>
//    var transaction: Attribute<Transaction>
//    private var changedDebugProperties: _ViewDebug.Properties
//    private var options: _GraphInputs.Options
//    #if canImport(Darwin) // FIXME: See #39
//    var mergedInputs: Set<OGAttribute>
//    #endif
//    
//    #if canImport(Darwin)
//    init(customInputs: PropertyList = PropertyList(),
//         time: Attribute<Time>,
//         cachedEnvironment: MutableBox<CachedEnvironment>,
//         phase: Attribute<Phase>,
//         transaction: Attribute<Transaction>,
//         changedDebugProperties: _ViewDebug.Properties = [],
//         options: _GraphInputs.Options = [],
//         mergedInputs: Set<OGAttribute> = []) {
//        self.customInputs = customInputs
//        self.time = time
//        self.cachedEnvironment = cachedEnvironment
//        self.phase = phase
//        self.transaction = transaction
//        self.changedDebugProperties = changedDebugProperties
//        self.options = options
//        self.mergedInputs = mergedInputs
//    }
//    #else // FIXME: See #39
//    init(customInputs: PropertyList = PropertyList(),
//         time: Attribute<Time>,
//         cachedEnvironment: MutableBox<CachedEnvironment>,
//         phase: Attribute<Phase>,
//         transaction: Attribute<Transaction>,
//         changedDebugProperties: _ViewDebug.Properties = [],
//         options: _GraphInputs.Options = []/*,
//         mergedInputs: Set<OGAttribute> = []*/) {
//        self.customInputs = customInputs
//        self.time = time
//        self.cachedEnvironment = cachedEnvironment
//        self.phase = phase
//        self.transaction = transaction
//        self.changedDebugProperties = changedDebugProperties
//        self.options = options
//        /* self.mergedInputs = mergedInputs */
//    }
//    #endif
//    
//    subscript<Input: GraphInput>(_ type: Input.Type) -> Input.Value {
//        get { customInputs[type] }
//        set { customInputs[type] = newValue }
//    }
//    
//    // MARK: - cachedEnvironment
//    
//    @inline(__always)
//    func detechedEnvironmentInputs() -> Self {
//        var newInputs = self
//        newInputs.cachedEnvironment = MutableBox(cachedEnvironment.wrappedValue)
//        return newInputs
//    }
//    
//    @inline(__always)
//    mutating func updateCachedEnvironment(_ box: MutableBox<CachedEnvironment>) {
//        cachedEnvironment = box
//        changedDebugProperties.insert(.environment)
//    }
//    
//    // MARK: - changedDebugProperties
//    
//    @inline(__always)
//    func withEmptyChangedDebugPropertiesInputs<R>(_ body: (_GraphInputs) -> R) -> R {
//        var inputs = self
//        inputs.changedDebugProperties = []
//        return body(inputs)
//    }
//    
//    // MARK: - options
//    
//    @inline(__always)
//    var enableLayout: Bool {
//        get { options.contains(.enableLayout) }
//        // TODO: setter
//    }
//}
//
//extension _GraphInputs {
//    struct Phase: Equatable {
//        var value: UInt32
//        
//        @inline(__always)
//        var seed: UInt32 {
//            get { value >> 1 }
//            // TODO
//            // set
//        }
//    }
//}
//
//extension _GraphInputs {
//    struct Options: OptionSet {
//        let rawValue: UInt32
//        
//        static var enableLayout: Options { Options(rawValue: 1 << 1) }
//    }
//}
//
//extension _GraphInputs {
//    typealias ConstantID = Int
//    
//    func intern<Value>(_ value: Value, id: ConstantID) -> Attribute<Value> {
//        cachedEnvironment.wrappedValue.intern(value, id: id.internID)
//    }
//}
//
//extension _GraphInputs.ConstantID {
//    @inline(__always)
//    var internID: Self { self & 0x1 }
//}
