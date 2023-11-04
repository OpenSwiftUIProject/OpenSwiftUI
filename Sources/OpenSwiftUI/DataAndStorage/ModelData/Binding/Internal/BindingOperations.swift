//
//  BindingOperations.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/5.
//  Lastest Version: iOS 15.5
//  Status: Complete

enum BindingOperations {}

extension BindingOperations {
    struct ForceUnwrapping<Value>: Projection {
        func get(base: Value?) -> Value { base! }
        func set(base: inout Value?, newValue: Value) { base = newValue }
    }

    struct NilCoalescing<Value>: Projection {
        let defaultValue: Value
        let generation: Int

        func get(base: Value?) -> Value { base ?? defaultValue }
        func set(base: inout Value?, newValue: Value) { base = newValue }

        static func == (lhs: BindingOperations.NilCoalescing<Value>, rhs: BindingOperations.NilCoalescing<Value>) -> Bool {
            lhs.generation == rhs.generation
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(generation)
        }
    }

    struct ToAnyHashable<Value: Hashable>: Projection {
        func get(base: Value) -> AnyHashable { AnyHashable(base) }
        func set(base: inout Value, newValue: AnyHashable) { base = newValue.base as! Value }
    }

    struct ToDouble<Value: BinaryFloatingPoint>: Projection {
        func get(base: Value) -> Double { Double(base) }
        func set(base: inout Value, newValue: Double) { base = Value(newValue) }
    }

    struct ToOptional<Value>: Projection {
        func get(base: Value) -> Value? { base }

        func set(base: inout Value, newValue: Value?) {
            guard let newValue else {
                return
            }
            base = newValue
        }
    }
}
