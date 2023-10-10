//
//  File.swift
//  
//
//  Created by Kyle on 2023/10/11.
//

import Foundation

extension View {
    /// Sets a value for the given preference.
    @inlinable
    public func preference<K>(key: K.Type = K.self, value: K.Value) -> some View where K : PreferenceKey {
        self
    }
}


extension View {
    /// Applies a transformation to a preference value.
    @inlinable
    public func transformPreference<K>(_ key: K.Type = K.self, _ callback: @escaping (inout K.Value) -> Void) -> some View where K : PreferenceKey {
        self
    }

}
