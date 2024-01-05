//
//  VersionSeed.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/1/5.
//  Lastest Version: iOS 15.5
//  Status: Complete
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
    
    @_transparent
    @inline(__always)
    func merge(_ seed: VersionSeed) -> VersionSeed {
        VersionSeed(value: merge32(value, seed.value))
    }
}

private func merge32(_ a: UInt32, _ b: UInt32) -> UInt32 {
    let a = UInt64(a)
    let b = UInt64(b)
    var c = b
    c &+= .max ^ (c &<< 32)
    c &+= a &<< 32
    c ^= (c &>> 22)
    c &+= .max ^ (c &<< 13)
    c ^= (c &>> 8)
    c &+= (c &<< 3)
    c ^= (c >> 15)
    c &+= .max ^ (c &<< 27)
    c ^= (c &>> 31)
    return UInt32(truncatingIfNeeded: c)
}

struct VersionSeedTracker<Key: HostPreferenceKey> {
    var seed: VersionSeed
}

struct VersionSeedSetTracker {
    private var values: [Value]
    
    mutating func addPreference<Key: HostPreferenceKey>(_: Key.Type) {
        values.append(Value(key: _AnyPreferenceKey<Key>.self, seed: .invalid))
    }
    
    mutating func updateSeeds(to preferences: PreferenceList) {
        for index in values.indices {
            var visitor = UpdateSeedVisitor(preferences: preferences, seed: nil)
            values[index].key.visitKey(&visitor)
            guard let seed = visitor.seed else {
                continue
            }
            values[index].seed = seed
        }
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
        
        mutating func visit(key: (some PreferenceKey).Type) {
            let valueSeed = preferences[key].seed
            matches = seed.isValid && valueSeed.isValid && seed.value == valueSeed.value
        }
    }
    
    private struct UpdateSeedVisitor: PreferenceKeyVisitor {
        let preferences: PreferenceList
        var seed: VersionSeed?
    
        mutating func visit(key: (some PreferenceKey).Type) {
            seed = preferences[key].seed
        }
    }
}
