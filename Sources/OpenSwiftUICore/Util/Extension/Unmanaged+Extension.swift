//
//  Unmanaged+Extension.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

extension Unmanaged {
    @_transparent
    package func map<T>(_ transform: (Instance) -> T) -> T {
        _withUnsafeGuaranteedRef { transform($0) }
    }

    @_transparent
    package func map<T>(_ transform: (Instance) -> T) -> Unmanaged<T> where T: AnyObject {
        _withUnsafeGuaranteedRef { .passUnretained(transform($0)) }
    }

    @_transparent
    package func map<T>(_ transform: (Instance) -> T?) -> Unmanaged<T>? where T: AnyObject {
        _withUnsafeGuaranteedRef { transform($0).map { .passUnretained($0) } }
    }

    package static func == (lhs: Unmanaged<Instance>, rhs: Unmanaged<Instance>) -> Bool {
        lhs.toOpaque() == rhs.toOpaque()
    }

    package static func != (lhs: Unmanaged<Instance>, rhs: Unmanaged<Instance>) -> Bool {
        lhs.toOpaque() != rhs.toOpaque()
    }
}
