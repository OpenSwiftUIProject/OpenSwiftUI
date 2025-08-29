//
//  FocusedValueKey.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import OpenSwiftUICore
import OpenAttributeGraphShims

@available(OpenSwiftUI_v2_0, *)
@propertyWrapper
public struct FocusedValue<Value>: DynamicProperty {
    @usableFromInline
    @frozen
    internal enum Content {
        case keyPath(KeyPath<FocusedValues, Value?>)
        case value(Value?)
    }

    @usableFromInline
    internal var content: FocusedValue<Value>.Content

    public init(_ keyPath: KeyPath<FocusedValues, Value?>) {
        _openSwiftUIUnimplementedFailure()
    }

    @inlinable
    public var wrappedValue: Value? {
        if case .value(let value) = content {
            return value
        } else {
            return nil
        }
    }

    public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<V>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(*, unavailable)
extension FocusedValue: Sendable {}

@available(*, unavailable)
extension FocusedValue.Content: Sendable {}

/// A protocol for identifier types used when publishing and observing focused
/// values.
///
/// Unlike ``EnvironmentKey``, `FocusedValueKey` has no default value
/// requirement, because the default value for a key is always `nil`.
@available(OpenSwiftUI_v2_0, *)
public protocol FocusedValueKey {
    associatedtype Value
}

/// A collection of state exported by the focused view and its ancestors.
@available(OpenSwiftUI_v2_0, *)
public struct FocusedValues {
    var plist: PropertyList

    struct StorageOptions: OptionSet {
        let rawValue: UInt8
    }

    var storageOptions: FocusedValues.StorageOptions

    var navigationDepth: Int

    var seed: VersionSeed

    @usableFromInline
    internal init() {
        plist = PropertyList()
        storageOptions = []
        navigationDepth = -1
        seed = .empty
    }

    /// Reads and writes values associated with a given focused value key.

    public subscript<Key>(key: Key.Type) -> Key.Value? where Key: FocusedValueKey {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }
}

@available(*, unavailable)
extension FocusedValues: Sendable {}

@available(OpenSwiftUI_v3_0, *)
extension FocusedValues: Equatable {
    public static func == (lhs: FocusedValues, rhs: FocusedValues) -> Bool {
        lhs.seed.matches(rhs.seed)
    }
}

// FIXME
struct FocusedValuesInputKey: ViewInput {
    static var defaultValue: OptionalAttribute<FocusedValues> {
        .init()
    }
}
