//
//  Box.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

// MARK: - Box

@propertyWrapper
final package class Box<T> {
    final package let value: T

    @inlinable
    package init(_ value: T) {
        self.value = value
    }
    
    @inlinable
    convenience package init(wrappedValue: T) {
        self.init(wrappedValue)
    }
    
    @inlinable
    final package var wrappedValue: T { value }
    
    @inlinable
    final package var projectedValue: Box<T> { self }
}

extension Box: Equatable where T: Equatable {
    @inlinable
    package static func == (lhs: Box<T>, rhs: Box<T>) -> Bool {
        lhs.value == rhs.value
    }
}

// MARK: - MutableBox

@propertyWrapper
final package class MutableBox<T> {
    final package var value: T
    
    @inlinable
    package init(_ value: T) {
        self.value = value
    }

    @inlinable
    convenience package init(wrappedValue value: T) {
        self.init(value)
    }
    
    @inlinable
    final package var wrappedValue: T {
        get { value }
        set { value = newValue }
    }
    
    @inlinable
    final package var projectedValue: MutableBox<T> { self }
}

extension MutableBox: Equatable where T: Equatable {
    @inlinable
    package static func == (lhs: MutableBox<T>, rhs: MutableBox<T>) -> Bool {
        lhs.value == rhs.value
    }
}

// MARK: - WeakBox

package struct WeakBox<T> where T: AnyObject {
    weak package var base: T?
    
    @inlinable
    package init(_ base: T? = nil) {
        self.base = base
    }
}

// MARK: - HashableWeakBox

package struct HashableWeakBox<T>: Hashable where T: AnyObject{
    weak package var base: T?

    let basePointer: UnsafeMutableRawPointer

    @inlinable
    init(_ base: T) {
        self.base = base
        self.basePointer = Unmanaged.passUnretained(base).toOpaque()
    }

    package func hash(into hasher: inout Hasher) {
        hasher.combine(basePointer)
    }

    package static func == (lhs: HashableWeakBox<T>, rhs: HashableWeakBox<T>) -> Bool {
        lhs.basePointer == rhs.basePointer
    }
}

// MARK: - Indirect

package struct Indirect<T> {
    var box: MutableBox<T>
    
    package var value: T {
        get { box.wrappedValue }
        set { box.wrappedValue = newValue }
    }
    
    package init(_ value: T) {
        box = MutableBox(wrappedValue: value)
    }
}

extension Indirect: Equatable where T: Equatable {
    package static func == (lhs: Indirect<T>, rhs: Indirect<T>) -> Bool {
        lhs.value == rhs.value
    }
}
