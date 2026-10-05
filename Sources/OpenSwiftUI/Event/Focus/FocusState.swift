//
//  FocusState.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 274D264A38B51DC68ACC48A91353B7D0 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - FocusState

/// A property wrapper type that can read and write a value that OpenSwiftUI updates
/// as the placement of focus within the scene changes.
///
/// Use this property wrapper in conjunction with ``View/focused(_:equals:)``
/// and ``View/focused(_:)`` to
/// describe views whose appearance and contents relate to the location of
/// focus in the scene. When focus enters the modified view, the wrapped value
/// of this property updates to match a given prototype value. Similarly, when
/// focus leaves, the wrapped value of this property resets to `nil`
/// or `false`. Setting the property's value programmatically has the reverse
/// effect, causing focus to move to the view associated with the
/// updated value.
///
/// In the following example of a simple login screen, when the user presses the
/// Sign In button and one of the fields is still empty, focus moves to that
/// field. Otherwise, the sign-in process proceeds.
///
///     struct LoginForm: View {
///         enum Field: Hashable {
///             case username
///             case password
///         }
///
///         @State private var username = ""
///         @State private var password = ""
///         @FocusState private var focusedField: Field?
///
///         var body: some View {
///             Form {
///                 TextField("Username", text: $username)
///                     .focused($focusedField, equals: .username)
///
///                 SecureField("Password", text: $password)
///                     .focused($focusedField, equals: .password)
///
///                 Button("Sign In") {
///                     if username.isEmpty {
///                         focusedField = .username
///                     } else if password.isEmpty {
///                         focusedField = .password
///                     } else {
///                         handleLogin(username, password)
///                     }
///                 }
///             }
///         }
///     }
///
/// To allow for cases where focus is completely absent from a view tree, the
/// wrapped value must be either an optional or a Boolean. Set the focus binding
/// to `false` or `nil` as appropriate to remove focus from all bound fields.
/// You can also use this to remove focus from a ``TextField`` and thereby
/// dismiss the keyboard.
///
/// ### Avoid ambiguous focus bindings
///
/// The same view can have multiple focus bindings. In the following example,
/// setting `focusedField` to either `name` or `fullName` causes the field
/// to receive focus:
///
///     struct ContentView: View {
///         enum Field: Hashable {
///             case name
///             case fullName
///         }
///         @FocusState private var focusedField: Field?
///
///         var body: some View {
///             TextField("Full Name", ...)
///                 .focused($focusedField, equals: .name)
///                 .focused($focusedField, equals: .fullName)
///         }
///     }
///
/// On the other hand, binding the same value to two views is ambiguous. In
/// the following example, two separate fields bind focus to the `name` value:
///
///     struct ContentView: View {
///         enum Field: Hashable {
///             case name
///             case fullName
///         }
///         @FocusState private var focusedField: Field?
///
///         var body: some View {
///             TextField("Name", ...)
///                 .focused($focusedField, equals: .name)
///             TextField("Full Name", ...)
///                 .focused($focusedField, equals: .name) // incorrect re-use of .name
///         }
///     }
///
/// If the user moves focus to either field, the `focusedField` binding updates
/// to `name`. However, if the app programmatically sets the value to `name`,
/// OpenSwiftUI chooses the first candidate, which in this case is the "Name"
/// field. OpenSwiftUI also emits a runtime warning in this case, since the repeated
/// binding is likely a programmer error.
///
@available(OpenSwiftUI_v3_0, *)
@frozen
@propertyWrapper
public struct FocusState<Value>: DynamicProperty where Value: Hashable {
    /// A property wrapper type that can read and write a value that indicates
    /// the current focus location.
    @frozen
    @propertyWrapper
    public struct Binding {
        @OpenSwiftUICore.Binding
        private var binding: Value

        init(binding: OpenSwiftUICore.Binding<Value>) {
            _binding = binding
        }

        /// The underlying value referenced by the bound property.
        public var wrappedValue: Value {
            get { binding }
            nonmutating set { binding = newValue }
        }

        /// A projection of the binding value that returns a binding.
        ///
        /// Use the projected value to pass a binding value down a view
        /// hierarchy.
        public var projectedValue: FocusState<Value>.Binding {
            self
        }

        var location: FocusStoreLocation<Value> {
            _binding.location as! FocusStoreLocation<Value>
        }

        var propertyID: ObjectIdentifier {
            if let location = _binding.location as? FocusStoreLocation<Value> {
                location.id
            } else {
                ObjectIdentifier(PrivateType.self)
            }
        }

        private enum PrivateType {}
    }

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

    /// A projection of the focus state value that returns a binding.
    ///
    /// When focus is outside any view that is bound to this state, the wrapped
    /// value is `nil` for optional-typed state or `false` for Boolean state.
    ///
    /// In the following example of a simple navigation sidebar, when the user
    /// presses the Filter Sidebar Contents button, focus moves to the sidebar's
    /// filter text field. Conversely, if the user moves focus to the sidebar's
    /// filter manually, then the value of `isFiltering` automatically
    /// becomes `true`, and the sidebar view updates.
    ///
    ///     struct Sidebar: View {
    ///         @State private var filterText = ""
    ///         @FocusState private var isFiltering: Bool
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Button("Filter Sidebar Contents") {
    ///                     isFiltering = true
    ///                 }
    ///
    ///                 TextField("Filter", text: $filterText)
    ///                     .focused($isFiltering)
    ///             }
    ///         }
    ///     }
    public var projectedValue: FocusState<Value>.Binding {
        let value = getValue(forReading: false)
        let binding: OpenSwiftUICore.Binding<Value>
        if let location {
            binding = .init(value: value, location: location)
        } else {
            Log.runtimeIssues("Accessing FocusState's value outside of the body of a View. This will result in a constant Binding of the initial value and will not update.")
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
        let box = Box(
            store: .init(inputs.focusStore),
            focusedItem: .init(inputs.focusedItem),
            location: nil
        )
        buffer.append(box, fieldOffset: fieldOffset)
    }

    /// Creates a focus state that binds to a Boolean.
    public init() where Value == Bool {
        value = false
        location = nil
        resetValue = false
    }

    /// Creates a focus state that binds to an optional type.
    public init<T>() where Value == T?, T: Hashable {
        value = nil
        location = nil
        resetValue = nil
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
        @OptionalAttribute var store: FocusStore?
        @OptionalAttribute var focusedItem: FocusItem??
        var location: FocusStoreLocation<Value>?

        mutating func reset() {
            location = nil
        }

        mutating func update(property: inout FocusState<Value>, phase: _GraphInputs.Phase) -> Bool {
            let oldLocation = location
            let newLocation: FocusStoreLocation<Value>
            if let oldLocation {
                newLocation = oldLocation
            } else {
                newLocation = property.location as? FocusStoreLocation<Value>
                    ?? FocusStoreLocation(host: .currentHost, resetValue: property.resetValue)
                location = newLocation
            }
            newLocation.store = store ?? FocusStore()
            newLocation.focusSeed = (focusedItem ?? nil)?.seed ?? .empty
            let (value, changed) = newLocation.update()
            property.value = value
            property.location = newLocation
            if $store?.changedValue().changed ?? true {
                #if os(macOS)
                onNextMainRunLoop { [weak newLocation] in
                    newLocation?.performDeferredUpdate()
                }
                #else
                newLocation.performDeferredUpdate()
                #endif
            }
            return (changed && newLocation.wasRead) || oldLocation == nil
        }
    }
}

@available(*, unavailable)
extension FocusState: Sendable {}

@available(*, unavailable)
extension FocusState.Binding: Sendable {}

// MARK: - View + Focus State

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Modifies this view by binding its focus state to the given state value.
    ///
    /// Use this modifier to cause the view to receive focus whenever
    /// the `binding` equals the `value`. Typically, you create an enumeration
    /// of fields that may receive focus, bind an instance of this enumeration,
    /// and assign its cases to focusable views.
    ///
    /// The following example uses the cases of a `LoginForm` enumeration to
    /// bind the focus state of two ``TextField`` views. A sign-in button
    /// validates the fields and sets the bound `focusedField` value to
    /// any field that requires the user to correct a problem.
    ///
    ///     struct LoginForm: View {
    ///         enum Field: Hashable {
    ///             case usernameField
    ///             case passwordField
    ///         }
    ///
    ///         @State private var username = ""
    ///         @State private var password = ""
    ///         @FocusState private var focusedField: Field?
    ///
    ///         var body: some View {
    ///             Form {
    ///                 TextField("Username", text: $username)
    ///                     .focused($focusedField, equals: .usernameField)
    ///
    ///                 SecureField("Password", text: $password)
    ///                     .focused($focusedField, equals: .passwordField)
    ///
    ///                 Button("Sign In") {
    ///                     if username.isEmpty {
    ///                         focusedField = .usernameField
    ///                     } else if password.isEmpty {
    ///                         focusedField = .passwordField
    ///                     } else {
    ///                         handleLogin(username, password)
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// To control focus using a Boolean, use the ``View/focused(_:)`` method
    /// instead.
    ///
    /// - Parameters:
    ///   - binding: The state binding to register. When focus moves to the
    ///     modified view, the binding sets the bound value to the corresponding
    ///     match value. If a caller sets the state value programmatically to the
    ///     matching value, then focus moves to the modified view. When focus
    ///     leaves the modified view, the binding sets the bound value to
    ///     `nil`. If a caller sets the value to `nil`, OpenSwiftUI automatically
    ///     dismisses focus.
    ///   - value: The value to match against when determining whether the
    ///     binding should change.
    /// - Returns: The modified view.
    nonisolated public func focused<Value>(
        _ binding: FocusState<Value>.Binding,
        equals value: Value
    ) -> some View where Value: Hashable {
        modifier(FocusStateBindingModifier(binding: binding, value: value))
    }

    /// Modifies this view by binding its focus state to the given Boolean state
    /// value.
    ///
    /// Use this modifier to cause the view to receive focus whenever
    /// the `condition` value is `true`. You can use this modifier to
    /// observe the focus state of a single view, or programmatically set and
    /// remove focus from the view.
    ///
    /// In the following example, a single ``TextField`` accepts a user's
    /// desired `username`. The text field binds its focus state to the
    /// Boolean value `usernameFieldIsFocused`. A "Submit" button's action
    /// verifies whether the name is available. If the name is unavailable, the
    /// button sets `usernameFieldIsFocused` to `true`, which causes focus to
    /// return to the text field, so the user can enter a different name.
    ///
    ///     @State private var username: String = ""
    ///     @FocusState private var usernameFieldIsFocused: Bool
    ///     @State private var showUsernameTaken = false
    ///
    ///     var body: some View {
    ///         VStack {
    ///             TextField("Choose a username.", text: $username)
    ///                 .focused($usernameFieldIsFocused)
    ///             if showUsernameTaken {
    ///                 Text("That username is taken. Please choose another.")
    ///             }
    ///             Button("Submit") {
    ///                 showUsernameTaken = false
    ///                 if !isUserNameAvailable(username: username) {
    ///                     usernameFieldIsFocused = true
    ///                     showUsernameTaken = true
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// To control focus by matching a value, use the
    /// ``View/focused(_:equals:)`` method instead.
    ///
    /// - Parameter condition: The focus state to bind. When focus moves
    ///   to the view, the binding sets the bound value to `true`. If a caller
    ///   sets the value to  `true` programmatically, then focus moves to the
    ///   modified view. When focus leaves the modified view, the binding
    ///   sets the value to `false`. If a caller sets the value to `false`,
    ///   OpenSwiftUI automatically dismisses focus.
    ///
    /// - Returns: The modified view.
    nonisolated public func focused(_ condition: FocusState<Bool>.Binding) -> some View {
        focused(condition, equals: true)
    }
}

// MARK: - FocusStateBindingResponder [WIP]

class FocusStateBindingResponder: DefaultLayoutViewResponder, BaseFocusResponder {
    weak var focusBridge: FocusBridge?
    var focusScopes: [Namespace.ID] = []

    #if os(iOS) || os(visionOS)
    var transform = ViewTransform()
    var size: CGSize = .zero
    var isEnabled: Bool = true
    var _uikitFocusItem: UIKitContainerFocusResponderItem<FocusStateBindingResponder>?
    #else
    var isEnabled: Bool {
        #if os(macOS)
        // Deleted in the target image.
        _openSwiftUIUnreachableCode()
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }
    #endif

    var platformItem: PlatformFocusItem? {
        #if os(macOS)
        // Deleted in the target image.
        _openSwiftUIUnreachableCode()
        #elseif os(iOS) || os(visionOS)
        hostedItem
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }

    var viewItem: FocusItem.ViewItem? {
        #if os(macOS)
        nil
        #elseif os(iOS) || os(visionOS)
        // Deleted in the target image.
        _openSwiftUIUnreachableCode()
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }

    var frame: CGRect? {
        #if os(macOS)
        nil
        #elseif os(iOS) || os(visionOS)
        // Deleted in the target image.
        _openSwiftUIUnreachableCode()
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }

    #if os(macOS)
    var effectiveLayoutDirection: LayoutDirection? { nil }

    var firstKeyViewInSubtree: PlatformView? {
        get { nil }
        set { _openSwiftUIEmptyStub() }
    }

    var lastKeyViewInSubtree: PlatformView? {
        get { nil }
        set { _openSwiftUIEmptyStub() }
    }
    #endif

    #if os(iOS) || os(visionOS)
    var focusGroupID: FocusGroupIdentifier? {
        // Deleted in the target image.
        _openSwiftUIUnreachableCode()
    }
    #endif
}

#if os(iOS) || os(visionOS)
extension FocusStateBindingResponder: AnyUIKitHostedFocusItemResponder {
    var hostedItem: (any AnyUIKitHostedFocusItem)? {
        if _uikitFocusItem == nil {
            _uikitFocusItem = UIKitContainerFocusResponderItem(self)
        }
        return _uikitFocusItem
    }
}
#endif

// MARK: - FocusStateBindingModifier [WIP]

private struct FocusStateBindingModifier<Value>: MultiViewModifier, PrimitiveViewModifier where Value: Hashable {
    var binding: FocusState<Value>.Binding
    var value: Value

    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        guard inputs.preferences.requiresViewResponders else {
            return outputs
        }
        let responder = FocusStateBindingResponder(inputs: inputs)
        let filter = Attribute(FocusStateBindingResponderFilter(
            inputs: inputs,
            outputs: outputs,
            responder: responder
        ))
        let list = Attribute(ListItemFilter(
            modifier: modifier.value,
            responder: responder,
            focusItem: .init(inputs.focusedItem),
            focusBridge: inputs.base.focusBridge,
            focusScopes: inputs.base.focusScopes,
            isFocused: false
        ))
        #if os(iOS) || os(visionOS)
        let lifecycle = Attribute(UIKitHostedFocusItemLifecycle(inputs: inputs, responder: filter))
        lifecycle.flags = [.removable, .transactional]
        #endif
        outputs.preferences.viewResponders = filter
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: FocusStoreList.Key.self,
            transform: Attribute(ListTransform(list: list))
        )
        return outputs
    }

    struct ListTransform: Rule {
        @Attribute var list: FocusStoreList

        var value: (inout FocusStoreList) -> Void {
            let list = list
            return { $0.append(contentsOf: list) }
        }
    }

    struct ListItemFilter: StatefulRule {
        @Attribute var modifier: FocusStateBindingModifier
        var responder: FocusStateBindingResponder
        @OptionalAttribute var focusItem: FocusItem??
        @Attribute var focusBridge: FocusBridge?
        @Attribute var focusScopes: [Namespace.ID]
        var isFocused: Bool

        typealias Value = FocusStoreList

        mutating func updateValue() {
            let (_, modifierChanged) = $modifier.changedValue()
            let (scopes, scopesChanged) = $focusScopes.changedValue()
            let newIsFocused = (focusItem ?? nil)?.responder?.isDescendant(of: responder) ?? false
            let focusChanged = newIsFocused != isFocused
            isFocused = newIsFocused
            guard focusChanged || modifierChanged || scopesChanged || !hasValue else {
                return
            }
            let bindingUpdateAction = FocusStateBindingUpdateAction(
                binding: modifier.binding,
                value: modifier.value
            )
            let storeUpdateAction = FocusStoreUpdateAction(
                value: modifier.value,
                responder: responder,
                bridge: focusBridge,
                focusScopes: scopes
            )
            value = FocusStoreList(items: [.init(
                version: .init(forUpdate: ()),
                propertyID: modifier.binding.propertyID,
                bindingUpdateAction: bindingUpdateAction,
                storeUpdateAction: storeUpdateAction,
                responder: responder,
                bridge: nil,
                isFocused: isFocused
            )])
        }
    }
}

// MARK: - EnvironmentValues + Focus Bridge

private struct FocusBridgeKey: EnvironmentKey {
    static var defaultValue: WeakBox<FocusBridge> { .init() }
}

extension EnvironmentValues {
    var focusBridge: FocusBridge? {
        get { self[FocusBridgeKey.self].base }
        set { self[FocusBridgeKey.self] = WeakBox(newValue) }
    }
}

extension CachedEnvironment.ID {
    fileprivate static let focusBridge: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    var focusBridge: Attribute<FocusBridge?> {
        mapEnvironment(id: .focusBridge) { $0.focusBridge }
    }
}

// MARK: - FocusStateBindingResponderFilter

private struct FocusStateBindingResponderFilter: StatefulRule {
    @Attribute var children: [ViewResponder]
    @Attribute var focusBridge: FocusBridge?
    @Attribute var focusScopes: [Namespace.ID]
    let responder: FocusStateBindingResponder
    #if os(iOS) || os(visionOS)
    @Attribute var transform: ViewTransform
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var isEnabled: Bool
    #endif

    init(inputs: _ViewInputs, outputs: _ViewOutputs, responder: FocusStateBindingResponder) {
        _children = outputs.viewResponders()
        _focusBridge = inputs.base.focusBridge
        _focusScopes = inputs.base.focusScopes
        self.responder = responder
        #if os(iOS) || os(visionOS)
        _transform = inputs.transform
        _position = inputs.animatedPosition()
        _size = inputs.animatedSize()
        _isEnabled = inputs.base.isEnabled
        #endif
    }

    typealias Value = [ViewResponder]

    mutating func updateValue() {
        responder.updateChildren($children.changedValue())
        responder.focusBridge = focusBridge
        responder.focusScopes = focusScopes
        #if os(iOS) || os(visionOS)
        let (position, positionChanged) = $position.changedValue()
        let (transform, transformChanged) = $transform.changedValue()
        let (size, sizeChanged) = $size.changedValue()
        let (isEnabled, isEnabledChanged) = $isEnabled.changedValue()
        if positionChanged || transformChanged || sizeChanged || isEnabledChanged || !hasValue {
            var transform = transform
            transform.appendPosition(position)
            responder.transform = transform
            responder.size = size.value
            responder.isEnabled = isEnabled
        }
        #endif
        if !hasValue {
            value = [responder]
        }
    }
}
