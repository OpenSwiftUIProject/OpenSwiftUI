//
//  PreferenceActionModifierExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct PreferenceActionModifierExample: View {
    private struct Key: PreferenceKey {
        static let defaultValue = ""

        static func reduce(value: inout String, nextValue: () -> String) {
            value = nextValue()
        }
    }

    var action: (String) -> Void

    var body: some View {
        Color.red
            .preference(key: Key.self, value: "changed")
            .onPreferenceChange(Key.self, perform: action)
    }
}
