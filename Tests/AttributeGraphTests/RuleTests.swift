//
//  RuleTests.swift
//  
//
//  Created by Kyle on 2023/10/17.
//

import XCTest
import AttributeGraph

final class RuleTests: XCTestCase {

    func testRuleInitialValue() throws {
        struct A: Rule {
            typealias Value = Int
            var value: Int
        }
        XCTAssertEqual(A.initialValue, nil)
    }
}
