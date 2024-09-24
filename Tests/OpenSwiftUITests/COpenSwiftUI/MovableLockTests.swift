//
//  MovableLockTests.swift
//
//
//  Created by Kyle on 2024/3/16.
//

import COpenSwiftUI
import Testing

#if canImport(Darwin)
final class MovableLockTests {
    let lock: MovableLock

    init() {
        lock = MovableLock.create()
    }

    deinit {
        lock.destory()
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
