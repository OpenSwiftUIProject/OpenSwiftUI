//
//  Box.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/17.
//  Lastest Version: iOS 15.5
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
