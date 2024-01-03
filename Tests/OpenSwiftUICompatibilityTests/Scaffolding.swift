//
//  Scaffolding.swift
//
//
//  Created by Kyle on 2024/1/4.
//

import Testing
import XCTest

final class AllTests: XCTestCase {
    func testAll() async {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}
