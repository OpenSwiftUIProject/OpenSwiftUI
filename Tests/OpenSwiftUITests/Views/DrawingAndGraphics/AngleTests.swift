//
//  AngleTests.swift
//
//
//  Created by Kyle on 2023/12/17.
//

import OpenSwiftUI
import XCTest

final class AngleTests: XCTestCase {
    private func helper(radians: Double, degrees: Double) {
        let a1 = Angle(radians: radians)
        XCTAssertEqual(a1.radians, radians)
        XCTAssertEqual(a1.degrees, degrees)
        XCTAssertEqual(a1.animatableData, radians * 128)
        let a2 = Angle(degrees: degrees)
        XCTAssertEqual(a2.radians, radians)
        XCTAssertEqual(a2.degrees, degrees)
        XCTAssertEqual(a1, a2)
        XCTAssertEqual(a1.animatableData * 2, (a2 * 2).animatableData)
        var a3 = a1
        a3.animatableData *= 2
        var a4 = a1
        a4.radians *= 2
        XCTAssertEqual(a3, a4)
    }

    func testZero() {
        helper(radians: .zero, degrees: .zero)
    }

    func testRightAngle() {
        helper(radians: .pi / 2, degrees: 90)
    }

    func testHalfCircle() {
        helper(radians: .pi, degrees: 180)
    }

    func testCircle() {
        helper(radians: .pi * 2, degrees: 360)
    }
}
