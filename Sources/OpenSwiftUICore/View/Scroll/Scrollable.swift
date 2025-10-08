//
//  Scrollable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 425A368F5B4FB640C2ED9A96D72B5AF3

// MARK: - Scrollable [WIP]

package protocol Scrollable {}

package protocol ScrollableContainer: Scrollable {}

package protocol ScrollableCollection : Scrollable {}

// MARK: ScrollablePreferenceKey

package struct ScrollablePreferenceKey: PreferenceKey {
    package typealias Value = [any Scrollable]

    package static let defaultValue: Value = []

    package static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

extension PreferencesInputs {
    @inline(__always)
    package var requiresScrollable: Bool {
        get {
            contains(ScrollablePreferenceKey.self)
        }
        set {
            if newValue {
                add(ScrollablePreferenceKey.self)
            } else {
                remove(ScrollablePreferenceKey.self)
            }
        }
    }
}
