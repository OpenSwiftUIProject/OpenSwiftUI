//
//  ConstantLocationTests.swift
//
//
//  Created by Kyle on 2023/11/8.
//

@testable import OpenSwiftUI
import XCTest

final class ConstantLocationTests: XCTestCase {
    func testConstantLocation() throws {
        let location = ConstantLocation(value: 0)
        XCTAssertEqual(location.wasRead, true)
        XCTAssertEqual(location.get(), 0)
        location.wasRead = false
        location.set(1, transaction: .init())
        XCTAssertEqual(location.wasRead, true)
        XCTAssertEqual(location.get(), 0)
    }
}
