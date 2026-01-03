//
//  PlatformItemList.swift
//  OpenSwiftUI
//
//  Status: Empty
//  ID: CE84B1BFBEAEAB6361605407E54625A3 (SwiftUI)

// FIXME
package struct PlatformItemList {
    var itesms: [Item]

    // FIXME
    struct Item {}

    fileprivate struct Key: PreferenceKey {
        static let defaultValue: PlatformItemList = .init(itesms: [])

        static func reduce(value: inout PlatformItemList, nextValue: () -> PlatformItemList) {
            value.itesms.append(contentsOf: nextValue().itesms)
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
