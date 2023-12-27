//
//  Scaffolding.swift
//
//
//  Created by Kyle on 2023/11/8.
//

#if OPENSWIFTUI_SWIFT_TESTING
import Testing
import XCTest

final class AllTests: XCTestCase {
    func testAll() async {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}
#endif
