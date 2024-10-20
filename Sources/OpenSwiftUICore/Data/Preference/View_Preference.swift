//
//  View_Preference.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: 6C396F98EFDD04A6B58F2F9112448013

extension View {
    /// Sets a value for the given preference.
    @inlinable
    public func preference<K>(key: K.Type = K.self, value: K.Value) -> some View where K : PreferenceKey {
        modifier(_PreferenceWritingModifier<K>(value: value))
    }
}


extension View {
    /// Applies a transformation to a preference value.
    @inlinable
    public func transformPreference<K>(_ key: K.Type = K.self, _ callback: @escaping (inout K.Value) -> Void) -> some View where K : PreferenceKey {
        modifier(_PreferenceTransformModifier<K>(transform: callback))
    }
}
