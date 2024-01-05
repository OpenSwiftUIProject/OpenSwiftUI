//
//  PreferenceList.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/1/5.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: C1C63C2F6F2B9F3EB30DD747F0605FBD

struct PreferenceList {
    private var first: PreferenceNode?
        
    subscript<Key: PreferenceKey>(_ keyType: Key.Type) -> Value<Key.Value> {
        get { fatalError("TODO") }
        set { fatalError("TODO") }
    }
    
    func valueIfPresent<Key: PreferenceKey>(_ keyType: Key.Type) -> Value<Key.Value>? {
        fatalError("TODO")
    }
    
    func modifyValue() {
        fatalError("TODO")
    }
    
    func removeValue() {
        fatalError("TODO")
    }
}

extension PreferenceList {
    struct Value<V> {
        var value: V
        var seed: VersionSeed
    }
}

private class PreferenceNode: CustomStringConvertible {
    let keyType: Any.Type
    let seed: VersionSeed
    let mergedSeed: VersionSeed
    let next: PreferenceNode?
    
    init(keyType: Any.Type, seed: VersionSeed, next: PreferenceNode?) {
        self.keyType = keyType
        self.seed = seed
        let seedResult: VersionSeed
        if let next {
            seedResult = next.mergedSeed.merge(seed)
        } else {
            seedResult = seed
        }
        self.mergedSeed = seedResult
        self.next = next
    }
    
    final func forEach(_ body:(PreferenceNode) -> ()) {
        var node = self
        repeat {
            body(node)
            if let next = node.next {
                node = next
            } else {
                break
            }
        } while true
    }
    
    final func find<Key: PreferenceKey>(key: Key.Type) -> _PreferenceNode<Key>? {
        var node = self
        repeat {
            if node.keyType == key {
                return node as? _PreferenceNode<Key>
            } else {
                if let next = node.next {
                    node = next
                } else {
                    break
                }
            }
        } while true
        return nil
    }
    
    func find(from: PreferenceNode?) -> PreferenceNode? { fatalError() }
    func combine(from: PreferenceNode?, next: PreferenceNode?) -> PreferenceNode? { fatalError() }
    func copy(next: PreferenceNode?) -> PreferenceNode { fatalError() }
    var description: String { fatalError() }
}

private class _PreferenceNode<Key: PreferenceKey>: PreferenceNode {
    let value: Key.Value
    
    init(value: Key.Value, seed: VersionSeed, next: PreferenceNode?) {
        self.value = value
        super.init(keyType: Key.self, seed: seed, next: next)
    }
    
    override func find(from: PreferenceNode?) -> PreferenceNode? {
        from?.find(key: Key.self)
    }
    
    override func combine(from: PreferenceNode?, next: PreferenceNode?) -> PreferenceNode? {
        var currentNode = from
        while let node = currentNode {
            if keyType == node.keyType {
                var value = self.value
                var seed = self.seed
                Key.reduce(value: &value) {
                    seed = seed.merge(node.seed)
                    return (node as! _PreferenceNode).value
                }
                return _PreferenceNode(value: value, seed: seed, next: next)
            } else {
                currentNode = node.next
            }
        }
        return nil
    }
    
    override func copy(next: PreferenceNode?) -> PreferenceNode {
        _PreferenceNode(value: value, seed: seed, next: next)
    }
        
    override var description: String {
        "\(Key.self) = \(value)"
    }
}
