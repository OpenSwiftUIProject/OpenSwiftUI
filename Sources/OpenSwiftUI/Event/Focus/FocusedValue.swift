//
//  FocusedValue.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B1EDB9B13C46E98882FF0F0DFA69F617 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore

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

// MARK: - FocusedBinding

/// A convenience property wrapper for observing and automatically unwrapping
/// state bindings from the focused view or one of its ancestors.
///
/// If multiple views publish bindings using the same key, the wrapped property
/// will reflect the value of the binding from the view closest to focus.
@available(OpenSwiftUI_v2_0, *)
@propertyWrapper
public struct FocusedBinding<Value>: DynamicProperty {
    @usableFromInline
    @frozen
    internal enum Content {
        case keyPath(KeyPath<FocusedValues, Binding<Value>?>)
        case value(Binding<Value>?)
    }

    @usableFromInline
    internal var content: FocusedBinding<Value>.Content

    /// A new property wrapper for the given key path.
    ///
    /// The value of the property wrapper is updated dynamically as focus
    /// changes and different published bindings go in and out of scope.
    ///
    /// - Parameter keyPath: The key path for the focus value to read.
    public init(_ keyPath: KeyPath<FocusedValues, Binding<Value>?>) {
        content = .keyPath(keyPath)
    }

    /// The unwrapped value for the focus key given the current scope and state
    /// of the focused view hierarchy.
    @inlinable
    public var wrappedValue: Value? {
        get {
            if case .value(let value) = content {
                return value?.wrappedValue
            } else {
                return nil
            }
        }
        nonmutating set {
            if case .value(let value) = content, let newValue = newValue {
                value?.wrappedValue = newValue
            }
        }
    }

    /// A binding to the optional value.
    ///
    /// The unwrapped value is `nil` when no focused view hierarchy has
    /// published a corresponding binding.
    public var projectedValue: Binding<Value?> {
        if case let .value(value?) = content {
            return Binding(value)
        } else {
            return .constant(nil)
        }
    }

    public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<V>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        // Content has the same layout as FocusedValue<Binding<Value>>.Content.
        let box = FocusedValueBox<Binding<Value>>(
            environment: inputs.environment,
            focusedValues: inputs[FocusedValuesInputKey.self]
        )
        buffer.append(box, fieldOffset: fieldOffset)
    }
}

@available(*, unavailable)
extension FocusedBinding: Sendable {}

@available(*, unavailable)
extension FocusedBinding.Content: Sendable {}

// MARK: - View + Focused Values

extension View {

    /// Modifies this view by injecting a value that you provide for use by
    /// other views whose state depends on the focused view hierarchy.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to associate `value` with when adding
    ///     it to the existing table of exported focus values.
    ///   - value: The focus value to export.
    /// - Returns: A modified representation of this view.
    @available(OpenSwiftUI_v2_0, *)
    nonisolated public func focusedValue<Value>(
        _ keyPath: WritableKeyPath<FocusedValues, Value?>,
        _ value: Value
    ) -> some View {
        modifier(ResponderViewModifier { responder in
            FocusedValueModifier(
                keyPath: keyPath,
                value: .some(.some(value)),
                responder: responder,
                isSceneValue: false
            )
        })
    }

    /// Creates a new view that exposes the provided value to other views whose
    /// state depends on the focused view hierarchy.
    ///
    /// Use this method instead of ``View/focusedSceneValue(_:_:)`` when your
    /// scene includes multiple focusable views with their own associated
    /// values, and you need an app- or scene-scoped element like a command or
    /// toolbar item that operates on the value associated with whichever view
    /// currently has focus. Each focusable view can supply its own value.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to associate `value` with when adding
    ///     it to the existing table of exported focus values.
    ///   - value: The focus value to export, or `nil` if no value is
    ///     currently available.
    /// - Returns: A modified representation of this view.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func focusedValue<Value>(
        _ keyPath: WritableKeyPath<FocusedValues, Value?>,
        _ value: Value?
    ) -> some View {
        modifier(ResponderViewModifier { responder in
            FocusedValueModifier(
                keyPath: keyPath,
                value: .some(value),
                responder: responder,
                isSceneValue: false
            )
        })
    }

    /// Modifies this view by injecting a value that you provide for use by
    /// other views whose state depends on the focused scene.
    ///
    /// Use this method instead of ``View/focusedValue(_:_:)`` for values that
    /// must be visible regardless of where focus is located in the active
    /// scene. For example, if an app needs a command for moving focus to a
    /// particular text field in the sidebar, it could use this modifier to
    /// publish a button action that's visible to command views as long as the
    /// scene is active, and regardless of where focus happens to be in it.
    ///
    ///     struct Sidebar: View {
    ///         @FocusState var isFiltering: Bool
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 TextField(...)
    ///                     .focused($isFiltering)
    ///                     .focusedSceneValue(\.filterAction) {
    ///                         isFiltering = true
    ///                     }
    ///             }
    ///         }
    ///     }
    ///
    ///     struct NavigationCommands: Commands {
    ///         @FocusedValue(\.filterAction) var filterAction
    ///
    ///         var body: some Commands {
    ///             CommandMenu("Navigate") {
    ///                 Button("Filter in Sidebar") {
    ///                     filterAction?()
    ///                 }
    ///             }
    ///             .disabled(filterAction == nil)
    ///         }
    ///     }
    ///
    ///     struct FilterActionKey: FocusedValueKey {
    ///         typealias Value = () -> Void
    ///     }
    ///
    ///     extension FocusedValues {
    ///         var filterAction: (() -> Void)? {
    ///             get { self[FilterActionKey.self] }
    ///             set { self[FilterActionKey.self] = newValue }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - keyPath: The key path to associate `value` with when adding
    ///     it to the existing table of published focus values.
    ///   - value: The focus value to publish.
    /// - Returns: A modified representation of this view.
    @available(OpenSwiftUI_v3_0, *)
    nonisolated public func focusedSceneValue<T>(
        _ keyPath: WritableKeyPath<FocusedValues, T?>,
        _ value: T
    ) -> some View {
        modifier(ResponderViewModifier { responder in
            FocusedValueModifier(
                keyPath: keyPath,
                value: .some(.some(value)),
                responder: responder,
                isSceneValue: true
            )
        })
    }

    /// Creates a new view that exposes the provided value to other views whose
    /// state depends on the active scene.
    ///
    /// Use this method instead of ``View/focusedValue(_:_:)`` for values that
    /// must be visible regardless of where focus is located in the active
    /// scene. For example, if an app needs a command for moving focus to a
    /// particular text field in the sidebar, it could use this modifier to
    /// publish a button action that's visible to command views as long as the
    /// scene is active, and regardless of where focus happens to be in it.
    ///
    ///     struct Sidebar: View {
    ///         @FocusState var isFiltering: Bool
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 TextField(...)
    ///                     .focused($isFiltering)
    ///                     .focusedSceneValue(\.filterAction) {
    ///                         isFiltering = true
    ///                     }
    ///             }
    ///         }
    ///     }
    ///
    ///     struct NavigationCommands: Commands {
    ///         @FocusedValue(\.filterAction) var filterAction
    ///
    ///         var body: some Commands {
    ///             CommandMenu("Navigate") {
    ///                 Button("Filter in Sidebar") {
    ///                     filterAction?()
    ///                 }
    ///             }
    ///             .disabled(filterAction == nil)
    ///         }
    ///     }
    ///
    ///     struct FilterActionKey: FocusedValueKey {
    ///         typealias Value = () -> Void
    ///     }
    ///
    ///     extension FocusedValues {
    ///         var filterAction: (() -> Void)? {
    ///             get { self[FilterActionKey.self] }
    ///             set { self[FilterActionKey.self] = newValue }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - keyPath: The key path to associate `value` with when adding
    ///     it to the existing table of published focus values.
    ///   - value: The focus value to publish, or `nil` if no value is
    ///     currently available.
    /// - Returns: A modified representation of this view.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func focusedSceneValue<T>(
        _ keyPath: WritableKeyPath<FocusedValues, T?>,
        _ value: T?
    ) -> some View {
        modifier(ResponderViewModifier { responder in
            FocusedValueModifier(
                keyPath: keyPath,
                value: .some(value),
                responder: responder,
                isSceneValue: true
            )
        })
    }

}

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

// MARK: - FocusedValueModifier

private struct FocusedValueModifier<Value>: MultiViewModifier, PrimitiveViewModifier {
    let keyPath: WritableKeyPath<FocusedValues, Value>
    let value: Value?
    let responder: ResponderNode
    var isSceneValue: Bool

    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: FocusedValueList.Key.self,
            transform: Attribute(Transform<Value>(
                viewPhase: inputs.viewPhase,
                modifier: modifier.value,
                depth: inputs[NavigationAuthority.DepthKey.self],
                focusItem: .init(inputs.focusedItem),
                updateSeed: GraphHost.currentHost.data.$updateSeed
            ))
        )
        return outputs
    }
}

// MARK: - FocusedValueList.Item

extension FocusedValueList {
    struct Item {
        var version: DisplayList.Version
        var isFocused: Bool
        var update: (inout FocusedValues) -> Void
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

// MARK: - FocusedValueList

struct FocusedValueList {
    var items: [Item] = []

    var version: DisplayList.Version {
        items.reduce(DisplayList.Version()) { max($0, $1.version) }
    }
}

// MARK: - FocusedValueModifier.Transform

extension FocusedValueModifier {
    struct Transform<Content>: StatefulRule {
        @Attribute var viewPhase: ViewPhase
        @Attribute var modifier: FocusedValueModifier<Content>
        @Attribute var depth: Int
        @OptionalAttribute var focusItem: FocusItem??
        @Attribute var updateSeed: UInt32
        var resetSeed: UInt32?
        var content: Content?
        var isFocused: Bool = false
        var lastUpdateSeed: UInt32 = .max
        var ttl: UInt32 = 0

        typealias Value = (inout FocusedValueList) -> Void

        mutating func updateValue() {
            let (modifier, modifierChanged) = $modifier.changedValue()
            var changed = resetSeed != viewPhase.resetSeed
            if changed {
                resetSeed = viewPhase.resetSeed
                lastUpdateSeed = 0
                ttl = 0
            }
            if lastUpdateSeed != updateSeed {
                lastUpdateSeed = updateSeed
                ttl = 2
            } else {
                if ttl != 0 {
                    ttl -= 1
                }
                if ttl == 0, hasValue {
                    return
                }
            }
            if modifierChanged, content == nil || !compareValues(content, modifier.value) {
                content = modifier.value
                changed = true
            }
            let isFocused = (focusItem ?? nil)?.responder?.isDescendant(of: modifier.responder) ?? false
            if self.isFocused != isFocused {
                self.isFocused = isFocused
                changed = true
            }
            guard changed || !hasValue else {
                return
            }
            let version = DisplayList.Version(forUpdate: ())
            let depth = depth
            let item = FocusedValueList.Item(version: version, isFocused: isFocused) { values in
                guard let value = modifier.value else {
                    return
                }
                var options: FocusedValues.StorageOptions = []
                if modifier.isSceneValue {
                    values.navigationDepth = depth
                    options.insert(.scene)
                }
                if isFocused {
                    options.insert(.inFocusedViewHierarchy)
                }
                values.storageOptions = options
                values[keyPath: modifier.keyPath] = value
            }
            value = { list in
                list.items.append(item)
            }
        }
    }
}

// MARK: - FocusedValueList.Key

extension FocusedValueList {
    struct Key: HostPreferenceKey {
        static var defaultValue: FocusedValueList { .init() }

        static func reduce(value: inout FocusedValueList, nextValue: () -> FocusedValueList) {
            value.items.append(contentsOf: nextValue().items)
        }
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
