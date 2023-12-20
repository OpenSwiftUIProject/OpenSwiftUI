//
//  RuleTests.swift
//  
//
//  Created by Kyle on 2023/10/17.
//

import XCTest
#if OPENGRAPH_COMPATIBILITY_TEST
import AttributeGraph
#else
import OpenGraph
#endif

final class RuleTests: XCTestCase {
    func testRuleInitialValue() throws {
        struct A: Rule {
            typealias Value = Int
            var value: Int
        }
        XCTAssertEqual(A.initialValue, nil)
    }
}
