//
//  Scaffolding.swift
//
//
//  Created by Kyle on 2023/11/8.
//

import Testing
import XCTest

final class AllTests: XCTestCase {
    func testAll() async {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}
