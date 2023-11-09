//
//  UITests.swift
//  OpenSwiftUIUITests
//
//  Created by Kyle on 2023/11/9.
//

import XCTest
import Hammer
import UIKit

final class UITests: XCTestCase {
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        let eventGenerator = EventGenerator(window: app.windows.firstMatch.value as! UIWindow)
        eventGenerator.showTouches = true
        try eventGenerator.fingerUp()
    }
}
