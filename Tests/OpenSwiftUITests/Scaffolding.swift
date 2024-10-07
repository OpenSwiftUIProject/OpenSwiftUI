//
//  Scaffolding.swift
//
//
//  Created by Kyle on 2023/11/8.
//

import Testing
import XCTest

#if compiler(<6.0)
// FIXME: Leave Scaffolding since we still use 5.10 toolchain on non-Darwin platform
final class AllTests: XCTestCase {
    func testAll() async {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}
#endif
