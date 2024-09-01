//
//  MutableBox.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2024
//  Status: Complete

@propertyWrapper
final package class MutableBox<T> {
    final package var value: T
    
    @inlinable
    package init(_ value: T) {
        self.value = value
    }

    @inlinable
    convenience package init(wrappedValue value: T) {
        self.value = value
    }
    
    @inlinable
    final package var wrappedValue: T {
        get { value }
        set { value = newValue }
    }
    
    @inlinable
    final package var projectedValue: MutableBox<T> {
        self
    }
}

extension MutableBox: Equatable where T: Equatable {
    @inlinable
    package static func == (lhs: MutableBox<T>, rhs: MutableBox<T>) -> Bool {
        lhs.value == rhs.value
    }
}
