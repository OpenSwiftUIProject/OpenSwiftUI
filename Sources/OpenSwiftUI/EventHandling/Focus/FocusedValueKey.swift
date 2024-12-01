//
//  FocusedValueKey.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

import OpenSwiftUICore

/// A protocol for identifier types used when publishing and observing focused
/// values.
///
/// Unlike ``EnvironmentKey``, `FocusedValueKey` has no default value
/// requirement, because the default value for a key is always `nil`.
public protocol FocusedValueKey {
    associatedtype Value
}

public struct FocusedValues {
    struct StorageOptions {
        let rawValue: UInt8
    }
    
    var plist: PropertyList
    var storageOptions: StorageOptions
    var seed: VersionSeed
    
    @usableFromInline
    internal init() {
        plist = PropertyList()
        storageOptions = StorageOptions(rawValue: 0)
        seed = .empty
    }
    
    /// Reads and writes values associated with a given focused value key.
    public subscript<Key>(key: Key.Type) -> Key.Value? where Key: FocusedValueKey {
        preconditionFailure("TODO")
    }
}

@available(*, unavailable)
extension FocusedValues: Sendable {}

extension FocusedValues: Equatable {
    public static func == (lhs: FocusedValues, rhs: FocusedValues) -> Bool {
        lhs.seed.matches(rhs.seed)
    }
}
