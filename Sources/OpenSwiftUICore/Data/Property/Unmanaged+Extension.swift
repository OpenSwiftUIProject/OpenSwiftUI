//
//  Unmanaged+Extension.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

extension Unmanaged {
    package func map<A: AnyObject>(_ transform: (Instance) throws -> A) rethrows -> Unmanaged<A> {
        try _withUnsafeGuaranteedRef { try .passUnretained(transform($0)) }
    }
    
    package func map<A: AnyObject>(_ transform: (Instance) throws -> A?) rethrows -> Unmanaged<A>? {
        try _withUnsafeGuaranteedRef { try transform($0).map { .passUnretained($0) } }
    }
    
    package func flatMap<A>(_ transform: (Instance) throws -> A) rethrows -> A {
        try _withUnsafeGuaranteedRef { try transform($0) }
    }
    
    package static func == (lhs: Unmanaged, rhs: Unmanaged) -> Bool {
        lhs.toOpaque() == rhs.toOpaque()
    }
}
