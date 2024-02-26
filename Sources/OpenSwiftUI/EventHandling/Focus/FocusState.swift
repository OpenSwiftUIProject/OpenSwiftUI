//
//  FocusState.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 274D264A38B51DC68ACC48A91353B7D0

@frozen
@propertyWrapper
public struct FocusState<Value>: DynamicProperty where Value: Hashable {
    @frozen
    @propertyWrapper
    public struct Binding {
        @OpenSwiftUI.Binding
        private var binding: Value
        
        init(binding: OpenSwiftUI.Binding<Value>) {
            _binding = binding
        }
        
        public var wrappedValue: Value {
            get { binding }
            nonmutating set { binding = newValue }
        }

        public var projectedValue: FocusState<Value>.Binding {
            self
        }
        
        var propertyID: ObjectIdentifier {
            if let location = _binding.location as? FocusStoreLocation<Value> {
                location.id
            } else {
                #if canImport(ObjectiveC)
                ObjectIdentifier(PrivateType.self)
                #else
                ObjectIdentifier(unsafeBitCast(0, to: AnyObject.self))
                #endif
            }
        }

        private enum PrivateType {}
    }

    var value: Value
    var location: AnyLocation<Value>?
    var resetValue: Value
    public var wrappedValue: Value {
        get {
            getValue(forReading: true)
        }
        nonmutating set {
            guard let location else {
                return
            }
            location.set(newValue, transaction: Transaction())
        }
    }

    public var projectedValue: FocusState<Value>.Binding {
        let value = getValue(forReading: false)
        let binding: OpenSwiftUI.Binding<Value>
        if let location {
            binding = OpenSwiftUI.Binding(value: value, location: location)
        } else {
            Log.runtimeIssues("Accessing FocusState's value outside of the body of a View. This will result in a constant Binding of the initial value and will not update.")
            binding = .constant(value)
        }
        return Binding(binding: binding)
    }
    
    public static func _makeProperty<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs) {
        // TODO
    }
    
    public init() where Value == Bool {
        value = false
        location = nil
        resetValue = false
    }
    
    public init<T>() where Value == T?, T: Hashable {
        value = nil
        location = nil
        resetValue = nil
    }
    
    private func getValue(forReading: Bool) -> Value {
        guard let location else {
            return value
        }
        if GraphHost.isUpdating {
            if forReading {
                location.wasRead = true
            }
            return value
        } else {
            return location.get()
        }
    }
}
