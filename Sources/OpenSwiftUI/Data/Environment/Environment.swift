//
//  Environment.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: 7B48F30970137591804EEB8D0D309152

internal import OpenGraphShims
#if OPENSWIFTUI_SWIFT_LOG
import Logging
#else
import os
#endif

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
/// creating custom environment values, see the ``EnvironmentKey`` protocol.
///
/// ### Get an observable object
///
/// You can also use `Environment` to get an observable object from a view's
/// environment. The observable object must conform to the
/// <doc://com.apple.documentation/documentation/Observation/Observable>
/// protocol, and your app must set the object in the environment using the
/// the object itself or a key path.
///
/// To set the object in the environment using the object itself, use the
/// ``View/environment(_:)-4516h`` modifier:
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
/// instance of the type using the ``View/environment(_:)-4516h`` modifier. If
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
@frozen
@propertyWrapper
public struct Environment<Value>: DynamicProperty {
    @usableFromInline
    @frozen
    enum Content {
        case keyPath(KeyPath<EnvironmentValues, Value>)
        case value(Value)
    }

    @usableFromInline
    var content: Content

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
    // Audited for RELEASE_2023
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
    func error() -> Never {
        fatalError("Reading Environment<\(Value.self)> outside View.body")
    }

    public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container _: _GraphValue<V>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        buffer.append(
            EnvironmentBox<Value>(
                environment: inputs.cachedEnvironment.wrappedValue.environment
            ),
            fieldOffset: fieldOffset
        )
    }
}

private struct EnvironmentBox<Value>: DynamicPropertyBox {
    @Attribute<EnvironmentValues>
    var environment: EnvironmentValues
    var keyPath: KeyPath<EnvironmentValues, Value>?
    var value: Value?
    
    init(environment: Attribute<EnvironmentValues>) {
        _environment = environment
        keyPath = nil
        value = nil
    }
        
    func destroy() {}
    func reset() {}
    mutating func update(property: inout Environment<Value>, phase _: _GraphInputs.Phase) -> Bool {
        guard case let .keyPath(propertyKeyPath) = property.content else {
            return false
        }
        let (environment, environmentChanged) = _environment.changedValue(options: [])
        let keyPathChanged = (propertyKeyPath != keyPath)
        if keyPathChanged { keyPath = propertyKeyPath }
        let valueChanged: Bool
        if keyPathChanged || environmentChanged {
            let newValue = environment[keyPath: propertyKeyPath]
            if let value, compareValues(value, newValue) {
                valueChanged = false
            } else {
                value = newValue
                valueChanged = true
            }
        } else {
            valueChanged = false
        }
        let value: Value = self.value!
        property.content = .value(value)
        return valueChanged
    }
}
