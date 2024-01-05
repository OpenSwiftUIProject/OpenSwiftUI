//
//  PreferenceList.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/1/5.
//  Lastest Version: iOS 15.5
//  Status: WIP

struct PreferenceList {
    private var first: PreferenceNode?
        
    subscript<Key: PreferenceKey>(_ keyType: Key.Type) -> Value<Key.Value> {
        get { fatalError("TODO") }
        set { fatalError("TODO") }
    }
}

extension PreferenceList {
    struct Value<V> {
        var value: V
        var seed: VersionSeed
    }
}

private class PreferenceNode {
    let keyType: Any.Type
    let seed: VersionSeed
    let mergedSeed: VersionSeed
    let next: PreferenceNode?
    
    init(keyType: Any.Type, seed: VersionSeed, next: PreferenceNode?) {
        fatalError("TODO")
    }
}
