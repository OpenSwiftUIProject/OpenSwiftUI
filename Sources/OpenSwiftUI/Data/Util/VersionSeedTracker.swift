//
//  VersionSeedTracker.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3F0A9C8FE1DF482BB97A7ECFF3793F1B (SwiftUI)

@_spi(Private)
package import OpenSwiftUICore

// MARK: - VersionSeedSetTracker

package struct VersionSeedSetTracker {
    private struct Value {
        var key: any PreferenceKey.Type
        var seed: VersionSeed
    }

    private var values: [VersionSeedSetTracker.Value]

    package mutating func addPreference<Key>(_ key: Key.Type) where Key: HostPreferenceKey {
        let value = Value(key: key, seed: .invalid)
        values.append(value)
    }

    package mutating func updateSeeds(to preferences: PreferenceValues) {
        for (index, value) in values.enumerated() {
            let seed = preferences.seed(for: value.key)
            values[index].seed = seed
        }
    }
}

// MARK: - VersionSeedTracker

package struct VersionSeedTracker<Key> where Key: PreferenceKey {
    package var seed: VersionSeed

    package init() {
        self.seed = .invalid
    }
    
    package mutating func didChange(_ preferences: PreferenceValues, action: (Key.Value) -> ()) {
        let value = preferences[Key.self]
        if !seed.matches(value.seed) {
            seed = value.seed
            action(value.value)
        }
    }
}

// MARK: - PreferenceValues Extension

extension PreferenceValues {
    fileprivate func seed<Key>(for keyType: Key.Type) -> VersionSeed where Key: PreferenceKey {
        return self[keyType].seed
    }
}
