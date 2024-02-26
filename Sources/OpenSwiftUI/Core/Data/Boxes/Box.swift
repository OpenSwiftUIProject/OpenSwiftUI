//
//  Box.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

final class Box<A> {
    let value: A

    init(_ value: A) {
        self.value = value
    }
}

extension Box: Equatable where A: Equatable {
    static func == (lhs: Box<A>, rhs: Box<A>) -> Bool {
        lhs.value == rhs.value
    }
}
