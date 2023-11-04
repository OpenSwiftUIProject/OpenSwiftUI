//
//  Binding.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/5.
//  Lastest Version: iOS 15.5
//  Status: Blocked by DynamicProperty

@frozen
@propertyWrapper
@dynamicMemberLookup
public struct Binding<Value> {
    public var transaction: Transaction
    var location: AnyLocation<Value>
    private var _value: Value

    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        let location = FunctionalLocation(getValue: get) { value, _ in set(value) }
        let box = LocationBox(location: location)
        self.init(value: get(), location: box)
    }

    public init(get: @escaping () -> Value, set: @escaping (Value, Transaction) -> Void) {
        let location = FunctionalLocation(getValue: get, setValue: set)
        let box = LocationBox(location: location)
        self.init(value: get(), location: box)
    }

    public static func constant(_ value: Value) -> Binding<Value> {
        let location = ConstantLocation(value: value)
        let box = LocationBox(location: location)
        return Binding(value: value, location: box)
    }

    public var wrappedValue: Value {
        get {
            readValue()
        }
        nonmutating set {
            location.set(newValue, transaction: transaction)
        }
    }

    public var projectedValue: Binding<Value> { self }

    @_alwaysEmitIntoClient
    public init(projectedValue: Binding<Value>) {
        self = projectedValue
    }
    
    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> Binding<Subject> {
        projecting(keyPath)
    }
}

 extension Binding {
    public init<V>(_ base: Binding<V>) where Value == V? {
        self = base.projecting(BindingOperations.ToOptional())
    }

    public init?(_ base: Binding<Value?>) {
        guard let _ = base.wrappedValue else {
            return nil
        }
        self = base.projecting(BindingOperations.ForceUnwrapping())
    }

    public init<V>(_ base: Binding<V>) where Value == AnyHashable, V : Hashable {
        self = base.projecting(BindingOperations.ToAnyHashable())
    }
 }

extension Binding: Identifiable where Value: Identifiable {
    public var id: Value.ID { wrappedValue.id }
    public typealias ID = Value.ID
}

extension Binding: Sequence where Value: MutableCollection {
    public typealias Element = Binding<Value.Element>
    public typealias Iterator = IndexingIterator<Binding<Value>>
    public typealias SubSequence = Slice<Binding<Value>>
}

extension Binding: Collection where Value: MutableCollection {
    public typealias Index = Value.Index
    public typealias Indices = Value.Indices
    public var startIndex: Binding<Value>.Index {
        wrappedValue.startIndex
    }

    public var endIndex: Binding<Value>.Index {
        wrappedValue.endIndex
    }

    public var indices: Value.Indices {
        wrappedValue.indices
    }

    public func index(after index: Binding<Value>.Index) -> Binding<Value>.Index {
        wrappedValue.index(after: index)
    }

    public func formIndex(after index: inout Binding<Value>.Index) {
        wrappedValue.formIndex(after: &index)
    }

    public subscript(position: Binding<Value>.Index) -> Binding<Value>.Element {
        Binding<Value>.Element {
            wrappedValue[position]
        } set: {
            wrappedValue[position] = $0
        }
    }
}

extension Binding: BidirectionalCollection where Value: BidirectionalCollection, Value: MutableCollection {
    public func index(before index: Binding<Value>.Index) -> Binding<Value>.Index {
        wrappedValue.index(before: index)
    }

    public func formIndex(before index: inout Binding<Value>.Index) {
        wrappedValue.formIndex(before: &index)
    }
}

extension Binding: RandomAccessCollection where Value: MutableCollection, Value: RandomAccessCollection {}

extension Binding {
    public func transaction(_ transaction: Transaction) -> Binding<Value> {
        var binding = self
        binding.transaction = transaction
        return binding
    }

    public func animation(_ animation: Animation? = .default) -> Binding<Value> {
        var binding = self
        binding.transaction.animation = animation
        return binding
    }
}

extension Binding : DynamicProperty {
    // TODO
    //    public static func _makeProperty<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs) {
    //    }
}

// MARK: - Binding Internal API

extension Binding {
    init(value: Value, location: AnyLocation<Value>, transaction: Transaction = Transaction()) {
        self.transaction = transaction
        self.location = location
        self._value = value
    }

    private func readValue() -> Value {
        if GraphHost.isUpdating {
            location.wasRead = true
            return _value
        } else {
            return location.get()
        }
    }

    func projecting<P: Projection>(_ p: P) -> Binding<P.Projected> where P.Base == Value {
        Binding<P.Projected>(value: p.get(base: _value), location: location.projecting(p), transaction: transaction)
    }
}
