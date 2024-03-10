//
//  MutableBox.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

@propertyWrapper
final class MutableBox<A> {
    private var value: A

    var wrappedValue: A {
        get { value }
        set { value = newValue }
    }
    
    init(_ value: A) {
        self.value = value
    }

    init(wrappedValue value: A) {
        self.value = value
    }

    var projectedValue: MutableBox<A> {
        self
    }
}

extension MutableBox: Equatable where A: Equatable {
    static func == (lhs: MutableBox<A>, rhs: MutableBox<A>) -> Bool {
        lhs.value == rhs.value
    }
}
