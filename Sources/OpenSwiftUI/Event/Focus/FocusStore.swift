@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

package struct FocusStore {
    package var seed: VersionSeed
    package var focusedResponders: [WeakBox<ResponderNode>]
    package var plists: [ObjectIdentifier: PropertyList]

    package init() {
        self.seed = .empty
        self.focusedResponders = []
        self.plists = [:]
    }
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
