//
//  EnvironmentKeyTransformModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: 1DBD4F024EFF0E73A70DB6DD05D5B548 (SwiftUI)
//  ID: E370275CDB55AC7AD9ACF0420859A9E8 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - EnvironmentKeyTransformModifier

/// A view modifier that transforms the existing value of an
/// environment key.
@frozen
public struct _EnvironmentKeyTransformModifier<Value>: ViewModifier, _GraphInputsModifier, PrimitiveViewModifier {
    /// The environment key path to transform.
    public var keyPath: WritableKeyPath<EnvironmentValues, Value>
    
    /// A function to map the original value of the environment key to
    /// its new value.
    public var transform: (inout Value) -> Void
    
    @inlinable
    public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, transform: @escaping (inout Value) -> Void) {
        self.keyPath = keyPath
        self.transform = transform
    }
    
    public static func _makeInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) {
        let childEnvironment = Attribute(
            ChildEnvironment(
                modifier: modifier.value,
                environment: inputs.environment
            )
        )
        inputs.environment = childEnvironment
    }
}

@available(*, unavailable)
extension _EnvironmentKeyTransformModifier: Sendable {}

extension View {
    /// Transforms the environment value of the specified key path with the
    /// given function.
    @inlinable
    nonisolated public func transformEnvironment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        transform: @escaping (inout V) -> Void
    ) -> some View {
        modifier(_EnvironmentKeyTransformModifier(
            keyPath: keyPath,
            transform: transform
        ))
    }
}

// MARK: - ChildEnvironment [6.5.4]

private struct ChildEnvironment<Value>: StatefulRule, AsyncAttribute, CustomStringConvertible {
    @Attribute var modifier: _EnvironmentKeyTransformModifier<Value>
    @Attribute var environment: EnvironmentValues
    var oldValue: Value?
    var oldKeyPath: WritableKeyPath<EnvironmentValues, Value>?

    init(
        modifier: Attribute<_EnvironmentKeyTransformModifier<Value>>,
        environment: Attribute<EnvironmentValues>,
        oldValue: Value? = nil,
        oldKeyPath: WritableKeyPath<EnvironmentValues, Value>? = nil
    ) {
        _modifier = modifier
        _environment = environment
        self.oldValue = oldValue
        self.oldKeyPath = oldKeyPath
    }

    var description: String {
        "EnvironmentTransform: EnvironmentValues"
    }

    typealias Value = EnvironmentValues

    mutating func updateValue() {
        let (environment, environmentChanged) = $environment.changedValue()
        let newKeyPath = modifier.keyPath
        var newValue = environment[keyPath: newKeyPath]
        $modifier.syncMainIfReferences { modifier in
            withObservation {
                modifier.transform(&newValue)
            }
        }
        let valueChanged = if !environmentChanged {
            // SwiftUI implementation:
            // oldValue.map { compareValues($0, newValue, mode: .equatableUnlessPOD) } ?? true
            oldValue.map{ !compareValues($0, newValue, mode: .equatableUnlessPOD) } ?? true
        } else {
            true
        }
        let keyPathChanged = if !valueChanged {
            // SwiftUI implementation:
            // oldKeyPath.map { $0 === newKeyPath } ?? true
            oldKeyPath.map{ $0 !== newKeyPath } ?? true
        } else {
            true
        }
        if environmentChanged || valueChanged || keyPathChanged || !hasValue {
            var env = environment
            env[keyPath: newKeyPath] = newValue
            value = env
            oldValue = newValue
            oldKeyPath = newKeyPath
        }
    }
}

// MARK: - EnvironmentModifier

package protocol EnvironmentModifier: _GraphInputsModifier {
    static func makeEnvironment(modifier: Attribute<Self>, environment: inout EnvironmentValues)
}

extension EnvironmentModifier {
    package static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        let updateEnviroment = UpdateEnvironment(
            modifier: modifier.value,
            environment: inputs.cachedEnvironment.wrappedValue.environment
        )
        inputs.environment = Attribute(updateEnviroment)
    }
}

private struct UpdateEnvironment<Modifier>: Rule where Modifier: EnvironmentModifier {
    @Attribute var modifier: Modifier
    @Attribute var environment: EnvironmentValues
    
    var value: EnvironmentValues {
        var environment = environment
        Modifier.makeEnvironment(modifier: $modifier, environment: &environment)
        return environment
    }
}
