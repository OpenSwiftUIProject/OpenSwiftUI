//
//  BindingOperations.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1B4A0A6DD72E915E1D833753C43AC6E0 (SwiftUICore)

@available(OpenSwiftUI_v1_0, *)
extension Binding {

    /// Creates a binding by projecting the base value to an optional value.
    ///
    /// - Parameter base: A value to project to an optional value.
    public init<V>(_ base: Binding<V>) where Value == V? {
        self = base.projecting(BindingOperations.ToOptional())
    }

    /// Creates a binding by projecting the base value to an unwrapped value.
    ///
    /// - Parameter base: A value to project to an unwrapped value.
    ///
    /// - Returns: A new binding or `nil` when `base` is `nil`.
    public init?(_ base: Binding<Value?>) {
        guard let _ = base.wrappedValue else {
            return nil
        }
        self = base.projecting(BindingOperations.ForceUnwrapping())
    }

    /// Creates a binding by projecting the base value to a hashable value.
    ///
    /// - Parameters:
    ///   - base: A `Hashable` value to project to an `AnyHashable` value.
    public init<V>(_ base: Binding<V>) where Value == AnyHashable, V: Hashable {
        self = base.projecting(BindingOperations.ToAnyHashable())
    }

    package init<V>(_ base: Binding<V>) where Value == Double, V: BinaryFloatingPoint {
        self = base.projecting(BindingOperations.ToDouble())
    }

    package init<V>(_ base: Binding<V>) where Value == Double, V: BinaryInteger {
        self = base.projecting(BindingOperations.ToDoubleFromInteger())
    }

    package static func == (lhs: Binding<Value>, rhs: Value) -> Binding<Bool> where Value: Hashable {
        lhs.projecting(BindingOperations.Equals(value: rhs))
    }
}

private let _constantFalse: Binding<Bool> = .constant(false)

extension Binding where Value == Bool {
    package static var `false`: Binding<Bool> {
        _constantFalse
    }
}

private var nilCoalescingGenerationCounter: Int = 0

package enum BindingOperations {
    // MARK: - ToOptional

    package struct ToOptional<Value>: Projection {
        package func get(base: Value) -> Value? {
            base
        }

        package func set(base: inout Value, newValue: Value?) {
            guard let newValue else {
                return
            }
            base = newValue
        }
    }

    // MARK: - ToAnyHashable

    package struct ToAnyHashable<Value: Hashable>: Projection {
        package func get(base: Value) -> AnyHashable {
            AnyHashable(base)
        }
        package func set(base: inout Value, newValue: AnyHashable) {
            base = newValue.base as! Value
        }
    }

    package struct ForceUnwrapping<Value>: Projection {
        package func get(base: Value?) -> Value {
            base!
        }

        package func set(base: inout Value?, newValue: Value) {
            base = newValue
        }

        package init() {
            _openSwiftUIEmptyStub()
        }
    }

    package struct NilCoalescing<Value>: Projection {
        let defaultValue: Value
        let generation: Int

        package init(defaultValue: Value) {
            self.defaultValue = defaultValue
            self.generation = nilCoalescingGenerationCounter
            nilCoalescingGenerationCounter += 1
        }

        package func get(base: Value?) -> Value {
            base ?? defaultValue
        }

        package func set(base: inout Value?, newValue: Value) {
            base = newValue
        }

        package static func == (lhs: BindingOperations.NilCoalescing<Value>, rhs: BindingOperations.NilCoalescing<Value>) -> Bool {
            lhs.generation == rhs.generation
        }

        package func hash(into hasher: inout Hasher) {
            hasher.combine(generation)
        }
    }

    package struct ToDouble<Base>: Projection where Base: BinaryFloatingPoint {
        package func get(base: Base) -> Double {
            Double(base)
        }

        package func set(base: inout Base, newValue: Double) {
            base = Base(newValue)
        }

        package init() {
            _openSwiftUIEmptyStub()
        }
    }

    package struct ToDoubleFromInteger<Base>: Projection where Base: BinaryInteger {
        package func get(base: Base) -> Double {
            Double(base)
        }

        package func set(base: inout Base, newValue: Double) {
            base = Base(newValue)
        }

        package init() {
            _openSwiftUIEmptyStub()
        }
    }

    fileprivate struct Equals<Value>: Projection where Value: Hashable {
        var value: Value

        func get(base: Value) -> Bool {
            base == value
        }

        func set(base: inout Value, newValue: Bool) {
            guard newValue else {
                return
            }
            base = value
        }
    }
}
