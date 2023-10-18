//
//  UnsafeLockedPointer.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/18.
//  Lastest Version: iOS 15.5
//  Status: WIP

@_implementationOnly import OpenSwiftUIShims

//@propertyWrapper
struct UnsafeLockedPointer<A>: Destroyable {
//    var wrappedValue: A {
//    }

    var base: LockedPointer

//    init(wrappedValue: A) {
//    }

    var projectedValue: UnsafeLockedPointer<A> { self }

    func destroy() {
        let address = _LockedPointerGetAddress(base).assumingMemoryBound(to: A.self)
        address.deinitialize(count: 1)
        _LockedPointerDelete(base)
    }
}
