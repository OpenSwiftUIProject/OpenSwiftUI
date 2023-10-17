//
//  MutableBoxTests.swift
//  
//
//  Created by Kyle on 2023/10/17.
//

import XCTest
@testable import OpenSwiftUI

final class MutableBoxTests: XCTestCase {
    func testExample() throws {
        @MutableBox var box = 3
        $box.wrappedValue = 4
        XCTAssertEqual(box, 4)
    }
}
