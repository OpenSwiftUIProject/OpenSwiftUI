//
//  MovableLockTests.swift
//  OpenSwiftUI_SPITests

import OpenSwiftUI_SPI
import Testing

#if canImport(Darwin)
final class MovableLockTests {
    let lock: MovableLock

    init() {
        lock = MovableLock()
    }

    deinit {
        lock.destroy()
    }
    
    @Test
    func owner() {
        #expect(lock.isOwner == false)
        #expect(lock.isOutermostOwner == false)
        lock.lock()
        #expect(lock.isOwner == true)
        #expect(lock.isOutermostOwner == true)
        lock.unlock()
        #expect(lock.isOwner == false)
        #expect(lock.isOutermostOwner == false)
    }
}
#endif
