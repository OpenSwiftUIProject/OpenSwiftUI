//
//  AGCompareValuesTests.swift
//  
//
//  Created by Kyle on 2023/12/20.
//

import XCTest
#if OPENGRAPH_COMPATIBILITY_TEST
import AttributeGraph
#else
import OpenGraph
#endif

final class AGCompareValuesTests: XCTestCase {
    override func setUp() async throws {
        #if !OPENGRAPH_COMPATIBILITY_TEST
        throw XCTSkip("OG implementation for compareValues is not ready")
        #endif
    }

    func testIntCompare() throws {
        XCTAssertTrue(compareValues(1, 1))
        XCTAssertFalse(compareValues(1, 2))
    }

    func testEnumCompare() throws {
        enum A { case a, b }
        XCTAssertTrue(compareValues(A.a, A.a))
        XCTAssertFalse(compareValues(A.a, A.b))

        enum B { case a, b, c }
        let b = B.b
        withUnsafePointer(to: b) { p in
            p.withMemoryRebound(to: A.self, capacity: MemoryLayout<A>.size) { pointer in
                XCTAssertTrue(compareValues(pointer.pointee, A.b))
            }
        }
        withUnsafePointer(to: b) { p in
            p.withMemoryRebound(to: A.self, capacity: MemoryLayout<A>.size) { pointer in
                XCTAssertFalse(compareValues(pointer.pointee, A.a))
            }
        }
    }

    func testStructCompare() throws {
        struct A1{
            var a: Int
            var b: Bool
        }
        struct A2 {
            var a: Int
            var b: Bool
        }
        let a = A1(a: 1, b: true)
        let b = A1(a: 1, b: true)
        let c = A1(a: 1, b: false)
        XCTAssertTrue(compareValues(b, a))
        XCTAssertFalse(compareValues(c, a))
        let d = A2(a: 1, b: true)
        withUnsafePointer(to: d) { p in
            p.withMemoryRebound(to: A1.self, capacity: MemoryLayout<A1>.size) { pointer in
                XCTAssertTrue(compareValues(pointer.pointee, a))
            }
        }
        withUnsafePointer(to: d) { p in
            p.withMemoryRebound(to: A1.self, capacity: MemoryLayout<A1>.size) { pointer in
                XCTAssertFalse(compareValues(pointer.pointee, c))
            }
        }
    }
}
