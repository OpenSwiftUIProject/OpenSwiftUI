@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

class FocusStoreLocation<A: Hashable>: AnyLocation<A>, @unchecked Sendable {
    override var wasRead: Bool {
        get {
            _wasRead
        }
        set {
            _wasRead = newValue
        }
    }
    
    override func get() -> A {
        openSwiftUIUnimplementedFailure()
    }
    
    override func set(_ value: A, transaction: Transaction) {
        openSwiftUIUnimplementedFailure()
    }
    
    typealias Value = A
    
    override init() { openSwiftUIBaseClassAbstractMethod() }
    
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
