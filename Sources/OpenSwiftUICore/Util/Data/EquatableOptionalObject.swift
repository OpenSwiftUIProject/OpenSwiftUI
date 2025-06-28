//
//  EquatableOptionalObject.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - EquatableOptionalObject [6.5.4]

@propertyWrapper 
package struct EquatableOptionalObject<T>: Equatable where T: AnyObject {
    package var wrappedValue: T?

    package init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }

    package static func == (lhs: EquatableOptionalObject<T>, rhs: EquatableOptionalObject<T>) -> Bool {
        return lhs.wrappedValue === rhs.wrappedValue
    }
}
