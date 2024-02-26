//
//  UnsafeLockedPointer.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Blocked by StoredLocationBase

internal import COpenSwiftUI

// TODO: caller StoredLocationBase
@propertyWrapper
struct UnsafeLockedPointer<Data>: Destroyable {
    private var base: LockedPointer

    init(wrappedValue: Data) {
        base = LockedPointer(type: Data.self)
        base.withUnsafeMutablePointer { $0.initialize(to: wrappedValue) }
    }

    @_transparent
    @inline(__always)
    var wrappedValue: Data {
        _read {
            base.lock()
            defer { base.unlock() }
            yield base.withUnsafeMutablePointer().pointee
        }
        nonmutating _modify {
            base.lock()
            defer { base.unlock() }
            yield &base.withUnsafeMutablePointer().pointee
        }
    }

    var projectedValue: UnsafeLockedPointer<Data> { self }

    @_transparent
    @inline(__always)
    func destroy() {
        base.withUnsafeMutablePointer(Data.self) { $0.deinitialize(count: 1) }
        base.delete()
    }
    
    @_transparent
    @inline(__always)
    func withMutableData<Result>(_ body: ((inout Data) -> Result)) -> Result {
        body(&wrappedValue)
    }
}
