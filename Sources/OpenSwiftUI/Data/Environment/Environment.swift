//
//  Environment.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Empty

@frozen
@propertyWrapper
public struct Environment<Value>: DynamicProperty {
    @usableFromInline
    @frozen
    enum Content {
        case keyPath(KeyPath<EnvironmentValues, Value>)
        case value(Value)
    }

    @usableFromInline
    var content: Content

    @inlinable
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        content = .keyPath(keyPath)
    }

    @inlinable
    public var wrappedValue: Value {
        switch content {
        case let .value(value):
            return value
        case let .keyPath(keyPath):
            return EnvironmentValues()[keyPath: keyPath]
        }
    }

    @usableFromInline
    func error() -> Never {
        fatalError("Reading Environment<\(Value.self)> outside View.body")
    }

    public static func _makeProperty<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs) {
        // TODO
    }
}
