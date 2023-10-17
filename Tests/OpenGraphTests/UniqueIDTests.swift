//
//  UniqueIDTests.swift
//  
//
//  Created by Kyle on 2023/10/9.
//

import XCTest
import OpenGraph

final class UniqueIDTests: XCTestCase {
    func testUniqueID() throws {
        XCTAssertEqual(OGMakeUniqueID(), 1)
        XCTAssertEqual(OGMakeUniqueID(), 2)
    }
}
