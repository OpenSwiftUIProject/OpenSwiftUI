//
//  EnvironmentKeyWritingModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3B04936F6043A290A3E53AE94FE09355 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: EnvironmentKeyWritingModifier

/// A modifier that sets a value for an environment keyPath.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _EnvironmentKeyWritingModifier<Value>: ViewModifier, _GraphInputsModifier, PrimitiveViewModifier {

    /// The environment keyPath to set.
    public var keyPath: WritableKeyPath<EnvironmentValues, Value>

    /// The environment value to set for `keyPath`.
    public var value: Value

    /// Creates an instance that sets a `value` for an environment `keyPath`.
    @inlinable
    public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
        self.keyPath = keyPath
        self.value = value
    }

    public static func _makeInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) {
        let childEnvironment = Attribute(
            ChildEnvironment(
                modifier: modifier.value,
                env: inputs.environment
            )
        )
        inputs.environment = childEnvironment
    }
}

@available(*, unavailable)
extension _EnvironmentKeyWritingModifier: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Sets the environment value of the specified key path to the given value.
    ///
    /// Use this modifier to set one of the writable properties of the
    /// ``EnvironmentValues`` structure, including custom values that you
    /// create. For example, you can set the value associated with the
    /// ``EnvironmentValues/truncationMode`` key:
    ///
    ///     MyView()
    ///         .environment(\.truncationMode, .head)
    ///
    /// You then read the value inside `MyView` or one of its descendants
    /// using the ``Environment`` property wrapper:
    ///
    ///     struct MyView: View {
    ///         @Environment(\.truncationMode) var truncationMode: Text.TruncationMode
    ///
    ///         var body: some View { ... }
    ///     }
    ///
    /// OpenSwiftUI provides dedicated view modifiers for setting most
    /// environment values, like the ``View/truncationMode(_:)``
    /// modifier which sets the ``EnvironmentValues/truncationMode`` value:
    ///
    ///     MyView()
    ///         .truncationMode(.head)
    ///
    /// Prefer the dedicated modifier when available, and offer your own when
    /// defining custom environment values, as described in
    /// ``Entry()``.
    ///
    /// This modifier affects the given view,
    /// as well as that view's descendant views. It has no effect
    /// outside the view hierarchy on which you call it.
    ///
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property of the
    ///     ``EnvironmentValues`` structure to update.
    ///   - value: The new value to set for the item specified by `keyPath`.
    ///
    /// - Returns: A view that has the given value set in its environment.
    @inlinable
    nonisolated public func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V) -> some View {
        modifier(_EnvironmentKeyWritingModifier(keyPath: keyPath, value: value))
    }
}

// MARK: - ChildEnvironment

private struct ChildEnvironment<Value>: StatefulRule, AsyncAttribute, CustomStringConvertible {
    @Attribute var modifier: _EnvironmentKeyWritingModifier<Value>
    @Attribute var env: EnvironmentValues
    var oldModifier: _EnvironmentKeyWritingModifier<Value>?

    init(
        modifier: Attribute<_EnvironmentKeyWritingModifier<Value>>,
        env: Attribute<EnvironmentValues>,
        oldModifier: _EnvironmentKeyWritingModifier<Value>? = nil
    ) {
        self._modifier = modifier
        self._env = env
        self.oldModifier = oldModifier
    }

    var description: String {
        "EnvironmentWriting: \(Value.self)"
    }

    typealias Value = EnvironmentValues

    mutating func updateValue() {
        let (modifier, modifierChanged) = $modifier.changedValue()
        let (environment, environmentChanged) = $env.changedValue()
        let modifierValueChanged: Bool
        if !environmentChanged, modifierChanged {
            modifierValueChanged = oldModifier.map { oldModifier in
                !(oldModifier.keyPath == modifier.keyPath && compareValues(oldModifier.value, modifier.value, mode: .equatableUnlessPOD))
            } ?? true
        } else {
            modifierValueChanged = false
        }

        if environmentChanged || modifierValueChanged || !hasValue {
            var env = environment
            env[keyPath: modifier.keyPath] = modifier.value
            value = env
            oldModifier = modifier
        }
    }
}
