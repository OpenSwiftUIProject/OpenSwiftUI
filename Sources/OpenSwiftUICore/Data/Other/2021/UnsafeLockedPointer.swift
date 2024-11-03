//
//  UnsafeLockedPointer.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#if OPENSWIFTUI_RELEASE_2021

import OpenSwiftUI_SPI

@propertyWrapper
package struct UnsafeLockedPointer<Data>: Destroyable {
    private var base: LockedPointer

    package init(wrappedValue: Data) {
        base = LockedPointer(type: Data.self)
        base.withUnsafeMutablePointer { $0.initialize(to: wrappedValue) }
    }
    
    package var wrappedValue: Data {
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

    package var projectedValue: UnsafeLockedPointer<Data> { self }
    
    package func destroy() {
        base.withUnsafeMutablePointer(Data.self) { $0.deinitialize(count: 1) }
        base.delete()
    }
    
    @_transparent
    @inline(__always)
    package func withMutableData<Result>(_ body: ((inout Data) -> Result)) -> Result {
        body(&wrappedValue)
    }
}
#endif
