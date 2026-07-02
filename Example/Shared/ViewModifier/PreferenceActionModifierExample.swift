//
//  PreferenceActionModifierExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct MyKey: PreferenceKey {
    static let defaultValue = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

struct PreferenceActionModifierExample: View {
    var body: some View {
        VStack {
            Color.red
                .preference(key: MyKey.self, value: "changed")
        }
        .onPreferenceChange(MyKey.self) {
            print("onPreferenceChange: \($0)")
        }
    }
}
