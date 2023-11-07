//
//  FunctionalLocationTests.swift
//
//
//  Created by Kyle on 2023/11/8.
//

@testable import OpenSwiftUI
import XCTest

final class FunctionalLocationTests: XCTestCase {
    func testFunctionalLocation() throws {
        class V {
            var count = 0
        }
        let value = V()
        let location = FunctionalLocation {
            value.count
        } setValue: { newCount, _ in
            value.count = newCount * newCount
        }

        XCTAssertEqual(location.wasRead, true)
        XCTAssertEqual(location.get(), 0)
        location.wasRead = false
        location.set(2, transaction: .init())
        XCTAssertEqual(location.wasRead, true)
        XCTAssertEqual(location.get(), 4)
    }
}
