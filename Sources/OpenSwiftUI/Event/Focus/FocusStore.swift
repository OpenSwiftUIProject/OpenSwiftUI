import OpenAttributeGraphShims
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

struct FocusStoreInputKey: ViewInput {
    static var defaultValue: OptionalAttribute<FocusStore> {
        .init()
    }
}

extension _ViewInputs {
    var focusStore: Attribute<FocusStore>? {
        get { base.focusStore }
        set { base.focusStore = newValue }
    }
}

extension _GraphInputs {
    var focusStore: Attribute<FocusStore>? {
        get { self[FocusStoreInputKey.self].attribute }
        set { self[FocusStoreInputKey.self] = .init(newValue) }
    }
}
