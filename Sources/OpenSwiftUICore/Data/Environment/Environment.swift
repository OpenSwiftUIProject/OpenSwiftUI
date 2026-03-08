//
//  Environment.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 7B48F30970137591804EEB8D0D309152 (SwiftUI)
//  ID: 24E0E088473ED74681D096110CC5FC9A (SwiftUICore)

import OpenAttributeGraphShims
#if OPENSWIFTUI_SWIFT_LOG
public import Logging
#else
public import os
#endif

// MARK: - Environment

/// A property wrapper that reads a value from a view's environment.
///
/// Use the `Environment` property wrapper to read a value
/// stored in a view's environment. Indicate the value to read using an
/// ``EnvironmentValues`` key path in the property declaration. For example, you
/// can create a property that reads the color scheme of the current
/// view using the key path of the ``EnvironmentValues/colorScheme``
/// property:
///
///     @Environment(\.colorScheme) var colorScheme: ColorScheme
///
/// You can condition a view's content on the associated value, which
/// you read from the declared property's ``wrappedValue``. As with any property
/// wrapper, you access the wrapped value by directly referring to the property:
///
///     if colorScheme == .dark { // Checks the wrapped value.
///         DarkContent()
///     } else {
///         LightContent()
///     }
///
/// If the value changes, OpenSwiftUI updates any parts of your view that depend on
/// the value. For example, that might happen in the above example if the user
/// changes the Appearance settings.
///
/// You can use this property wrapper to read --- but not set --- an environment
/// value. OpenSwiftUI updates some environment values automatically based on system
/// settings and provides reasonable defaults for others. You can override some
/// of these, as well as set custom environment values that you define,
/// using the ``View/environment(_:_:)`` view modifier.
///
/// For the complete list of environment values provided by OpenSwiftUI, see the
/// properties of the ``EnvironmentValues`` structure. For information about
/// creating custom environment values, see the ``Entry()`` macro.
///
/// ### Get an observable object
///
/// You can also use `Environment` to get an observable object from a view's
/// environment. The observable object must conform to the
/// [Observable](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable)
/// protocol, and your app must set the object in the environment using the
/// the object itself or a key path.
///
/// To set the object in the environment using the object itself, use the
/// ``View/environment(_:)`` modifier:
///
///     @Observable
///     class Library {
///         var books: [Book] = [Book(), Book(), Book()]
///
///         var availableBooksCount: Int {
///             books.filter(\.isAvailable).count
///         }
///     }
///
///     @main
///     struct BookReaderApp: App {
///         @State private var library = Library()
///
///         var body: some Scene {
///             WindowGroup {
///                 LibraryView()
///                     .environment(library)
///             }
///         }
///     }
///
/// To get the observable object using its type, create a property and provide
/// the `Environment` property wrapper the object's type:
///
///     struct LibraryView: View {
///         @Environment(Library.self) private var library
///
///         var body: some View {
///             // ...
///         }
///     }
///
/// By default, reading an object from the environment returns a non-optional
/// object when using the object type as the key. This default behavior assumes
/// that a view in the current hierarchy previously stored a non-optional
/// instance of the type using the ``View/environment(_:)`` modifier. If
/// a view attempts to retrieve an object using its type and that object isn't
/// in the environment, OpenSwiftUI throws an exception.
///
/// In cases where there is no guarantee that an object is in the environment,
/// retrieve an optional version of the object as shown in the following code.
/// If the object isn't available the environment, OpenSwiftUI returns `nil`
/// instead of throwing an exception.
///
///     @Environment(Library.self) private var library: Library?
///
/// ### Get an observable object using a key path
///
/// To set the object with a key path, use the ``View/environment(_:_:)``
/// modifier:
///
///     @Observable
///     class Library {
///         var books: [Book] = [Book(), Book(), Book()]
///
///         var availableBooksCount: Int {
///             books.filter(\.isAvailable).count
///         }
///     }
///
///     @main
///     struct BookReaderApp: App {
///         @State private var library = Library()
///
///         var body: some Scene {
///             WindowGroup {
///                 LibraryView()
///                     .environment(\.library, library)
///             }
///         }
///     }
///
/// To get the object, create a property and specify the key path:
///
///     struct LibraryView: View {
///         @Environment(\.library) private var library
///
///         var body: some View {
///             // ...
///         }
///     }
///
@available(OpenSwiftUI_v1_0, *)
@frozen
@propertyWrapper
public struct Environment<Value>: DynamicProperty {

    @usableFromInline
    @frozen
    internal enum Content: @unchecked Sendable {

        /// A key path describing how to dereference the view's current
        /// environment to produce the linked value.
        case keyPath(KeyPath<EnvironmentValues, Value>)

        /// The view's current value of the environment property.
        case value(Value)
    }

    @usableFromInline
    internal var content: Content

    /// Creates an environment property to read the specified key path.
    ///
    /// Don’t call this initializer directly. Instead, declare a property
    /// with the ``Environment`` property wrapper, and provide the key path of
    /// the environment value that the property should reflect:
    ///
    ///     struct MyView: View {
    ///         @Environment(\.colorScheme) var colorScheme: ColorScheme
    ///
    ///         // ...
    ///     }
    ///
    /// OpenSwiftUI automatically updates any parts of `MyView` that depend on
    /// the property when the associated environment value changes.
    /// You can't modify the environment value using a property like this.
    /// Instead, use the ``View/environment(_:_:)`` view modifier on a view to
    /// set a value for a view hierarchy.
    ///
    /// - Parameter keyPath: A key path to a specific resulting value.
    @inlinable
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        content = .keyPath(keyPath)
    }

    /// The current value of the environment property.
    ///
    /// The wrapped value property provides primary access to the value's data.
    /// However, you don't access `wrappedValue` directly. Instead, you read the
    /// property variable created with the ``Environment`` property wrapper:
    ///
    ///     @Environment(\.colorScheme) var colorScheme: ColorScheme
    ///
    ///     var body: some View {
    ///         if colorScheme == .dark {
    ///             DarkContent()
    ///         } else {
    ///             LightContent()
    ///         }
    ///     }
    ///
    @inlinable
    public var wrappedValue: Value {
        switch content {
        case let .value(value):
            return value
        case let .keyPath(keyPath):
            #if OPENSWIFTUI_SWIFT_LOG
            Log.runtimeIssuesLog.log(level: .critical, """
                    Accessing Environment<\(Value.self)>'s value outside of \
                    being installed on a View. \
                    This will always read the default value \
                    and will not update.
                    """)
            #else
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                os_log(.fault, log: Log.runtimeIssuesLog, """
                    Accessing Environment<\(Value.self)>'s value outside of \
                    being installed on a View. \
                    This will always read the default value \
                    and will not update.
                    """)
            } else {
                os_log(.fault, log: Log.runtimeIssuesLog, """
                    Accessing Environment's value outside of being \
                    installed on a View. \
                    This will always read the default value \
                    and will not update.
                    """)
            }
            #endif
            // not bound to a view, return the default value.
            return EnvironmentValues()[keyPath: keyPath]
        }
    }

    @usableFromInline
    internal func error() -> Never {
        preconditionFailure("Reading Environment<\(Value.self)> outside View.body")
    }

    public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container _: _GraphValue<V>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        if Value.self == EnvironmentValues.self {
            buffer.append(
                FullEnvironmentBox(environment: inputs.environment),
                fieldOffset: fieldOffset
            )
        } else {
            buffer.append(
                EnvironmentBox<Value>(environment: inputs.environment),
                fieldOffset: fieldOffset
            )
        }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Environment: Sendable where Value: Sendable {}

// MARK: - FullEnvironmentBox

private struct FullEnvironmentBox: DynamicPropertyBox {
    @Attribute var environment: EnvironmentValues
    var keyPath: KeyPath<EnvironmentValues, EnvironmentValues>?
    var value: EnvironmentValues?
    var tracker: PropertyList.Tracker = .init()

    typealias Property = Environment<EnvironmentValues>

    mutating func update(property: inout Property, phase _: ViewPhase) -> Bool {
        guard case let .keyPath(propertyKeyPath) = property.content else {
            return false
        }
        let (environment, environmentChanged) = $environment.changedValue()
        let keyPathChanged = (propertyKeyPath != keyPath)
        if keyPathChanged {
            keyPath = propertyKeyPath
        }
        let valueChanged: Bool
        if keyPathChanged || environmentChanged {
            let newValue = environment[keyPath: propertyKeyPath]
            if let value, !tracker.hasDifferentUsedValues(environment.plist) {
                valueChanged = false
            } else {
                tracker.reset()
                tracker.initializeValues(from: newValue.plist)
                value = EnvironmentValues(newValue.plist, tracker: tracker)
                valueChanged = true
            }
        } else {
            valueChanged = false
        }
        property.content = .value(value!)
        return valueChanged
    }
}

// MARK: - EnvironmentBox

private struct EnvironmentBox<Value>: DynamicPropertyBox {
    @Attribute var environment: EnvironmentValues
    var keyPath: KeyPath<EnvironmentValues, Value>?
    var value: Value?
    var hadObservation: Bool = false

    typealias Property = Environment<Value>

    mutating func update(property: inout Property, phase _: ViewPhase) -> Bool {
        guard case let .keyPath(propertyKeyPath) = property.content else {
            return false
        }
        let (environment, environmentChanged) = $environment.changedValue()
        let keyPathChanged = (propertyKeyPath != keyPath)
        var valueChanged = environmentChanged
        if keyPathChanged {
            keyPath = propertyKeyPath
            valueChanged = true
        }
        if keyPathChanged || environmentChanged || hadObservation {
            let (newValue, accessList) = _withObservation {
                environment[keyPath: propertyKeyPath]
            }
            hadObservation = accessList != nil
            if let value, compareValues(value, newValue) {
                valueChanged = false
            } else {
                value = newValue
            }
        } else {
            valueChanged = false
        }
        property.content = .value(value!)
        return valueChanged
    }
}
