//
//  AccessibilityFocusState.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 595604A29672AB74A744D145AF563C16 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - AccessibilityFocusState

/// A property wrapper type that can read and write a value that OpenSwiftUI updates
/// as the focus of any active accessibility technology, such as VoiceOver,
/// changes.
///
/// Use this capability to request that VoiceOver or other accessibility
/// technologies programmatically focus on a specific element, or to determine
/// whether VoiceOver or other accessibility technologies are focused on
/// particular elements. Use ``View/accessibilityFocused(_:equals:)`` or
/// ``View/accessibilityFocused(_:)`` in conjunction with this property
/// wrapper to identify accessibility elements for which you want to get
/// or set accessibility focus. When accessibility focus enters the modified accessibility element,
/// the framework updates the wrapped value of this property to match a given
/// prototype value. When accessibility focus leaves, OpenSwiftUI resets the wrapped value
/// of an optional property to `nil` or the wrapped value of a Boolean property to `false`.
/// Setting the property's value programmatically has the reverse effect, causing
/// accessibility focus to move to whichever accessibility element is associated with the updated value.
///
///  In the example below, when `notification` changes, and its  `isPriority` property
///  is `true`, the accessibility focus moves to the notification `Text` element above the rest of the
///  view's content:
///
///     struct CustomNotification: Equatable {
///         var text: String
///         var isPriority: Bool
///     }
///
///     struct ContentView: View {
///         @Binding var notification: CustomNotification?
///         @AccessibilityFocusState var isNotificationFocused: Bool
///
///         var body: some View {
///             VStack {
///                 if let notification = self.notification {
///                     Text(notification.text)
///                         .accessibilityFocused($isNotificationFocused)
///                 }
///                 Text("The main content for this view.")
///             }
///             .onChange(of: notification) { notification in
///                 if (notification?.isPriority == true)  {
///                     isNotificationFocused = true
///                 }
///             }
///
///         }
///     }
///
/// To allow for cases where accessibility focus is completely absent from the
/// tree of accessibility elements, or accessibility technologies are not
/// active, the wrapped value must be either optional or Boolean.
///
/// Some initializers of `AccessibilityFocusState` also allow specifying
/// accessibility technologies, determining to which types of accessibility
/// focus this binding applies. If you specify no accessibility technologies,
/// OpenSwiftUI uses an aggregate of any and all active accessibility technologies.
@available(OpenSwiftUI_v3_0, *)
@propertyWrapper
@frozen
public struct AccessibilityFocusState<Value>: DynamicProperty where Value: Hashable {
    @propertyWrapper
    @frozen
    public struct Binding {
        private var _binding: OpenSwiftUICore.Binding<Value>

        init(binding: OpenSwiftUICore.Binding<Value>) {
            _binding = binding
        }

        /// The underlying value referenced by the bound property.
        public var wrappedValue: Value {
            get { _binding.wrappedValue }
            nonmutating set { _binding.wrappedValue = newValue }
        }

        /// The currently focused element.
        public var projectedValue: AccessibilityFocusState<Value>.Binding {
            self
        }

        var propertyID: ObjectIdentifier {
            if let location = _binding.location as? AccessibilityFocusStoreLocation<Value> {
                location.id
            } else {
                ObjectIdentifier(PrivateType.self)
            }
        }

        private enum PrivateType {}
    }

    var technologies: AccessibilityTechnologies? = nil
    var value: Value
    var location: AnyLocation<Value>?
    var resetValue: Value

    /// The current state value, taking into account whatever bindings might be
    /// in effect due to the current location of focus.
    ///
    /// When focus is not in any view that is bound to this state, the wrapped
    /// value will be `nil` (for optional-typed state) or `false` (for `Bool`-
    /// typed state).
    public var wrappedValue: Value {
        get {
            getValue(forReading: true)
        }
        nonmutating set {
            guard let location else {
                return
            }
            location.set(newValue, transaction: Transaction())
        }
    }

    /// A projection of the state value that can be used to establish bindings between view content
    /// and accessibility focus placement.
    ///
    /// Use `projectedValue` in conjunction with
    /// ``View/accessibilityFocused(_:equals:)`` to establish
    /// bindings between view content and accessibility focus placement.
    public var projectedValue: AccessibilityFocusState<Value>.Binding {
        let value = getValue(forReading: false)
        let binding: OpenSwiftUICore.Binding<Value>
        if let location {
            binding = .init(value: value, location: location)
        } else {
            Log.runtimeIssues("Accessing AccessibilityFocusState's value outside of the body of a View. This will result in a constant Binding of the initial value and will not update.")
            binding = .constant(value)
        }
        return Binding(binding: binding)
    }

    public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<V>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        let box = Box(store: .init(inputs.accessibilityFocusStore), location: nil)
        buffer.append(box, fieldOffset: fieldOffset)
    }

    /// Creates a new accessibility focus state for a Boolean value.
    public init() where Value == Bool {
        value = false
        location = nil
        resetValue = false
    }

    /// Creates a new accessibility focus state for a Boolean value, using the accessibility
    /// technologies you specify.
    ///
    /// - Parameters:
    ///   - technologies: One of the available ``AccessibilityTechnologies``.
    public init(for technologies: AccessibilityTechnologies) where Value == Bool {
        self.init()
        technologies.assertAllSupportFocus()
        self.technologies = technologies
    }

    /// Creates a new accessibility focus state of the type you provide.
    public init<T>() where Value == T?, T: Hashable {
        value = nil
        location = nil
        resetValue = nil
    }

    /// Creates a new accessibility focus state of the type and
    /// using the accessibility technologies you specify.
    ///
    /// - Parameter technologies: One or more of the available
    ///  ``AccessibilityTechnologies``.
    public init<T>(for technologies: AccessibilityTechnologies) where Value == T?, T: Hashable {
        self.init()
        technologies.assertAllSupportFocus()
        self.technologies = technologies
    }

    private func getValue(forReading: Bool) -> Value {
        guard let location else {
            return value
        }
        if GraphHost.isUpdating {
            if forReading {
                location.wasRead = true
            }
            return value
        } else {
            return location.get()
        }
    }

    struct Box: DynamicPropertyBox {
        @OptionalAttribute var store: AccessibilityFocusStore?
        var location: AccessibilityFocusStoreLocation<Value>?

        mutating func reset() {
            location = nil
        }

        mutating func update(property: inout AccessibilityFocusState<Value>, phase: _GraphInputs.Phase) -> Bool {
            let oldLocation = location
            let newLocation: AccessibilityFocusStoreLocation<Value>
            if let oldLocation {
                newLocation = oldLocation
            } else {
                let technologies = property.technologies?.intersection(.focusSupportingTechnologies)
                    ?? .focusSupportingTechnologies
                newLocation = property.location as? AccessibilityFocusStoreLocation<Value>
                    ?? AccessibilityFocusStoreLocation(
                        host: .currentHost,
                        resetValue: property.resetValue,
                        technologies: technologies
                    )
                location = newLocation
            }
            newLocation.store = store ?? AccessibilityFocusStore()
            let (value, changed) = newLocation.update()
            property.value = value
            property.location = newLocation
            if $store?.changedValue().changed ?? true {
                newLocation.performDeferredUpdate()
            }
            return (changed && newLocation.wasRead) || oldLocation == nil
        }
    }
}

@available(*, unavailable)
extension AccessibilityFocusState.Binding: Sendable {}

@available(OpenSwiftUI_v3_0, *)
extension AccessibilityFocusState: Sendable where Value: Sendable {}

// MARK: - View + AccessibilityFocusState

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Modifies this view by binding its accessibility element's focus state to
    /// the given state value.
    ///
    /// - Parameters:
    ///   - binding: The state binding to register. When accessibility focus moves to the
    ///     accessibility element of the modified view, OpenSwiftUI sets the bound value to the corresponding
    ///     match value. If you set the state value programmatically to the matching value, then
    ///     accessibility focus moves to the accessibility element of the modified view. OpenSwiftUI sets
    ///     the value to `nil` if accessibility focus leaves the accessibility element associated with the
    ///     modified view, and programmatically setting the value to `nil` dismisses focus automatically.
    ///   - value: The value to match against when determining whether the
    ///     binding should change.
    /// - Returns: The modified view.
    nonisolated public func accessibilityFocused<Value>(
        _ binding: AccessibilityFocusState<Value>.Binding,
        equals value: Value
    ) -> some View where Value: Hashable {
        modifier(AccessibilityFocusBindingModifier(binding: binding, prototype: value))
    }

    /// Modifies this view by binding its accessibility element's focus state
    /// to the given boolean state value.
    ///
    /// - Parameter condition: The accessibility focus state to bind. When
    ///     accessibility focus moves to the accessibility element of the
    ///     modified view, the focus value is set to `true`.
    ///     If the value is set to `true` programmatically, then accessibility
    ///     focus will move to accessibility element of the modified view.
    ///     The value will be set to `false` if accessibility focus leaves
    ///     the accessibility element of the modified view,
    ///     and accessibility focus will be dismissed automatically if the
    ///     value is set to `false` programmatically.
    ///
    /// - Returns: The modified view.
    nonisolated public func accessibilityFocused(_ condition: AccessibilityFocusState<Bool>.Binding) -> some View {
        accessibilityFocused(condition, equals: true)
    }
}

// MARK: - AccessibilityFocusBindingModifier

private struct AccessibilityFocusBindingModifier<Value> where Value: Hashable {
    @AccessibilityFocusState<Value>.Binding var binding: Value
    var prototype: Value

    init(binding: AccessibilityFocusState<Value>.Binding, prototype: Value) {
        _binding = binding
        self.prototype = prototype
    }
}

extension AccessibilityFocusBindingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.modifier(AccessibilityFocusStoreListModifier(binding: $binding, prototype: prototype))
    }
}
