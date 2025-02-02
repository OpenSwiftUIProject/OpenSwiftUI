//
//  EnvironmentKey.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
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

package protocol DerivedEnvironmentKey {
    associatedtype Value: Equatable
    static func value(in: EnvironmentValues) -> Value
}
