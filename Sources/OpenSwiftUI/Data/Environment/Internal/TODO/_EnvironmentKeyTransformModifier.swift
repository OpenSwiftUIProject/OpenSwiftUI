//
//  _EnvironmentKeyTransformModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 1DBD4F024EFF0E73A70DB6DD05D5B548

@frozen
public struct _EnvironmentKeyTransformModifier<Value>: PrimitiveViewModifier, _GraphInputsModifier {
    public var keyPath: WritableKeyPath<EnvironmentValues, Value>
    public var transform: (inout Value) -> Void
    
    @inlinable
    public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, transform: @escaping (inout Value) -> Void) {
        self.keyPath = keyPath
        self.transform = transform
    }

    public static func _makeInputs(modifier: _GraphValue<_EnvironmentKeyTransformModifier<Value>>, inputs: inout _GraphInputs) {

    }
}

extension View {
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

private struct ChildEnvironment {
    
}
