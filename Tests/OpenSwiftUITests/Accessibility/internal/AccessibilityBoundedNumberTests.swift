//
//  AccessibilityBoundedNumberTests.swift
//
//
//  Created by Kyle on 2023/12/3.
//

@testable import OpenSwiftUI
import XCTest

final class AccessibilityBoundedNumberTests: XCTestCase {
    func testBoundedNumberLocalizedDescription() throws {
        if let boundedNumber = AccessibilityBoundedNumber(for: 4.5, in: 3.0...16.0, by: 0.1) {
            XCTAssertEqual(boundedNumber.localizedDescription, "4.5") //decimal case
        } else {
            XCTFail("Failed to init bounded number")
        }
        if let boundedNumber = AccessibilityBoundedNumber(for: 4.5, in: 1.0...101.0, by: 0.1) {
            XCTAssertEqual(boundedNumber.localizedDescription, "4%") // .percent case
        } else {
            XCTFail("Failed to init bounded number")
        }
        if let boundedNumber = AccessibilityBoundedNumber(for: 1.5, in: 1.3...2.3, by: 0.1) {
            XCTAssertEqual(boundedNumber.localizedDescription, "1.5") // .decimal case
        } else {
            XCTFail("Failed to init bounded number")
        }
        if let boundedNumber = AccessibilityBoundedNumber(for: 1.5, in: 1.0...2.0, by: 0.1) {
            XCTAssertEqual(boundedNumber.localizedDescription, "150%") // .percent case
        } else {
            XCTFail("Failed to init bounded number")
        }
    }
}
