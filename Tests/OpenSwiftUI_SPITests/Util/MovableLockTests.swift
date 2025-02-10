//
//  MovableLockTests.swift
//  OpenSwiftUI_SPITests

import OpenSwiftUI_SPI
import Testing

#if canImport(Darwin)
final class MovableLockTests {
    let lock: MovableLock

    init() {
        lock = MovableLock.create()
    }

    deinit {
        lock.destroy()
    }
    
    @Test
    func owner() {
        #expect(lock.isOwner == false)
        #expect(lock.isOuterMostOwner == false)
        lock.lock()
        #expect(lock.isOwner == true)
        #expect(lock.isOuterMostOwner == true)
        lock.unlock()
        #expect(lock.isOwner == false)
        #expect(lock.isOuterMostOwner == false)
    }
}
#endif
