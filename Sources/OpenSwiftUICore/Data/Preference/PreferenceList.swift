//
//  PreferenceList.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Copmlete
//  ID: C1C63C2F6F2B9F3EB30DD747F0605FBD (SwiftUI)
//  ID: 7B694C05291EA7AF22785AB458D1BC2F (SwiftUICore)

// MARK: - PreferenceList

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
    
    package subscript<K>(key: K.Type) -> Value<K.Value> where K: PreferenceKey {
        get {
            guard let first,
                  let node = first.find(key) else {
                return Value(value: key.defaultValue, seed: .empty)
            }
            return Value(value: node.value, seed: node.seed)
        }
        set {
            if let first,
               let _ = first.find(key) {
                removeValue(for: key)
            }
            first = _PreferenceNode<K>(value: newValue.value, seed: newValue.seed, next: first)
        }
    }
    
    package func valueIfPresent<K>(for key: K.Type = K.self) -> Value<K.Value>? where K: PreferenceKey {
        first?.find(key).map { node in
            Value(value: node.value, seed: node.seed)
        }
    }
    
    package func contains<K>(_ key: K.Type) -> Bool where K: PreferenceKey {
        first?.find(key) != nil
    }
    
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
    
    package mutating func modifyValue<K>(for key: K.Type, transform: Value<(inout K.Value) -> Void>) where K: PreferenceKey {
        var value = self[key]
        value.seed.merge(transform.seed)
        transform.value(&value.value)
        removeValue(for: key)
        first = _PreferenceNode<K>(value: value.value, seed: value.seed, next: first)
    }
    
    package func mayNotBeEqual(to other: PreferenceList) -> Bool {
        guard first !== other.first else {
            return false
        }
        return !seed.matches(other.seed)
    }
    
    package var seed: VersionSeed { first?.mergedSeed ?? .empty }
    
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

// MARK: - PreferenceNode

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
    
    @inlinable
    final func forEach(_ body: (PreferenceNode) -> Void) {
        var currentNode: PreferenceNode? = self
        while let node = currentNode {
            body(node)
            currentNode = node.next
        }
    }
    
    @inlinable
    final func find<K>(_ key: K.Type = K.self) -> _PreferenceNode<K>? where K: PreferenceKey {
        var currentNode: PreferenceNode? = self
        while let node = currentNode {
            guard node.keyType == key else {
                currentNode = node.next
                continue
            }
            return (node as! _PreferenceNode<K>)
        }
        return nil
    }
    
    func find(from _: PreferenceNode?) -> PreferenceNode? { _openSwiftUIBaseClassAbstractMethod() }
    func combine(from _: PreferenceNode?, next _: PreferenceNode?) -> PreferenceNode? { _openSwiftUIBaseClassAbstractMethod() }
    func copy(next _: PreferenceNode?) -> PreferenceNode { _openSwiftUIBaseClassAbstractMethod() }
    class var _includesRemovedValues: Bool { _openSwiftUIBaseClassAbstractMethod() }
    var description: String { _openSwiftUIBaseClassAbstractMethod() }
}

// MARK: - PreferenceNode

private class _PreferenceNode<K>: PreferenceNode where K: PreferenceKey {
    let value: K.Value
    
    init(value: K.Value, seed: VersionSeed, next: PreferenceNode?) {
        self.value = value
        super.init(keyType: K.self, seed: seed, next: next)
    }
    
    override func find(from: PreferenceNode?) -> PreferenceNode? {
        from?.find(K.self)
    }
    
    override func combine(from: PreferenceNode?, next: PreferenceNode?) -> PreferenceNode? {
        var currentNode = from
        while let node = currentNode {
            guard keyType == node.keyType else {
                currentNode = node.next
                continue
            }
            var value = self.value
            var seed = self.seed
            K.reduce(value: &value) {
                seed.merge(node.seed)
                return (node as! _PreferenceNode).value
            }
            return _PreferenceNode(value: value, seed: seed, next: next)
        }
        return nil
    }
    
    override func copy(next: PreferenceNode?) -> PreferenceNode {
        _PreferenceNode(value: value, seed: seed, next: next)
    }
    
    override class var _includesRemovedValues: Bool { K._includesRemovedValues }
    
    override var description: String {
        "\(K.self) = \(value)"
    }
}
