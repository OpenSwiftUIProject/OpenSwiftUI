//
//  UnsafeLockedPointerTests.swift
//  
//
//  Created by Kyle on 2023/10/19.
//

import XCTest
@testable import OpenSwiftUI

final class UnsafeLockedPointerTests: XCTestCase {
    func testBasic() {
        let pointer = UnsafeLockedPointer(wrappedValue: 2)
        defer { pointer.destroy() }
        XCTAssertEqual(pointer.wrappedValue, 2)
        pointer.wrappedValue = 3
        XCTAssertEqual(pointer.wrappedValue, 3)
    }

    func testPropertyWrapper() {
        @UnsafeLockedPointer var value = 2
        defer { $value.destroy() }
        XCTAssertEqual(value, 2)
        $value.wrappedValue = 3
        XCTAssertEqual(value, 3)
    }
}
