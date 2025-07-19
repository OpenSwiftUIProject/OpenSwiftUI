//
//  UIKitEnvironmentKey.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 859636D0EA4E0B7C4D7D1B41B613A4D5 (SwiftUI?)

#if canImport(UIKit)

public import OpenSwiftUICore
public import UIKit

/// An environment key that is bridged to a UIKit trait.
///
/// Use this protocol to allow the same underlying data to be accessed using an
/// environment key in OpenSwiftUI and trait in UIKit. As the bridging is
/// bidirectional, values written to the trait in UIKit can be read using the
/// environment key in OpenSwiftUI, and values written to the environment key in
/// OpenSwiftUI can be read from the trait in UIKit.
///
/// Given a custom UIKit trait named `MyTrait` with `myTrait` properties on
/// both `UITraitCollection` and `UIMutableTraits`:
///
///     struct MyTrait: UITraitDefinition {
///         static let defaultValue = "Default value"
///     }
///
///     extension UITraitCollection {
///         var myTrait: String {
///             self[MyTrait.self]
///         }
///     }
///
///     extension UIMutableTraits {
///         var myTrait: String {
///             get { self[MyTrait.self] }
///             set { self[MyTrait.self] = newValue }
///         }
///     }
///
/// You can declare an environment key to represent the same data:
///
///     struct MyEnvironmentKey: EnvironmentKey {
///         static let defaultValue = "Default value"
///     }
///
/// Bridge the environment key and the trait by conforming to the
/// `UITraitBridgedEnvironmentKey` protocol, providing implementations
/// of ``read(from:)`` and ``write(to:value:)`` to losslessly convert
/// the environment value from and to the corresponding trait value:
///
///     extension MyEnvironmentKey: UITraitBridgedEnvironmentKey {
///         static func read(
///             from traitCollection: UITraitCollection
///         ) -> String {
///             traitCollection.myTrait
///         }
///
///         static func write(
///             to mutableTraits: inout UIMutableTraits, value: String
///         ) {
///             mutableTraits.myTrait = value
///         }
///     }
///
@available(OpenSwiftUI_v5_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
public protocol UITraitBridgedEnvironmentKey: EnvironmentKey {
    /// Reads the trait value from the trait collection, and returns
    /// the equivalent environment value.
    ///
    /// - Parameter traitCollection: The trait collection to read from.
    static func read(from traitCollection: UITraitCollection) -> Value

    /// Writes the equivalent trait value for the environment value into
    /// the mutable traits.
    ///
    /// - Parameter mutableTraits: The mutable traits to write to.
    /// - Parameter value: The environment value to write.
    static func write(to mutableTraits: inout any UIMutableTraits, value: Value)
}


extension EnvironmentValues {
    subscript<K>(_ key: K.Type) -> K.Value where K: UITraitBridgedEnvironmentKey {
        get { getBridgeValue(for: key) }
        set { setBridgeValue(value: newValue, for: K.self) }
    }

    private func getBridgeValue<K>(for key: K.Type) -> K.Value where K: UITraitBridgedEnvironmentKey {
        valueWithSecondaryLookup(UITraitBridgedEnvironmentPropertyKeyLookup<K>.self)
    }

    private mutating func setBridgeValue<K>(value: K.Value, for key: K.Type) where K: UITraitBridgedEnvironmentKey {
        if !bridgedEnvironmentKeys.contains(where: { $0 == key }) {
            bridgedEnvironmentKeys.append(key)
        }
        setValue(value, for: key)
    }
}

private struct UITraitBridgedEnvironmentPropertyKeyLookup<K>: PropertyKeyLookup where K: UITraitBridgedEnvironmentKey {
    typealias Primary = EnvironmentPropertyKey<K>
    typealias Secondary = EnvironmentPropertyKey<InheritedTraitCollectionKey>

    static func lookup(in traitCollection: UITraitCollection?) -> K.Value? {
        traitCollection.map { K.read(from: $0) }
    }
}

struct UITraitBridgedEnvironmentResolver: BridgedEnvironmentResolver {
    static func read<K>(for key: K.Type, from environment: EnvironmentValues) -> K.Value where K: EnvironmentKey {
        let bridgeKey = key as! any UITraitBridgedEnvironmentKey.Type
        return environment[bridgeKey] as! K.Value
    }

    static func write<K>(for key: K.Type, to environment: inout EnvironmentValues, value: K.Value) where K: EnvironmentKey {
        let bridgeKey = key as! any UITraitBridgedEnvironmentKey.Type
        write(bridgedKey: bridgeKey, to: &environment, value: value)
    }

    static func write<K, V>(bridgedKey: K.Type, to environment: inout EnvironmentValues, value: V) where K: UITraitBridgedEnvironmentKey {
        environment[K.self] = value as! K.Value
    }
}

#endif
