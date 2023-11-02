//
//  State.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/1.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 08168374F4710A99DCB15B5E8768D632

@frozen
@propertyWrapper
public struct State<Value>: DynamicProperty {
    @usableFromInline
    var _value: Value

    @usableFromInline
    var _location: AnyLocation<Value>?

    public init(wrappedValue value: Value) {
        _value = value
        _location = nil
    }

    @_alwaysEmitIntoClient
    public init(initialValue value: Value) {
        _value = value
    }

    public var wrappedValue: Value {
        get {
            getValue(forReading: true)
        }
        nonmutating set {
            guard let _location else {
                return
            }
            _location.set(newValue, transaction: Transaction())
        }
    }
//    public var projectedValue: Binding<Value> {}
//
//    public static func _makeProperty(in _: inout _DynamicPropertyBuffer, container _: _GraphValue<some Any>, fieldOffset _: Swift.Int, inputs _: inout _GraphInputs) {
//
//    }
}

extension State where Value: ExpressibleByNilLiteral {
    @inlinable public init() {
        self.init(wrappedValue: nil)
    }
}

extension State {
    private func getValue(forReading: Bool) -> Value {
        guard let _location else {
            return _value
        }
        if GraphHost.isUpdating {
            if forReading {
                _location.wasRead = true
            }
            return _value
        } else {
            return _location.get()
        }
    }
}
