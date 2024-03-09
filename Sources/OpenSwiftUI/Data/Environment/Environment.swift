//
//  Environment.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Empty
//  ID:

internal import OpenGraphShims

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

    public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container _: _GraphValue<V>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        buffer.append(
            EnvironmentBox<Value>(
                environment: inputs.cachedEnvironment.wrappedValue.environment
            ),
            fieldOffset: fieldOffset
        )
    }
}

private struct EnvironmentBox<Value>: DynamicPropertyBox {
    @Attribute<EnvironmentValues>
    var environment: EnvironmentValues
    var keyPath: KeyPath<EnvironmentValues, Value>?
    var value: Value?
    
    init(environment: Attribute<EnvironmentValues>) {
        _environment = environment
        keyPath = nil
        value = nil
    }
        
    func destroy() {}
    func reset() {}
    func update(property: inout Environment<Value>, phase: _GraphInputs.Phase) -> Bool {
        fatalError("TODO")
    }
}
