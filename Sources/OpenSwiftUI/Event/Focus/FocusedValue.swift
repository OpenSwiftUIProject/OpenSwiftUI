//
//  FocusedValue.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B1EDB9B13C46E98882FF0F0DFA69F617 (SwiftUI)

import OpenSwiftUICore
import OpenAttributeGraphShims

// MARK: - FocusedValue

/// A property wrapper for observing values from the focused view or one of its
/// ancestors.
///
/// If multiple views publish values using the same key, the wrapped property
/// will reflect the value from the view closest to focus.
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

    /// A new property wrapper for the given key path.
    ///
    /// The value of the property wrapper is updated dynamically as focus
    /// changes and different published values go in and out of scope.
    ///
    /// - Parameter keyPath: The key path for the focus value to read.
    public init(_ keyPath: KeyPath<FocusedValues, Value?>) {
        content = .keyPath(keyPath)
    }

    /// The value for the focus key given the current scope and state of the
    /// focused view hierarchy.
    ///
    /// Returns `nil` when nothing in the focused view hierarchy exports a
    /// value.
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
        let box = FocusedValueBox<Value>(
            environment: inputs.environment,
            focusedValues: inputs[FocusedValuesInputKey.self]
        )
        buffer.append(box, fieldOffset: fieldOffset)
    }
}

@available(*, unavailable)
extension FocusedValue: Sendable {}

@available(*, unavailable)
extension FocusedValue.Content: Sendable {}

// MARK: - FocusedValueKey

/// A protocol for identifier types used when publishing and observing focused
/// values.
///
/// Unlike ``EnvironmentKey``, `FocusedValueKey` has no default value
/// requirement, because the default value for a key is always `nil`.
@available(OpenSwiftUI_v2_0, *)
public protocol FocusedValueKey {
    associatedtype Value
}

// MARK: - FocusedValues

/// A collection of state exported by the focused view and its ancestors.
@available(OpenSwiftUI_v2_0, *)
public struct FocusedValues {
    var plist: PropertyList

    var storageOptions: FocusedValues.StorageOptions

    var navigationDepth: Int

    var seed: VersionSeed

    struct StorageOptions: OptionSet {
        let rawValue: UInt8

        static let inFocusedViewHierarchy = StorageOptions(rawValue: 1 << 0)
        static let scene = StorageOptions(rawValue: 1 << 1)
    }

    @usableFromInline
    internal init() {
        plist = PropertyList()
        storageOptions = []
        navigationDepth = -1
        seed = .empty
    }

    /// Reads and writes values associated with a given focused value key.
    public subscript<Key>(key: Key.Type) -> Key.Value? where Key: FocusedValueKey {
        get {
            var sceneEntry: Entry<Key>?
            var sceneDepth = Int.min
            var viewEntry: Entry<Key>?
            plist.forEach(keyType: FocusedValuePropertyKey<Key>.self) { entry, _ in
                guard let entry else {
                    return
                }
                if entry.scope == .scene, sceneEntry == nil || entry.depth > sceneDepth {
                    sceneEntry = entry
                    sceneDepth = entry.depth
                } else if entry.scope == .view, entry.inFocusedViewHierarchy {
                    viewEntry = entry
                }
            }
            return viewEntry?.value ?? sceneEntry?.value
        }
        set {
            guard let newValue else {
                return
            }
            let isSceneValue = storageOptions.contains(.scene)
            plist[FocusedValuePropertyKey<Key>.self] = Entry(
                scope: isSceneValue ? .scene : .view,
                value: newValue,
                inFocusedViewHierarchy: storageOptions.contains(.inFocusedViewHierarchy),
                depth: isSceneValue ? navigationDepth : -1
            )
        }
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

// MARK: - FocusedValuePropertyKey

private struct FocusedValuePropertyKey<Key>: PropertyKey where Key: FocusedValueKey {
    static var defaultValue: FocusedValues.Entry<Key>? { nil }
}

extension FocusedValues {
    fileprivate struct Entry<Key> where Key: FocusedValueKey {
        let scope: FocusedValueScope
        let value: Key.Value
        let inFocusedViewHierarchy: Bool
        let depth: Int
    }
}

// MARK: - FocusedValueBox

private struct FocusedValueBox<Value>: DynamicPropertyBox {
    @Attribute var environment: EnvironmentValues
    @OptionalAttribute var focusedValues: FocusedValues?
    var keyPath: KeyPath<FocusedValues, Value?>?
    var value: Value?

    typealias Property = FocusedValue<Value>

    mutating func update(property: inout Property, phase _: ViewPhase) -> Bool {
        guard case let .keyPath(propertyKeyPath) = property.content else {
            return false
        }
        let (focusedValues, focusedValuesChanged) = $focusedValues?.changedValue() ?? (.init(), false)
        let (_, environmentChanged) = $environment.changedValue()
        let keyPathChanged = propertyKeyPath != keyPath
        if keyPathChanged {
            keyPath = propertyKeyPath
        }
        var valueChanged = keyPathChanged || focusedValuesChanged || environmentChanged
        if valueChanged {
            let newValue = focusedValues[keyPath: propertyKeyPath]
            if let value, compareValues(value, newValue) {
                valueChanged = false
            } else {
                value = newValue
            }
        }
        property.content = .value(value)
        return valueChanged
    }
}

// MARK: - FocusedValuesInputKey

struct FocusedValuesInputKey: ViewInput {
    static var defaultValue: OptionalAttribute<FocusedValues> {
        .init()
    }
}

extension _ViewInputs {
    var focusedValues: Attribute<FocusedValues>? {
        get { base.focusedValues }
        set { base.focusedValues = newValue }
    }
}

extension _GraphInputs {
    var focusedValues: Attribute<FocusedValues>? {
        get { self[FocusedValuesInputKey.self].attribute }
        set { self[FocusedValuesInputKey.self] = .init(newValue) }
    }
}

// MARK: - FocusedValueScope

struct FocusedValueScope: Equatable, Identifiable {
    let id: ViewIdentity
    let name: String

    static let scene = FocusedValueScope(id: .init(), name: "Scene")
    static let view = FocusedValueScope(id: .init(), name: "View")

    static func == (lhs: FocusedValueScope, rhs: FocusedValueScope) -> Bool {
        lhs.id == rhs.id
    }
}
