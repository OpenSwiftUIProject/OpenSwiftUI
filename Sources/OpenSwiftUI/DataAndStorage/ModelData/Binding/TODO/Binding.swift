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
