//
//  TransactionalPreferenceActionModifierExample.swift
//  Shared

#if OPENSWIFTUI
@_spi(Private) import OpenSwiftUI
#else
import SwiftUI_SPI
#endif

#if OPENSWIFTUI
@available(OpenSwiftUI_v8_0, *)
#else
@available(iOS 18.2, macOS 15.2, *)
#endif
struct TransactionalPreferenceActionExample: View {
    private struct Key: PreferenceKey {
        static let defaultValue = ""

        static func reduce(value: inout String, nextValue: () -> String) {
            value = nextValue()
        }
    }

    var action: @Sendable (String, Transaction) -> Void

    var body: some View {
        Color.red
            .preference(key: Key.self, value: "changed")
            .onPreferenceChange(Key.self) { value, transaction in
                action(value, transaction)
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
    }
}
