//
//  EnvironmentValues.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 83E729E7BD00420AB79EFD8DF557072A (SwiftUI)
//  ID: 0CBA6217BE011883F496E97230B6CF8F (SwiftUICore)

/// A collection of environment values propagated through a view hierarchy.
///
/// OpenSwiftUI exposes a collection of values to your app's views in an
/// `EnvironmentValues` structure. To read a value from the structure,
/// declare a property using the ``Environment`` property wrapper and
/// specify the value's key path. For example, you can read the current locale:
///
///     @Environment(\.locale) var locale: Locale
///
/// Use the property you declare to dynamically control a view's layout.
/// OpenSwiftUI automatically sets or updates many environment values, like
/// ``EnvironmentValues/pixelLength``, ``EnvironmentValues/scenePhase``, or
/// ``EnvironmentValues/locale``, based on device characteristics, system state,
/// or user settings. For others, like ``EnvironmentValues/lineLimit``, OpenSwiftUI
/// provides a reasonable default value.
///
/// You can set or override some values using the ``View/environment(_:_:)``
/// view modifier:
///
///     MyView()
///         .environment(\.lineLimit, 2)
///
/// The value that you set affects the environment for the view that you modify
/// --- including its descendants in the view hierarchy --- but only up to the
/// point where you apply a different environment modifier.
///
/// OpenSwiftUI provides dedicated view modifiers for setting some values, which
/// typically makes your code easier to read. For example, rather than setting
/// the ``EnvironmentValues/lineLimit`` value directly, as in the previous
/// example, you should instead use the ``View/lineLimit(_:)`` modifier:
///
///     MyView()
///         .lineLimit(2)
///
/// In some cases, using a dedicated view modifier provides additional
/// functionality. For example, you must use the
/// ``View/preferredColorScheme(_:)`` modifier rather than setting
/// ``EnvironmentValues/colorScheme`` directly to ensure that the new
/// value propagates up to the presenting container when presenting a view
/// like a popover:
///
///     MyView()
///         .popover(isPresented: $isPopped) {
///             PopoverContent()
///                 .preferredColorScheme(.dark)
///         }
///
/// Create a custom environment value by declaring a new property
/// in an extension to the environment values structure and applying
/// the ``Entry()`` macro to the variable declaration:
///
///     extension EnvironmentValues {
///         @Entry var myCustomValue: String = "Default value"
///     }
///
///     extension View {
///         func myCustomValue(_ myCustomValue: String) -> some View {
///             environment(\.myCustomValue, myCustomValue)
///         }
///     }
///
/// Clients of your value then access the value in the usual way, reading it
/// with the ``Environment`` property wrapper, and setting it with the
/// `myCustomValue` view modifier.
public struct EnvironmentValues: CustomStringConvertible {
    private var _plist: PropertyList
    
    private let tracker: PropertyList.Tracker?
    
    /// Creates an environment values instance.
    ///
    /// You don't typically create an instance of ``EnvironmentValues``
    /// directly. Doing so would provide access only to default values that
    /// don't update based on system settings or device characteristics.
    /// Instead, you rely on an environment values' instance
    /// that OpenSwiftUI manages for you when you use the ``Environment``
    /// property wrapper and the ``View/environment(_:_:)`` view modifier.
    public init() {
        _plist = PropertyList()
        tracker = nil
        CoreGlue2.shared.configureEmptyEnvironment(&self)
    }
    
    /// Creates an environment values instance with the specified property list.
    ///
    /// - Parameter plist: The property list to initialize the environment values with.
    package init(_ plist: PropertyList) {
        _plist = plist
        tracker = nil
    }
    
    /// Creates an environment values instance with the specified property list and tracker.
    ///
    /// - Parameters:
    ///   - plist: The property list to initialize the environment values with.
    ///   - tracker: The tracker to monitor property list changes.
    package init(_ plist: PropertyList, tracker: PropertyList.Tracker) {
        tracker.initializeValues(from: plist)
        self._plist = plist
        self.tracker = tracker
    }
    
    /// The underlying property list that stores environment values.
    package var plist: PropertyList {
        get {
            _plist
        }
        set {
            guard _plist.id != newValue.id else {
                return
            }
            if let tracker {
                tracker.invalidateAllValues(from: _plist, to: newValue)
            }
            _plist = newValue
        }
    }
    
    /// Returns a new environment values instance without a tracker.
    ///
    /// - Returns: An environment values instance with the same property list but no tracker.
    package func removingTracker() -> EnvironmentValues {
        EnvironmentValues(_plist)
    }
    
    /// Adds dependencies from another tracker to this environment's tracker.
    ///
    /// - Parameter other: The tracker whose dependencies should be added.
    package func addDependencies(from other: PropertyList.Tracker) {
        guard let tracker else { return }
        tracker.formUnion(other)
    }
    
    /// Retrieves a value using a secondary lookup mechanism.
    ///
    /// - Parameter key: The lookup key type.
    /// - Returns: The value associated with the key's primary type.
    package func valueWithSecondaryLookup<Lookup>(_ key: Lookup.Type) -> Lookup.Primary.Value where Lookup: PropertyKeyLookup {
        if let tracker {
            tracker.valueWithSecondaryLookup(_plist, secondaryLookupHandler: key)
        } else {
            _plist.valueWithSecondaryLookup(key)
        }
    }
    
    /// Sets a value for the specified environment key.
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - key: The environment key type.
    package mutating func setValue<K>(_ value: K.Value, for key: K.Type) where K: EnvironmentKey {
        _set(value, for: key)
    }
    
    private mutating func _set<K>(_ value: K.Value, for key: K.Type) where K: EnvironmentKey {
        let oldPlist = _plist
        _plist[EnvironmentPropertyKey<K>.self] = value
        if let tracker {
            tracker.invalidateValue(
                for: EnvironmentPropertyKey<K>.self,
                from: oldPlist,
                to: plist
            )
        }
    }

    /// Accesses the environment value associated with a custom key.
    ///
    /// Create custom environment values by defining a key
    /// that conforms to the ``EnvironmentKey`` protocol, and then using that
    /// key with the subscript operator of the ``EnvironmentValues`` structure
    /// to get and set a value for that key:
    ///
    ///     private struct MyEnvironmentKey: EnvironmentKey {
    ///         static let defaultValue: String = "Default value"
    ///     }
    ///
    ///     extension EnvironmentValues {
    ///         var myCustomValue: String {
    ///             get { self[MyEnvironmentKey.self] }
    ///             set { self[MyEnvironmentKey.self] = newValue }
    ///         }
    ///     }
    ///
    /// You use custom environment values the same way you use system-provided
    /// values, setting a value with the ``View/environment(_:_:)`` view
    /// modifier, and reading values with the ``Environment`` property wrapper.
    /// You can also provide a dedicated view modifier as a convenience for
    /// setting the value:
    ///
    ///     extension View {
    ///         func myCustomValue(_ myCustomValue: String) -> some View {
    ///             environment(\.myCustomValue, myCustomValue)
    ///         }
    ///     }
    ///
    public subscript<K>(key: K.Type) -> K.Value where K: EnvironmentKey {
        get {
            if let tracker {
                tracker.value(_plist, for: EnvironmentPropertyKey<K>.self)
            } else {
                _plist[EnvironmentPropertyKey<K>.self]
            }
        }
        set {
            setValue(newValue, for: key)
        }
    }

    /// Accesses the environment value associated with a derived environment key.
    ///
    /// Derived environment keys calculate their values based on other environment values.
    /// This subscript provides read-only access to these derived values.
    ///
    /// - Parameter key: The derived environment key type.
    /// - Returns: The value associated with the key.
    package subscript<K>(key: K.Type) -> K.Value where K: DerivedEnvironmentKey {
        if let tracker {
            tracker.derivedValue(_plist, for: DerivedEnvironmentPropertyKey<K>.self)
        } else {
            _plist[DerivedEnvironmentPropertyKey<K>.self]
        }
    }

    /// A string that represents the contents of the environment values
    /// instance.
    public var description: String { _plist.description }
}

@available(*, unavailable)
extension EnvironmentValues: Sendable {}

/// A property key that provides access to environment values.
///
/// This type bridges between the `EnvironmentKey` protocol and the internal `PropertyKey` system.
package struct EnvironmentPropertyKey<Key>: PropertyKey where Key: EnvironmentKey {
    /// The default value for this property key, obtained from the environment key.
    package static var defaultValue: Key.Value {
        Key.defaultValue
    }
}

/// A property key that provides access to derived environment values.
///
/// This type bridges between the `DerivedEnvironmentKey` protocol and the internal `DerivedPropertyKey` system.
private struct DerivedEnvironmentPropertyKey<Key>: DerivedPropertyKey where Key: DerivedEnvironmentKey {
    /// Calculates the derived value based on the current environment.
    ///
    /// - Parameter plist: The property list containing the current environment state.
    /// - Returns: The calculated value for this derived key.
    static func value(in plist: PropertyList) -> Key.Value {
        Key.value(in: EnvironmentValues(plist))
    }
}
