//
//  AccessibilityBoundedNumberTests.swift
//
//
//  Created by Kyle on 2023/12/3.
//

@testable import OpenSwiftUI
import Testing

struct AccessibilityBoundedNumberTests {
    @Test(arguments: [
        (4.5, 3.0 ... 16.0, 0.1,"4.5"),
        (4.5, 1.0 ... 101.0, 0.1,"4%"),
        (1.5, 1.3 ... 2.3, 0.1,"1.5"),
        (1.5, 1.0 ... 2.0, 0.1,"150%"),

    ])
    func boundedNumberLocalizedDescription(
        value: Double,
        range: ClosedRange<Double>,
        strideValue: Double,
        expectedDescription: String
    ) throws {
        let boundedNumber = try #require(AccessibilityBoundedNumber(for: value, in: range, by: strideValue))
        #expect(boundedNumber.localizedDescription == expectedDescription)
    }
}
