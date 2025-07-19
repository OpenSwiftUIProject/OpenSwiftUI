//
//  EnvironmentKey.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenGraphShims

/// A key for accessing values in the environment.
///
/// You can create custom environment values by extending the
/// ``EnvironmentValues`` structure with new properties.
/// First declare a new environment key type and specify a value for the
/// required ``defaultValue`` property:
///
///     private struct MyEnvironmentKey: EnvironmentKey {
///         static let defaultValue: String = "Default value"
///     }
///
/// The Swift compiler automatically infers the associated ``Value`` type as the
/// type you specify for the default value. Then use the key to define a new
/// environment value property:
///
///     extension EnvironmentValues {
///         var myCustomValue: String {
///             get { self[MyEnvironmentKey.self] }
///             set { self[MyEnvironmentKey.self] = newValue }
///         }
///     }
///
/// Clients of your environment value never use the key directly.
/// Instead, they use the key path of your custom environment value property.
/// To set the environment value for a view and all its subviews, add the
/// ``View/environment(_:_:)`` view modifier to that view:
///
///     MyView()
///         .environment(\.myCustomValue, "Another string")
///
/// As a convenience, you can also define a dedicated view modifier to
/// apply this environment value:
///
///     extension View {
///         func myCustomValue(_ myCustomValue: String) -> some View {
///             environment(\.myCustomValue, myCustomValue)
///         }
///     }
///
/// This improves clarity at the call site:
///
///     MyView()
///         .myCustomValue("Another string")
///
/// To read the value from inside `MyView` or one of its descendants, use the
/// ``Environment`` property wrapper:
///
///     struct MyView: View {
///         @Environment(\.myCustomValue) var customValue: String
///
///         var body: some View {
///             Text(customValue) // Displays "Another string".
///         }
///     }
///
public protocol EnvironmentKey {
    /// The associated type representing the type of the environment key's
    /// value.
    associatedtype Value

    /// The default value for the environment key.
    static var defaultValue: Value { get }
    
    /// Compares two values of the environment key's associated type.
    ///
    /// This function determines if two values of this environment key's 
    /// associated type should be considered equal. OpenSwiftUI uses this 
    /// to determine when environment changes should trigger view updates.
    ///
    /// - Parameters:
    ///   - lhs: The first value to compare.
    ///   - rhs: The second value to compare.
    /// - Returns: `true` if the values are considered equal; otherwise, `false`.
    ///
    /// The default implementation uses general value comparison for non-Equatable types.
    /// Types conforming to `Equatable` receive an optimized implementation that uses
    /// the `==` operator.
    static func _valuesEqual(_ lhs: Self.Value, _ rhs: Self.Value) -> Bool
}

extension EnvironmentKey {
    public static func _valuesEqual(_ lhs: Self.Value, _ rhs: Self.Value) -> Bool {
        compareValues(lhs, rhs)
    }
}

extension EnvironmentKey where Value: Equatable {
    public static func _valuesEqual(_ lhs: Self.Value, _ rhs: Self.Value) -> Bool {
        lhs == rhs
    }
}

/// A protocol that defines environment keys derived from other environment values.
///
/// Unlike standard `EnvironmentKey` that stores values directly, a `DerivedEnvironmentKey`
/// calculates its value dynamically based on other environment values.
///
/// To implement a derived environment key:
/// 1. Create a type that conforms to `DerivedEnvironmentKey`
/// 2. Specify the `Value` type that must conform to `Equatable`
/// 3. Implement the `value(in:)` method to compute the derived value
///
/// Example:
///
///     private struct MyDerivedKey: DerivedEnvironmentKey {
///         typealias Value = String
///
///         static func value(in values: EnvironmentValues) -> String {
///             return "\(values.someOtherValue) derived"
///         }
///     }
///
/// Then extend `EnvironmentValues` to access your derived value:
///
///     extension EnvironmentValues {
///         var myDerivedValue: String {
///             self[MyDerivedKey.self]
///         }
///     }
///
package protocol DerivedEnvironmentKey {
    /// The associated type representing the type of the environment key's
    /// value.
    associatedtype Value: Equatable
    
    /// Calculates the derived value based on the current environment values.
    ///
    /// - Parameter values: The current environment values.
    /// - Returns: The derived value for this key.
    static func value(in: EnvironmentValues) -> Value
}

package protocol BridgedEnvironmentKey: EnvironmentKey {}

package protocol BridgedEnvironmentResolver {
    static func read<K>(for key: K.Type, from environment: EnvironmentValues) -> K.Value where K: EnvironmentKey

    static func write<K>(for key: K.Type, to environment: inout EnvironmentValues, value: K.Value) where K: EnvironmentKey
}
