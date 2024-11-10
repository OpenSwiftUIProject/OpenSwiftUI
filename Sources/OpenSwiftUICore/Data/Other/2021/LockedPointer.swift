//
//  LockedPointer.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

#if OPENSWIFTUI_RELEASE_2021

import OpenSwiftUI_SPI

package extension LockedPointer {
    @_transparent
    init<Data>(type: Data.Type) {
        self = _LockedPointerCreate(MemoryLayout<Data>.size, MemoryLayout<Data>.alignment)
    }

    @_transparent
    @discardableResult
    func withUnsafeMutablePointer<Data, R>(_ type: Data.Type = Data.self, _ body: (UnsafeMutablePointer<Data>) throws -> R) rethrows -> R {
        try body(withUnsafeMutablePointer(type))
    }

    @_transparent
    func withUnsafeMutablePointer<Data>(_ type: Data.Type = Data.self) -> UnsafeMutablePointer<Data> {
        _LockedPointerGetAddress(self).assumingMemoryBound(to: Data.self)
    }

    @_transparent
    func lock() {
        _LockedPointerLock(self)
    }

    @_transparent
    func unlock() {
        _LockedPointerUnlock(self)
    }

    @_transparent
    func delete() {
        _LockedPointerDelete(self)
    }
}

#endif
