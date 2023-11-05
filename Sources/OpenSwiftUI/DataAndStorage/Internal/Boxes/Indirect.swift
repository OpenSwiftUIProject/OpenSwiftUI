//
//  Indirect.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/17.
//  Lastest Version: iOS 15.5
//  Status: Complete

struct Indirect<A> {
    var box : MutableBox<A>

    var value: A { box.value }
}

extension Indirect: Equatable where A: Equatable {
    static func == (lhs: Indirect<A>, rhs: Indirect<A>) -> Bool {
        lhs.value == rhs.value
    }
}
