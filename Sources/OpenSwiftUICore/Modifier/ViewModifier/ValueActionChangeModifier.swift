//
//  ValueActionChangeModifier.swift
//  OpenSwiftUI

import Foundation

// FIXME

struct _ValueActionModifier2<Value>: PrimitiveViewModifier where Value: Equatable {
    var value: Value
    var action: (Value, Value) -> Void
}

extension View {
    nonisolated public func onChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (_ oldValue: V,_ newValue: V) -> Void
    ) -> some View where V: Equatable {
        self.modifier(_ValueActionModifier2(value: value, action: action))
    }
    
    nonisolated public func onChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping () -> Void
    ) -> some View where V: Equatable {
        // FIXME
        self
    }
}
