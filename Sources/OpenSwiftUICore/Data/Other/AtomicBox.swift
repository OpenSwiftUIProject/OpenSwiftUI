//
//  AtomicBox.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete
//  ID: 82B2D47816BC992595021D60C278AFF0

import Foundation

private final class AtomicBuffer<Value>: ManagedBuffer<os_unfair_lock_s, Value> {
    static func allocate(value: Value) -> AtomicBuffer<Value> {
        let buffer = AtomicBuffer.create(minimumCapacity: 1) { buffer in
            os_unfair_lock_s()
        }
        buffer.withUnsafeMutablePointerToElements { pointer in
            pointer.initialize(to: value)
        }
        return unsafeDowncast(buffer, to: AtomicBuffer<Value>.self)
    }
}

@propertyWrapper
package struct AtomicBox<Value> {
    private let buffer: AtomicBuffer<Value>
    
    package init(wrappedValue: Value) {
        buffer = AtomicBuffer.allocate(value: wrappedValue)
    }
    
    @inline(__always)
    package var wrappedValue: Value {
        get {
            os_unfair_lock_lock(&buffer.header)
            defer { os_unfair_lock_unlock(&buffer.header) }
            return buffer.withUnsafeMutablePointerToElements { $0.pointee }
        }
        nonmutating _modify {
            os_unfair_lock_lock(&buffer.header)
            defer { os_unfair_lock_unlock(&buffer.header) }
            yield &buffer.withUnsafeMutablePointerToElements { $0 }.pointee
        }
    }

    @inline(__always)
    package func access<T>(_ body: (inout Value) throws -> T) rethrows -> T {
        try body(&wrappedValue)
    }
    
    package var projectedValue: AtomicBox<Value> { self }
}

extension AtomicBox: @unchecked Sendable where Value: Sendable {}

extension AtomicBox where Value: ExpressibleByNilLiteral {
    package init() {
        self.init(wrappedValue: nil)
    }
}
