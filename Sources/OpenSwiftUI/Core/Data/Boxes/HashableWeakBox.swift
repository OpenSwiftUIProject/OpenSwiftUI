//
//  HashabelWeakBox.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

struct HashableWeakBox<A: AnyObject>: Hashable {
    weak var base: A?

    // 0x8
    let basePointer: UnsafeMutableRawPointer

    init(base: A) {
        self.base = base
        self.basePointer = Unmanaged.passUnretained(base).toOpaque()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(basePointer)
    }

    static func == (lhs: HashableWeakBox<A>, rhs: HashableWeakBox<A>) -> Bool {
        lhs.basePointer == rhs.basePointer
    }
}
