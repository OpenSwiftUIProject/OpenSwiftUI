protocol _GraphInputsModifier {}

@frozen
public struct _EnvironmentKeyTransformModifier<Value> : ViewModifier, _GraphInputsModifier {
    public var keyPath: Swift.WritableKeyPath<EnvironmentValues, Value>
    public var transform: (inout Value) -> Swift.Void
    
    @inlinable
    public init(keyPath: Swift.WritableKeyPath<EnvironmentValues, Value>, transform: @escaping (inout Value) -> Swift.Void) {
        self.keyPath = keyPath
        self.transform = transform
    }
    public static func _makeInputs(modifier: _GraphValue<_EnvironmentKeyTransformModifier<Value>>, inputs: inout _GraphInputs) {

    }
    public typealias Body = Never
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
