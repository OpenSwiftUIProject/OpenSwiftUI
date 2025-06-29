//
//  GraphValue.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import OpenGraphShims

/// A transient reference to a value in the view hierarchy's dataflow
/// graph. "Transient" means that these values must never be stored,
/// only passed around while initializing views.
public struct _GraphValue<Value>: Equatable {
    package var value: Attribute<Value>
    
    @_spi(ForOpenSwiftUIOnly)
    public init(_ value: Attribute<Value>) {
        self.value = value
    }
    
    @_spi(ForOpenSwiftUIOnly)
    public init<U>(_ value: U) where Value == U.Value, U: Rule {
        self.init(Attribute(value))
    }
    
    @_spi(ForOpenSwiftUIOnly)
    public init<U>(_ value: U) where Value == U.Value, U: StatefulRule {
        self.init(Attribute(value))
    }
    
    public subscript<U>(keyPath: KeyPath<Value, U>) -> _GraphValue<U> {
        _GraphValue<U>(value[keyPath: keyPath])
    }
    
    package subscript<U>(offset subject: (inout Value) -> PointerOffset<Value, U>) -> _GraphValue<U> {
        _GraphValue<U>(value[offset: subject])
    }
    
    package func unsafeCast<T>(to _: T.Type = T.self) -> _GraphValue<T> {
        _GraphValue<T>(value.unsafeCast(to: T.self))
    }
    
    package func unsafeBitCast<T>(to _: T.Type) -> _GraphValue<T> {
        _GraphValue<T>(value.unsafeBitCast(to: T.self))
    }
    
    public static func == (a: _GraphValue<Value>, b: _GraphValue<Value>) -> Bool {
        a.value == b.value
    }
}

@available(*, unavailable)
extension _GraphValue: Sendable {}
