//
//  View_Preference.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/24.
//  Lastest Version: iOS 15.5
//  Status: WIP

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
