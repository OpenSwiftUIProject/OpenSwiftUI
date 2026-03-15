//
//  PlatformItemList.swift
//  OpenSwiftUI
//
//  Status: Empty
//  ID: CE84B1BFBEAEAB6361605407E54625A3 (SwiftUI)

import Foundation

// FIXME
package struct PlatformItemList {
    var items: [Item]

    // FIXME
    struct Item {
        var text: NSAttributedString?
        var secondaryText: NSAttributedString?
        var platformIdentifier: String?
        var isExternal: Bool = false
        var hierarchicalLevel: Int = 0
        // var imageColorResolver: mageColorResolver?
        var isEnabled: Bool = false
        var resolvedImage: Image.Resolved?
        var namedResolvedImage: Image.NamedResolved?
        // TODO
        var label: NSAttributedString?
        var tooltip: String?
        var badge: String?
        // TODO
    }

    var mergedContentItems: Item {
        // FIXME
        .init()
    }

    fileprivate struct Key: PreferenceKey {
        static let defaultValue: PlatformItemList = .init(items: [])

        static func reduce(value: inout PlatformItemList, nextValue: () -> PlatformItemList) {
            value.items.append(contentsOf: nextValue().items)
        }
    }
}

extension PreferencesInputs {
    @inline(__always)
    var requiresPlatformItemList: Bool {
        get {
            contains(PlatformItemList.Key.self)
        }
        set {
            if newValue {
                add(PlatformItemList.Key.self)
            } else {
                remove(PlatformItemList.Key.self)
            }
        }
    }
}

// MARK: - PlatformItemListSpacerRepresentable [6.5.4] [WIP]

struct PlatformItemListSpacerRepresentable: PlatformSpacerRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool {
        guard inputs.preferences.requiresPlatformItemList else {
            return false
        }
        return inputs[PlatformItemListFlagsInput.self].contains(.init(rawValue: 1 << 3)) // FIXME
    }
    
    static func makeRepresentation(inputs: _ViewInputs, outputs: inout _ViewOutputs) {
        // outputs.preferences.makePreferenceWriter
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: PlatformItemListFlagsInput [WIP]

struct PlatformItemListFlagsInput: ViewInput {
    static var defaultValue: PlatformItemListFlagsSet = []
}

struct PlatformItemListFlagsSet: OptionSet {
    var rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}
