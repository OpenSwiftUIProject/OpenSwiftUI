//
//  LockedPointerTests.swift
//
//
//  Created by Kyle on 2023/10/19.
//

@testable import OpenSwiftUI
import OpenSwiftUIShims
import XCTest

final class LockedPointerTests: XCTestCase {
    func testAlignmentOffset() throws {
        // The alignment of a struct type is the maximum alignment out of all its properties.
        // Between an Int and a Bool, the Int has a larger alignment value of 8, so the struct uses it.
        struct A {
            let v1: Int
            let v2: Bool
        }
        struct B {
            let v1: Bool
            let v2: Int
        }
        struct C {
            let v1: SIMD3<Int>
            let v2: Bool
        }

        XCTAssertEqual(MemoryLayout<A>.size, 9)
        XCTAssertEqual(MemoryLayout<A>.stride, 16)
        XCTAssertEqual(MemoryLayout<A>.alignment, 8)

        XCTAssertEqual(MemoryLayout<B>.size, 16)
        XCTAssertEqual(MemoryLayout<B>.stride, 16)
        XCTAssertEqual(MemoryLayout<B>.alignment, 8)

        XCTAssertEqual(MemoryLayout<C>.size, 33)
        XCTAssertEqual(MemoryLayout<C>.stride, 48)
        XCTAssertEqual(MemoryLayout<C>.alignment, 16)

        let p1 = LockedPointer(type: A.self)
        let p2 = LockedPointer(type: B.self)
        let p3 = LockedPointer(type: C.self)
        defer {
            p1.delete()
            p2.delete()
            p3.delete()
        }

        XCTAssertEqual(p1.rawValue.pointee.offset, 8)
        XCTAssertEqual(p2.rawValue.pointee.offset, 8)
        XCTAssertEqual(p3.rawValue.pointee.offset, 16)
    }

    func testLocking() {
        let pointer = LockedPointer(type: Int.self)
        XCTAssertEqual(pointer.rawValue.pointee.lock._os_unfair_lock_opaque, 0)
        pointer.lock()
        XCTAssertNotEqual(pointer.rawValue.pointee.lock._os_unfair_lock_opaque, 0)
        pointer.unlock()
        XCTAssertEqual(pointer.rawValue.pointee.lock._os_unfair_lock_opaque, 0)
    }
}
