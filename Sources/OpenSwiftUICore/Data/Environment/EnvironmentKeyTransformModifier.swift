//
//  EnvironmentKeyTransformModifier.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by Observation
//  ID: 1DBD4F024EFF0E73A70DB6DD05D5B548 (SwiftUI)
//  ID: E370275CDB55AC7AD9ACF0420859A9E8 (SwiftUICore)

package import OpenGraphShims

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
    
    public static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        let childEnvironment = ChildEnvironment(
            modifier: modifier.value,
            environment: inputs.cachedEnvironment.wrappedValue.environment,
            oldValue: nil,
            oldKeyPath: nil
        )
        inputs.environment = Attribute(childEnvironment)
    }
}

private struct ChildEnvironment<Value>: StatefulRule, AsyncAttribute, CustomStringConvertible {
    @Attribute private var modifier: _EnvironmentKeyTransformModifier<Value>
    @Attribute private var environment: EnvironmentValues
    private var oldValue: Value?
    private var oldKeyPath: WritableKeyPath<EnvironmentValues, Value>?
    
    init(
        modifier: Attribute<_EnvironmentKeyTransformModifier<Value>>,
        environment: Attribute<EnvironmentValues>,
        oldValue: Value?,
        oldKeyPath: WritableKeyPath<EnvironmentValues, Value>?
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
    
    // FIXME
    mutating func updateValue() {
        var (environment, environmentChanged) = _environment.changedValue()
        let keyPath = modifier.keyPath
        var newValue = environment[keyPath: keyPath]
        $modifier.syncMainIfReferences { modifier in
            // TODO: Observation
            modifier.transform(&newValue)
        }
        guard !environmentChanged,
              let valueChanged = oldValue.map({ compareValues($0, newValue, mode: .equatableUnlessPOD) }), !valueChanged,
              let keyPathChanged = oldKeyPath.map({ $0 == keyPath }), !keyPathChanged,
              hasValue
        else {
            environment[keyPath: keyPath] = newValue
            value = environment
            oldValue = newValue
            oldKeyPath = keyPath
            return
        }
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
