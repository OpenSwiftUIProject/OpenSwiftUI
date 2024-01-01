//
//  PropertyListTests.swift
//
//
//  Created by Kyle on 2024/1/1.
//

@testable import OpenSwiftUI
import XCTest

final class PropertyListTests: XCTestCase {
    func testDescription() throws {
        let plist = PropertyList()
        XCTAssertEqual(plist.description, "[]")
    }
}
