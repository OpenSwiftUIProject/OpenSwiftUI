//
//  Unmanaged+Extension.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

extension Unmanaged {
    func map<A: AnyObject>(_ transform: (Instance) throws -> A) rethrows -> Unmanaged<A> {
        try _withUnsafeGuaranteedRef { try .passUnretained(transform($0)) }
    }
    
    func map<A: AnyObject>(_ transform: (Instance) throws -> A?) rethrows -> Unmanaged<A>? {
        try _withUnsafeGuaranteedRef { try transform($0).map { .passUnretained($0) } }
    }
    
    func flatMap<A>(_ transform: (Instance) throws -> A) rethrows -> A {
        try _withUnsafeGuaranteedRef { try transform($0) }
    }
    
    static func == (lhs: Unmanaged, rhs: Unmanaged) -> Bool {
        lhs.toOpaque() == rhs.toOpaque()
    }
}
