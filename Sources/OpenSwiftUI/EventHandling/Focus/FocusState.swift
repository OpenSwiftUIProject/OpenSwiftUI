//
//  FocusState.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/2/1.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 274D264A38B51DC68ACC48A91353B7D0

@frozen
//@propertyWrapper
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
}
