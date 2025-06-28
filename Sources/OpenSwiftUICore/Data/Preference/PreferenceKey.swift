//
//  PreferenceKey.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

// MARK: - PreferenceKey

/// A named value produced by a view.
///
/// A view with multiple children automatically combines its values for a given
/// preference into a single value visible to its ancestors.
public protocol PreferenceKey {
    /// The type of value produced by this preference.
    associatedtype Value

    /// The default value of the preference.
    ///
    /// Views that have no explicit value for the key produce this default
    /// value. Combining child views may remove an implicit value produced by
    /// using the default. This means that `reduce(value: &x, nextValue:
    /// {defaultValue})` shouldn't change the meaning of `x`.
    static var defaultValue: Value { get }

    /// Combines a sequence of values by modifying the previously-accumulated
    /// value with the result of a closure that provides the next value.
    ///
    /// This method receives its values in view-tree order. Conceptually, this
    /// combines the preference value from one tree with that of its next
    /// sibling.
    ///
    /// - Parameters:
    ///   - value: The value accumulated through previous calls to this method.
    ///     The implementation should modify this value.
    ///   - nextValue: A closure that returns the next value in the sequence.
    static func reduce(value: inout Value, nextValue: () -> Value)

    /// If true `reduce()` will also see preference values for views
    /// that have active removal transitions. The default
    /// implementation returns false.
    static var _includesRemovedValues: Bool { get }

    /// If true the preference may be read via the renderer host API.
    /// Defaults to false. If true `_includesRemovedValues` should be
    /// false.
    static var _isReadableByHost: Bool { get }
}

extension PreferenceKey where Value: ExpressibleByNilLiteral {
    /// Let nil-expressible values default-initialize to nil.
    public static var defaultValue: Value { Value(nilLiteral: ()) }
}

extension PreferenceKey {
    public static var _includesRemovedValues: Bool { false }

    public static var _isReadableByHost: Bool { false }
    
    package static var readableName: String {
        var name = _typeName(Self.self, qualified: false)
        if name.hasSuffix("Key") {
            name.removeLast(3)
        }
        if name.hasSuffix("Preference") {
            name.removeLast(10)
        }
        if name.isEmpty {
            let fullname = _typeName(Self.self, qualified: true)
            let results = fullname.split(maxSplits: 1) { $0 == "." }
            return String(results[1])
        } else {
            return name
        }
    }

    package static func visitKey<Visitor>(_ visitor: inout Visitor) where Visitor: PreferenceKeyVisitor {
        visitor.visit(key: Self.self)
    }
}

// MARK: - PreferenceKeyVisitor

package protocol PreferenceKeyVisitor {
    mutating func visit<K>(key: K.Type) where K: PreferenceKey
}

// MARK: - PreferenceKeys [6.5.4]

package struct PreferenceKeys: Equatable, RandomAccessCollection, MutableCollection {
    var keys: [any PreferenceKey.Type] = []

    @inlinable
    package init() {}
    
    @inlinable
    package var isEmpty: Bool { keys.isEmpty }
    
    @inlinable
    package func contains(_ key: any PreferenceKey.Type) -> Bool {
        keys.contains { $0 == key }
    }
    
    package mutating func add(_ key: any PreferenceKey.Type) {
        guard !contains(key) else {
            return
        }
        keys.append(key)
    }

    package mutating func remove(_ key: any PreferenceKey.Type) {
        guard let index = keys.firstIndex(where: { $0 == key }) else { return }
        keys.remove(at: index)
    }
    
    package static func == (lhs: PreferenceKeys, rhs: PreferenceKeys) -> Bool {
        guard lhs.keys.count == rhs.keys.count else {
            return false
        }
        guard !lhs.keys.isEmpty else {
            return true
        }
        for index in lhs.indices {
            guard lhs[index] == rhs[index] else {
                return false
            }
        }
        return true
    }
    
    package var startIndex: Int { keys.startIndex }
    package var endIndex: Int { keys.endIndex }

    @inlinable
    package subscript(position: Int) -> any PreferenceKey.Type {
        get { keys[position] }
        set { keys[position] = newValue }
    }
}

// MARK: - HostPreferencesKey

package struct HostPreferencesKey: PreferenceKey {
    package static var defaultValue: PreferenceList {
        PreferenceList()
    }
    
    package static func reduce(value: inout PreferenceList, nextValue: () -> PreferenceList) {
        value.combine(with: nextValue())
    }
    
    private static var nodeId = UInt32.zero
    
    package static func makeNodeId() -> UInt32 {
        nodeId &+= 1
        return nodeId
    }
}

// MARK: - HostPreferenceKey

@_spi(Private)
public protocol HostPreferenceKey: PreferenceKey {}

@_spi(Private)
extension HostPreferenceKey {
    public static var _isReadableByHost: Bool { true }
}
