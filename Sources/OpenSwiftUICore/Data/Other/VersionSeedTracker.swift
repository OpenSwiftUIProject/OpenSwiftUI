//
//  VersionSeedTracker.swift
//  OpenSwiftUI
//  Audited for iOS 15.5
//  Status: Complete

//struct VersionSeedTracker<Key: HostPreferenceKey> {
//    var seed: VersionSeed
//}
//
//struct VersionSeedSetTracker {
//    private var values: [Value]
//
//    mutating func addPreference<Key: HostPreferenceKey>(_: Key.Type) {
//        values.append(Value(key: _AnyPreferenceKey<Key>.self, seed: .invalid))
//    }
//
//    mutating func updateSeeds(to preferences: PreferenceList) {
//        for index in values.indices {
//            var visitor = UpdateSeedVisitor(preferences: preferences, seed: nil)
//            values[index].key.visitKey(&visitor)
//            guard let seed = visitor.seed else {
//                continue
//            }
//            values[index].seed = seed
//        }
//    }
//}
//
//extension VersionSeedSetTracker {
//    private struct Value {
//        var key: AnyPreferenceKey.Type
//        var seed: VersionSeed
//    }
//}
//
//extension VersionSeedSetTracker {
//    private struct HasChangesVisitor: PreferenceKeyVisitor {
//        let preferences: PreferenceList
//        var seed: VersionSeed
//        var matches: Bool?
//
//        mutating func visit(key: (some PreferenceKey).Type) {
//            let valueSeed = preferences[key].seed
//            matches = seed.matches(valueSeed)
//        }
//    }
//
//    private struct UpdateSeedVisitor: PreferenceKeyVisitor {
//        let preferences: PreferenceList
//        var seed: VersionSeed?
//
//        mutating func visit(key: (some PreferenceKey).Type) {
//            seed = preferences[key].seed
//        }
//    }
//}
