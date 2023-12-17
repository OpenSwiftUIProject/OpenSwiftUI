//
//  AxisTests.swift
//
//
//  Created by Kyle on 2023/12/17.
//

import OpenSwiftUI
import XCTest

final class AxisTests: XCTestCase {
    func testExample() {
        let h = Axis.horizontal
        let v = Axis.vertical
        XCTAssertEqual(Axis.allCases, [h, v])
        XCTAssertEqual(h.rawValue, 0)
        XCTAssertEqual(v.rawValue, 1)

        XCTAssertEqual(h.description, "horizontal")
        XCTAssertEqual(v.description, "vertical")

        let hs = Axis.Set.horizontal
        let vs = Axis.Set.vertical
        XCTAssertFalse(hs.contains(vs))
    }
}
