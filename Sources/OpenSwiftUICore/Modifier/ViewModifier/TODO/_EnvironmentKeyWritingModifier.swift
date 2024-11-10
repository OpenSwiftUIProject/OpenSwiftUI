//
//  _EnvironmentKeyWritingModifier.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

@frozen
public struct _EnvironmentKeyWritingModifier<Value>: ViewModifier/*, _GraphInputsModifier*/ {
    public var keyPath: WritableKeyPath<EnvironmentValues, Value>
    public var value: Value

    @inlinable
    @inline(__always)
    public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
        self.keyPath = keyPath
        self.value = value
    }

    public static func _makeInputs(modifier: _GraphValue<_EnvironmentKeyWritingModifier<Value>>, inputs: inout _GraphInputs) {
        // TODO
    }
}

extension View {
    @inlinable
    @inline(__always)
    public func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V) -> some View {
        modifier(_EnvironmentKeyWritingModifier<V>(keyPath: keyPath, value: value))
    }
}
