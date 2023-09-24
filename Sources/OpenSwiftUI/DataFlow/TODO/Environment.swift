//
//  Environment.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/24.
//  Lastest Version: iOS 15.5
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

    @inlinable public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        content = .keyPath(keyPath)
    }

    @inlinable public var wrappedValue: Value {
        switch content {
        case let .value(value):
            return value
        case let .keyPath(keyPath):
            return EnvironmentValues()[keyPath: keyPath]
        }
    }

    // WIP
    @usableFromInline
    func error() -> Never {
        fatalError()
    }

    // WIP
    public static func _makeProperty<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs) {

    }
}
