//
//  FocusStore.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 5347FD43F24C67CC5D552D8EE95E9192 (SwiftUI)

import COpenSwiftUI
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - FocusStoreLocation

class FocusStoreLocation<Value: Hashable>: AnyLocation<Value> {
    var store: FocusStore
    weak var host: GraphHost?
    var resetValue: Value
    var focusSeed: VersionSeed
    var deferredUpdate: (Value, VersionSeed)?
    var resolvedEntry: FocusStore.Entry<Value>?
    var resolvedSeed: VersionSeed
    var _wasRead: Bool

    var id: ObjectIdentifier { ObjectIdentifier(self) }

    override var wasRead: Bool {
        get {
            _wasRead
        }
        set {
            _wasRead = newValue
        }
    }

    override func get() -> Value {
        getValue(forReading: false)
    }

    override func set(_ value: Value, transaction: Transaction) {
        host?.asyncTransaction { [weak self, resetValue] in
            guard let self else { return }
            deferredUpdate = nil
            if value == resetValue {
                if getValue(forReading: false) != resetValue, let entry = resolvedEntry {
                    Update.enqueueAction(reason: nil) {
                        entry.updateFocus(false)
                    }
                }
            } else if let entry = findEntry(with: value) {
                Update.enqueueAction(reason: nil) {
                    entry.updateFocus(true)
                }
            } else {
                deferUpdate(value)
            }
        }
    }

    override init() { _openSwiftUIBaseClassAbstractMethod() }

    init(host: GraphHost, resetValue: Value) {
        self.store = FocusStore()
        self.host = host
        self.resetValue = resetValue
        self.focusSeed = .empty
        self.deferredUpdate = nil
        self.resolvedEntry = nil
        self.resolvedSeed = .empty
        self._wasRead = false
        super.init()
    }

    func getValue(forReading: Bool) -> Value {
        if GraphHost.isUpdating, forReading {
            _wasRead = true
        }
        if resolvedEntry == nil || !store.seed.matches(resolvedSeed) {
            resolvedEntry = findFocusedEntry()
            resolvedSeed = store.seed
        }
        return resolvedEntry?.value ?? resetValue
    }

    func findFocusedEntry() -> FocusStore.Entry<Value>? {
        guard let plist = store.plists[id] else { return nil }
        var result: FocusStore.Entry<Value>?
        var focusedIndex = store.focusedResponders.count
        plist.forEach(keyType: FocusStore.Key<Value>.self) { entry, stop in
            guard let entry, entry.isValid else { return }
            if let responder = entry.responder {
                for (index, focused) in store.focusedResponders.enumerated() {
                    guard focused.base === responder, index < focusedIndex else { continue }
                    result = entry
                    focusedIndex = index
                    stop = index == 0
                    return
                }
            } else if entry.searchFieldState?.wrappedValue.isFocused == true {
                result = entry
                stop = true
            }
        }
        return result
    }

    func findEntry(with value: Value) -> FocusStore.Entry<Value>? {
        guard let plist = store.plists[id] else { return nil }
        var result: FocusStore.Entry<Value>?
        plist.forEach(keyType: FocusStore.Key<Value>.self) { entry, stop in
            guard let entry, entry.isValid, value == entry.value else { return }
            result = entry
            stop = true
        }
        return result
    }

    func deferUpdate(_ value: Value) {
        deferredUpdate = (value, focusSeed)
    }

    override func update() -> (Value, Bool) {
        let oldValue = resolvedEntry?.value ?? resetValue
        let value = getValue(forReading: false)
        return (value, oldValue != value)
    }

    func performDeferredUpdate() {
        if let (value, seed) = deferredUpdate,
           seed.matches(focusSeed) || seed.matches(.empty) {
            set(value, transaction: .current)
        } else {
            deferredUpdate = nil
        }
    }
}

extension FocusStoreLocation: Location {}

// MARK: - FocusStore

struct FocusStore: Equatable {
    var seed: VersionSeed
    var focusedResponders: [WeakBox<ViewResponder>]
    var plists: [ObjectIdentifier: PropertyList]

    init() {
        self.seed = .empty
        self.focusedResponders = []
        self.plists = [:]
    }

    static func == (lhs: FocusStore, rhs: FocusStore) -> Bool {
        lhs.seed.matches(rhs.seed)
    }

    init(_ list: FocusStoreList) {
        self.init()
        makeStoreContent(list)
    }

    private mutating func makeStoreContent(_ list: FocusStoreList) {
        var version = DisplayList.Version()
        for item in list.items {
            version.combine(with: item.version)
        }
        seed = VersionSeed(value: UInt32(version.value))
        for item in list.items {
            var plist = plists[item.propertyID] ?? PropertyList()
            item.storeUpdateAction.update?(&plist)
            plists[item.propertyID] = plist
            if item.isFocused, let responder = item.responder as? ViewResponder {
                focusedResponders.append(WeakBox(responder))
            }
        }
    }
}

// MARK: - FocusStore.Entry

extension FocusStore {
    struct Entry<Value: Hashable> {
        var value: Value
        var focusScopes: [Namespace.ID]
        private var target: Target

        private enum Target {
            case focusResponder(WeakBox<ViewResponder>, WeakBox<FocusBridge>)
            case searchField(Binding<SearchFieldState>)
        }

        init(
            value: Value,
            focusScopes: [Namespace.ID],
            responder: any BaseFocusResponder,
            bridge: FocusBridge
        ) {
            self.init(
                value: value,
                focusScopes: focusScopes,
                target: .focusResponder(WeakBox(responder as? ViewResponder), WeakBox(bridge))
            )
        }

        private init(value: Value, focusScopes: [Namespace.ID], target: Target) {
            self.value = value
            self.focusScopes = focusScopes
            self.target = target
        }

        init(value: Value, focusScopes: [Namespace.ID], searchFieldState: Binding<SearchFieldState>) {
            self.init(value: value, focusScopes: focusScopes, target: .searchField(searchFieldState))
        }

        var responder: (any BaseFocusResponder)? {
            guard case let .focusResponder(responder, _) = target else { return nil }
            return responder.base as? any BaseFocusResponder
        }

        var searchFieldState: Binding<SearchFieldState>? {
            guard case let .searchField(state) = target else { return nil }
            return state
        }

        var isValid: Bool {
            switch target {
            case let .focusResponder(_, bridge):
                bridge.base?.canAcceptFocus ?? false
            case .searchField:
                true
            }
        }

        private var defaultFocusItem: FocusItem? {
            guard case let .focusResponder(responder, bridge) = target,
                  let responder = responder.base as? any BaseFocusResponder
            else { return nil }
            #if os(macOS)
            return bridge.base?.navigator.defaultFocusItem(for: responder)
            #elseif os(iOS) || os(visionOS)
            // Resolve the host's responder graph before visiting the target subtree.
            _ = bridge.base?.host?.responderNode
            var result: FocusItem?
            responder.visitBaseFocusResponders { responder in
                if let responder = responder as? any FocusResponder,
                   responder.focusItem?.isFocusable == true {
                    result = responder.focusItem
                } else if let item = responder.platformItem as? any UIKitHostedContainerFocusItem,
                          item.providesDefaultFocusItems {
                    result = FocusItem(
                        base: .platformItem(WeakBox(item)),
                        prefersFocusSystem: false,
                        responder: nil
                    )
                }
                return result == nil ? .next : .cancel
            }
            return result
            #else
            _openSwiftUIUnimplementedFailure()
            #endif
        }

        fileprivate func updateFocus(_ isFocused: Bool) {
            switch target {
            case let .focusResponder(_, bridge):
                if isFocused {
                    _ = defaultFocusItem.map { item -> Void in
                        bridge.base?.moveFocus(to: item, designatedPlatformResponder: nil)
                    }
                } else {
                    #if os(macOS)
                    bridge.base?.host?.window?.makeFirstResponder(nil)
                    #elseif os(iOS) || os(visionOS)
                    bridge.base?.host?.firstResponder?.resignFirstResponder()
                    #else
                    _openSwiftUIUnimplementedFailure()
                    #endif
                }
            case let .searchField(binding):
                var state = binding.wrappedValue
                state.focusUpdate = SearchFocusUpdate(value: isFocused)
                if isFocused, case .notSearching = state.searchState {
                    state.searchState = .searching(state.hasSuggestions ?? state.hasCustomAccessory ?? false)
                    state.isFocused = true
                }
                binding.wrappedValue = state
            }
        }
    }
}

// MARK: - FocusStoreInputKey

struct FocusStoreInputKey: ViewInput {
    static var defaultValue: OptionalAttribute<FocusStore> {
        .init()
    }
}

// MARK: - FocusStore.Key

extension FocusStore {
    struct Key<V: Hashable>: PropertyKey {
        static var defaultValue: Entry<V>? { nil }
    }
}

// MARK: - Focus Store Inputs

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
