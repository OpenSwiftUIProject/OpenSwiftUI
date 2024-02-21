//
//  GraphValue.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/2/21.
//  Lastest Version: iOS 15.5
//  Status: WIP

internal import OpenGraphShims

public struct _GraphValue<Value>: Equatable {
    public subscript<U>(keyPath keyPath: KeyPath<Value, U>) -> _GraphValue<U> {
        _GraphValue<U>(value[keyPath: keyPath])
    }

    public static func == (a: _GraphValue<Value>, b: _GraphValue<Value>) -> Bool {
        a.value == b.value
    }

    var value: Attribute<Value>

    init(_ value: Attribute<Value>) {
        self.value = value
    }
//    init(_ value: Rule)
//    init(_ value: StatefulRule)

    subscript<Member>(offset body: (inout Value) -> PointerOffset<Value, Member>) -> _GraphValue<Member> {
        .init(value[offset: body])
    }
    
    subscript<Member>(keyPath: KeyPath<Value, Member>) -> _GraphValue<Member> {
        .init(value[keyPath: keyPath])
    }
    
    func unsafeBitCast<V>(to type: V.Type) -> _GraphValue<V> {
        .init(value.unsafeBitCast(to: type))
    }
}

extension Attribute {
    func unsafeBitCast<V>(to type: V.Type) -> Attribute<V> {
        unsafeOffset(at: 0, as: V.self)
    }
}
