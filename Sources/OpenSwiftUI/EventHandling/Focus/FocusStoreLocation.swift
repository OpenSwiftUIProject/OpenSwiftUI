class FocusStoreLocation<A: Hashable>/*: Location*/ {
    init() { fatalError() }
    
    var store: FocusStore
    weak var host: GraphHost?
    var resetValue: A
    var focusSeed: VersionSeed
    var failedAssignment: (A, VersionSeed)?
    var resolvedEntry: FocusStore.Entry<A>?
    var resolvedSeed: VersionSeed
    var _wasRead: Bool
    
    var id: ObjectIdentifier { ObjectIdentifier(self) }
}
