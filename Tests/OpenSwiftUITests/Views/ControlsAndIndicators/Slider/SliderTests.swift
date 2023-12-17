//
//  SliderTests.swift
//  
//
//  Created by Kyle on 2023/12/16.
//

import XCTest
@testable import OpenSwiftUI

final class SliderTests: XCTestCase {
    func testExample() throws {
        let s = Slider(value: .constant(233), in: 200.0 ... 300.0, step: 28.0)
        XCTAssertEqual(s.skipDistance, 0.333, accuracy: 0.001)
        XCTAssertEqual(s.discreteValueCount, 4)
    }
}
