//
//  GraphValue.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

internal import OpenGraphShims

/// A transient reference to a value in the view hierarchy's dataflow
/// graph. "Transient" means that these values must never be stored,
/// only passed around while initializing views.
public struct _GraphValue<Value>: Equatable {
    var value: Attribute<Value>
    
    init(_ value: Attribute<Value>) {
        self.value = value
    }
    
    init<R: Rule>(_ rule: R) where R.Value == Value {
        value = Attribute(rule)
    }
    
    init<R: StatefulRule>(_ rule: R) where R.Value == Value {
        value = Attribute(rule)
    }
    
    func unsafeBitCast<V>(to type: V.Type) -> _GraphValue<V> {
        _GraphValue<V>(value.unsafeBitCast(to: type))
    }
    
    /// Returns the value created by fetching the property at `keyPath`
    /// of `self`.
    public subscript<Member>(keyPath: KeyPath<Value, Member>) -> _GraphValue<Member> {
        _GraphValue<Member>(value[keyPath: keyPath])
    }
    
    subscript<Member>(offset body: (inout Value) -> PointerOffset<Value, Member>) -> _GraphValue<Member> {
        _GraphValue<Member>(value[offset: body])
    }

    public static func == (a: _GraphValue<Value>, b: _GraphValue<Value>) -> Bool {
        a.value == b.value
    }
}

extension Attribute {
    func unsafeBitCast<V>(to type: V.Type) -> Attribute<V> {
        unsafeOffset(at: 0, as: V.self)
    }
}
