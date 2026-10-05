//
//  FocusStoreList.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore

// MARK: - FocusStoreList

struct FocusStoreList: Equatable {
    var items: [Item] = []

    struct Key: HostPreferenceKey {
        static var defaultValue: FocusStoreList { .init() }

        static func reduce(value: inout FocusStoreList, nextValue: () -> FocusStoreList) {
            value.append(contentsOf: nextValue())
        }
    }

    struct Item {
        var version: DisplayList.Version
        var propertyID: ObjectIdentifier
        var bindingUpdateAction: FocusStateBindingUpdateAction
        var storeUpdateAction: FocusStoreUpdateAction
        weak var responder: ResponderNode?
        weak var bridge: FocusBridge?
        var isFocused: Bool
    }

    static func == (lhs: FocusStoreList, rhs: FocusStoreList) -> Bool {
        let lhsVersion = lhs.items.reduce(into: DisplayList.Version()) {
            $0.combine(with: $1.version)
        }
        let rhsVersion = rhs.items.reduce(into: DisplayList.Version()) {
            $0.combine(with: $1.version)
        }
        return lhsVersion == rhsVersion
    }
}

// MARK: - FocusStoreList + Collection

extension FocusStoreList: Collection {
    var startIndex: Int { items.startIndex }

    var endIndex: Int { items.endIndex }

    subscript(index: Int) -> Item {
        _read { yield items[index] }
    }

    func index(after index: Int) -> Int {
        index + 1
    }
}

// MARK: - FocusStoreList + RangeReplaceableCollection

extension FocusStoreList: RangeReplaceableCollection {
    mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C)
    where C: Collection, C.Element == Item {
        items.replaceSubrange(subrange, with: newElements)
    }
}

// MARK: - FocusStoreUpdateAction

struct FocusStoreUpdateAction {
    let update: ((inout PropertyList) -> Void)?

    init<Value: Hashable>(
        value: Value,
        responder: any BaseFocusResponder,
        bridge: FocusBridge?,
        focusScopes: [Namespace.ID]
    ) {
        update = { [weak responder, weak bridge] plist in
            guard let responder, let bridge else { return }
            plist[FocusStore.Key<Value>.self] = .init(
                value: value,
                focusScopes: focusScopes,
                responder: responder,
                bridge: bridge
            )
        }
    }

    init<Value: Hashable>(
        value: Value,
        focusScopes: [Namespace.ID],
        searchFieldState: Binding<SearchFieldState>
    ) {
        update = { plist in
            plist[FocusStore.Key<Value>.self] = .init(
                value: value,
                focusScopes: focusScopes,
                searchFieldState: searchFieldState
            )
        }
    }
}

// MARK: - FocusStateBindingUpdateAction

struct FocusStateBindingUpdateAction {
    let update: () -> Void

    init<Value: Hashable>(binding: FocusState<Value>.Binding, value: Value) {
        update = { binding.wrappedValue = value }
    }
}
