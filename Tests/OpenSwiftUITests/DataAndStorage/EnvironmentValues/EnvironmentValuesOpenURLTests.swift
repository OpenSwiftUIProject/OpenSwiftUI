//
//  EnvironmentValuesOpenURLTests.swift
//  
//
//  Created by Kyle on 2023/11/28.
//

import XCTest
@testable import OpenSwiftUI

final class EnvironmentValuesOpenURLTests: XCTestCase {
    #if DEBUG
    func testOpenSensitiveURLActionKey() throws {
        let value = OpenSensitiveURLActionKey.defaultValue
        value.callAsFunction(URL(string: "https://example.com")!)
    }
    #endif
}
