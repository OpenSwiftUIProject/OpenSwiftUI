//
//  LocationTests.swift
//
//
//  Created by Kyle on 2023/11/8.
//

@testable import OpenSwiftUI
import XCTest

final class LocationTests: XCTestCase {
    func testLocation() throws {
        struct L: Location {
            typealias Value = Int
            var wasRead = false
            func get() -> Int { 0 }
            func set(_: Int, transaction _: Transaction) {}
        }
        let location = L()
        let (value, result) = location.update()
        XCTAssertEqual(value, 0)
        XCTAssertEqual(result, true)
    }
}
