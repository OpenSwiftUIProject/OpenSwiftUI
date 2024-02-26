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
        // Layout:
        // - [+0x0] = keypath
        // - [+0x8]b = 0
        case keyPath(KeyPath<EnvironmentValues, Value>)

        // Layout:
        // - [+0x0] = value
        // - [+0x8]b = 1
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
