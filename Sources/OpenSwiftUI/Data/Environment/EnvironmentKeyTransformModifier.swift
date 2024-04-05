//
//  EnvironmentKeyTransformModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Blocked by syncMainIfReferences
//  ID: 1DBD4F024EFF0E73A70DB6DD05D5B548

internal import OpenGraphShims

@frozen
public struct _EnvironmentKeyTransformModifier<Value>: PrimitiveViewModifier, _GraphInputsModifier {
    public var keyPath: WritableKeyPath<EnvironmentValues, Value>
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
            oldKeyPath: nil
        )
        let attribute = Attribute(childEnvironment)
        let cachedEnvironment = CachedEnvironment(attribute)  
        inputs.updateCachedEnvironment(MutableBox(cachedEnvironment))
    }
}

extension View {
    /// Transforms the environment value of the specified key path with the
    /// given function.
    @inlinable
    public func transformEnvironment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        transform: @escaping (inout V) -> Void
    ) -> some View {
        modifier(_EnvironmentKeyTransformModifier(
            keyPath: keyPath,
            transform: transform
        ))
    }
}

private struct ChildEnvironment<Value>: StatefulRule, AsyncAttribute {
    @Attribute
    private var modifier: _EnvironmentKeyTransformModifier<Value>
    private var _environment: Attribute<EnvironmentValues>
    private var oldValue: Value?
    private var oldKeyPath: WritableKeyPath<EnvironmentValues, Value>?
    
    init(modifier: Attribute<_EnvironmentKeyTransformModifier<Value>>,
         environment: Attribute<EnvironmentValues>,
         oldValue: Value? = nil,
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
    
    mutating func updateValue() {
        var (environment, environmentChanged) = _environment.changedValue()
        let keyPath = modifier.keyPath
        var newValue = environment[keyPath: keyPath]
        _modifier.syncMainIfReferences { modifier in
            modifier.transform(&newValue)
        }
        guard !environmentChanged,
              let valueChanged = oldValue.map({ compareValues($0, newValue, mode: ._2) }), !valueChanged,
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
