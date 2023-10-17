//
//  MutableBox.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/17.
//  Lastest Version: iOS 15.5
//  Status: Complete

import Foundation

@propertyWrapper
final class MutableBox<A> {
    var value: A

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
