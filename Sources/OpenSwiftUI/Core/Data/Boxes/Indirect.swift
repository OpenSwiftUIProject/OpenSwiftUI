//
//  Indirect.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
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
