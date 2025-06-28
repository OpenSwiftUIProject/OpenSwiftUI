@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

struct FocusStore {
    var seed: VersionSeed
    var focusedResponders: ContiguousArray<ResponderNode>
    var plists: [ObjectIdentifier : PropertyList]
}

// MARK: - FocusStore.Key

extension FocusStore {
    struct Key<V: Hashable>: PropertyKey {
        static var defaultValue: Entry<V>? { nil }
    }
}

// MARK: - FocusStore.Item
extension FocusStore {
    struct Entry<Value: Hashable> {
        
    }
}
