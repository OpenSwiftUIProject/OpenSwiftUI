//
//  EnvironmentValuesOpenURLTests.swift
//  
//
//  Created by Kyle on 2023/11/28.
//

import XCTest
@testable import OpenSwiftUI

final class EnvironmentValuesOpenURLTests: XCTestCase {
    #if os(iOS) || os(macOS) || os(tvOS)
    func testOpenURLActionKey() {
        let value = OpenURLActionKey.defaultValue
        value.callAsFunction(URL(string: "https://example.com")!)
    }
    #endif
}
