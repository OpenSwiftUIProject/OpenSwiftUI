//
//  VersionSeed.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/1/5.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 1B00D77CE2C80F9C0F5A59FDEA30ED6B

struct VersionSeed: CustomStringConvertible {
    var value: UInt32
    
    var description: String {
        switch value {
        case VersionSeed.zero.value: "empty"
        case VersionSeed.invalid.value: "invalid"
        default: value.description
        }
    }
    
    static var zero: VersionSeed { VersionSeed(value: .zero) }
    static var invalid: VersionSeed { VersionSeed(value: .max) }
    
    var isValid: Bool { value != VersionSeed.invalid.value }
}

struct VersionSeedTracker<Key: HostPreferenceKey> {
    var seed: VersionSeed
}

struct VersionSeedSetTracker {
    private var values: [Value]
    
    func addPreference<Key: HostPreferenceKey>(_ keyType: Key.Type) {
        
    }
    
    func updateSeeds(to: PreferenceList) {
        
    }
}

extension VersionSeedSetTracker {
    private struct Value {
        var key: AnyPreferenceKey.Type
        var seed: VersionSeed
    }
}

extension VersionSeedSetTracker {
    private struct HasChangesVisitor: PreferenceKeyVisitor {
        let preferences: PreferenceList
        var seed: VersionSeed
        var matches: Bool?
        
        mutating func visit<Key>(key: Key.Type) where Key : PreferenceKey {
            let valueSeed = preferences[key].seed
            matches = seed.isValid && valueSeed.isValid && seed.value == valueSeed.value
        }
    }
    
    private struct UpdateSeedVisitor: PreferenceKeyVisitor {
        let preferences: PreferenceList
        var seed: VersionSeed?
    
        mutating func visit<Key>(key: Key.Type) where Key : PreferenceKey {
            seed = preferences[key].seed
        }
    }
}
