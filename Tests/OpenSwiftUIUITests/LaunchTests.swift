//
//  UITestsLaunchTests.swift
//  OpenSwiftUIUITests
//
//  Created by Kyle on 2023/11/9.
//

import XCTest

final class UITestsLaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
