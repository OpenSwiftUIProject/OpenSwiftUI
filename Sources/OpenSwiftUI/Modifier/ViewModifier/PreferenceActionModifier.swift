//
//  PreferenceActionModifier.swift
//  OpenSwiftUI
//
//  Audited for 8.0.66
//  Status: Complete

package import OpenSwiftUICore

@_spi(Private)
@available(OpenSwiftUI_v8_0, *)
extension View {
    /// Adds an action to perform when the specified preference key's value
    /// changes, including the transaction that produced the change.
    nonisolated public func onPreferenceChange<K>(
        _ key: K.Type = K.self,
        action: @escaping @Sendable (K.Value, Transaction) -> Void
    ) -> some View where K: PreferenceKey, K.Value: Equatable {
        return modifier(TransactionalPreferenceActionModifier<K>(action: action))
    }
}
