//
//  _EnvironmentKeyWritingModifier.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: WIP

@frozen
public struct _EnvironmentKeyWritingModifier<Value>: ViewModifier, _GraphInputsModifier, PrimitiveViewModifier {
    public var keyPath: WritableKeyPath<EnvironmentValues, Value>
    public var value: Value

    @inlinable
    public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
        self.keyPath = keyPath
        self.value = value
    }

    public static func _makeInputs(modifier: _GraphValue<_EnvironmentKeyWritingModifier<Value>>, inputs: inout _GraphInputs) {
        // TODO
    }
    
    
}

@available(*, unavailable)
extension _EnvironmentKeyWritingModifier: Sendable {}

extension View {
    @inlinable
    nonisolated public func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V) -> some View {
        modifier(_EnvironmentKeyWritingModifier<V>(keyPath: keyPath, value: value))
    }
}
