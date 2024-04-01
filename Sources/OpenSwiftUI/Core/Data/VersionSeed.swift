//
//  VersionSeed.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: 1B00D77CE2C80F9C0F5A59FDEA30ED6B

struct VersionSeed: CustomStringConvertible {
    var value: UInt32

    var description: String {
        switch value {
        case VersionSeed.empty.value: "empty"
        case VersionSeed.invalid.value: "invalid"
        default: value.description
        }
    }

    @inline(__always)
    static var empty: VersionSeed { VersionSeed(value: .zero) }

    @inline(__always)
    static var invalid: VersionSeed { VersionSeed(value: .max) }

    @inline(__always)
    var isInvalid: Bool { value == VersionSeed.invalid.value }

    @inline(__always)
    var isEmpty: Bool { value == VersionSeed.empty.value }

    @inline(__always)
    mutating func merge(_ other: VersionSeed) {
        guard !isInvalid, !other.isEmpty else {
            return
        }
        guard !isEmpty, !other.isInvalid else {
            self = other
            return
        }
        self = VersionSeed(value: merge32(value, other.value))
    }

    @inline(__always)
    func merging(_ seed: VersionSeed) -> VersionSeed {
        var newValue = self
        newValue.merge(seed)
        return newValue
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
            matches = !seed.isInvalid && !valueSeed.isInvalid && seed.value == valueSeed.value
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
