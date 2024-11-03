//
//  PreferenceList.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

package struct PreferenceList: CustomStringConvertible {
    private var first: PreferenceNode?
    
    @inlinable
    package init() {}
    
    package struct Value<T> {
        package var value: T
        package var seed: VersionSeed
        
        package init(value: T, seed: VersionSeed) {
            self.value = value
            self.seed = seed
        }
    }
    
    // TODO: TO BE AUDITED
    package subscript<K>(key: K.Type) -> Value<K.Value> where K: PreferenceKey{
        get {
            guard let first,
                  let node = first.find(key: key) else {
                return Value(value: key.defaultValue, seed: .empty)
            }
            return Value(value: node.value, seed: node.seed)
        }
        set {
            if let first,
               let _ = first.find(key: key) {
                removeValue(for: key)
            }
            first = _PreferenceNode<K>(value: newValue.value, seed: newValue.seed, next: first)
        }
    }
    
    // TODO: TO BE AUDITED
    package func valueIfPresent<K>(for _: K.Type) -> Value<K.Value>? where K: PreferenceKey {
        guard let first else {
            return nil
        }
        return first.find(key: K.self).map { node in
            Value(value: node.value, seed: node.seed)
        }
    }
    
    // TODO: TO BE AUDITED
    package func contains<K>(_ key: K.Type) -> Bool where K: PreferenceKey {
        first?.find(key: key) != nil
    }
    
    // TODO: TO BE AUDITED
    package mutating func removeValue<K>(for key: K.Type) where K: PreferenceKey {
        let first = first
        self.first = nil
        first?.forEach { node in
            guard node.keyType != key else {
                return
            }
            self.first = node.copy(next: self.first)
        }
    }
    
    // TODO: TO BE AUDITED
    package mutating func modifyValue<K>(for key: K.Type, transform: Value <(inout K.Value) -> Void>) where K: PreferenceKey {
        var value = self[key]
        value.seed.merge(transform.seed)
        transform.value(&value.value)
        removeValue(for: key)
        first = _PreferenceNode<K>(value: value.value, seed: value.seed, next: first)
    }
    
    // TODO: TO BE AUDITED
    package func mayNotBeEqual(to other: PreferenceList) -> Bool {
        // TODO
        return false
    }
    
    package var seed: VersionSeed { first?.mergedSeed ?? .empty }
    
    // TODO: TO BE AUDITED
    package mutating func combine(with other: PreferenceList) {
        guard let otherFirst = other.first else {
            return
        }
        guard let selfFirst = first else {
            first = otherFirst
            return
        }
        first = nil
        selfFirst.forEach { node in
            if let mergedNode = node.combine(from: otherFirst, next: first) {
                first = mergedNode
            } else {
                first = node.copy(next: first)
            }
        }
        otherFirst.forEach { node in
            guard node.find(from: selfFirst) == nil else {
                return
            }
            first = node.copy(next: first)
        }
    }
    
    package mutating func filterRemoved() {
        guard let first else {
            return
        }
        self.first = nil
        first.forEach { node in
            guard type(of: node)._includesRemovedValues else {
                return
            }
            self.first = node.copy(next: self.first)
        }
    }
    
    package var description: String {
        var description = "\(seed.description): ["
        var currentNode = first
        var shouldAddSeparator = false
        while let node = currentNode {
            if shouldAddSeparator {
                description.append(", ")
            } else {
                shouldAddSeparator = true
            }
            description.append(node.description)
            currentNode = node.next
        }
        description.append("]")
        return description
    }
}

// TODO: TO BE AUDITED
private class PreferenceNode: CustomStringConvertible {
    let keyType: Any.Type
    let seed: VersionSeed
    let mergedSeed: VersionSeed
    let next: PreferenceNode?
    
    init(keyType: Any.Type, seed: VersionSeed, next: PreferenceNode?) {
        self.keyType = keyType
        self.seed = seed
        if let next {
            var mergedSeed = next.mergedSeed
            mergedSeed.merge(seed)
            self.mergedSeed = mergedSeed
        } else {
            self.mergedSeed = seed
        }
        self.next = next
    }
    
    final func forEach(_ body: (PreferenceNode) -> Void) {
        var node = self
        repeat {
            body(node)
            guard let next = node.next else {
                break
            }
            node = next
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
    
    func find(from _: PreferenceNode?) -> PreferenceNode? { fatalError() }
    func combine(from _: PreferenceNode?, next _: PreferenceNode?) -> PreferenceNode? { fatalError() }
    func copy(next _: PreferenceNode?) -> PreferenceNode { fatalError() }
    class var _includesRemovedValues: Bool { fatalError() }
    var description: String { fatalError() }
}

// TODO: TO BE AUDITED
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
                    seed.merge(node.seed)
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
    
    override class var _includesRemovedValues: Bool { Key._includesRemovedValues }
    
    override var description: String {
        "\(Key.self) = \(value)"
    }
}
