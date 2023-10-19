//
//  UnsafeLockedPointer.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/18.
//  Lastest Version: iOS 15.5
//  Status: Blocked by StoredLocationBase

@_implementationOnly import OpenSwiftUIShims

@propertyWrapper
struct UnsafeLockedPointer<Data>: Destroyable {
    // TODO: caller StoredLocationBase
    var wrappedValue: Data {
        _read {
            _LockedPointerLock(base)
            defer {
                _LockedPointerUnlock(base)
            }
            yield _LockedPointerGetAddress(base).assumingMemoryBound(to: Data.self).pointee
        }
        nonmutating _modify {
            _LockedPointerLock(base)
            defer {
                _LockedPointerUnlock(base)
            }
            yield &_LockedPointerGetAddress(base).assumingMemoryBound(to: Data.self).pointee
        }
    }

    var base: LockedPointer

    init(wrappedValue: Data) {
        base = _LockedPointerCreate(MemoryLayout<Data>.size, MemoryLayout<Data>.alignment)
        _LockedPointerGetAddress(base)
            .assumingMemoryBound(to: Data.self)
            .initialize(to: wrappedValue)
    }

    var projectedValue: UnsafeLockedPointer<Data> { self }

    func destroy() {
        _LockedPointerGetAddress(base)
            .assumingMemoryBound(to: Data.self)
            .deinitialize(count: 1)
        _LockedPointerDelete(base)
    }
}
