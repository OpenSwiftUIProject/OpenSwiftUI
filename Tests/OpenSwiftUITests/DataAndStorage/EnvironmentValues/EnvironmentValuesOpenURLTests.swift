//
//  EnvironmentValuesOpenURLTests.swift
//
//
//  Created by Kyle on 2023/11/28.
//

import Foundation
@testable import OpenSwiftUI
import Testing

struct EnvironmentValuesOpenURLTests {
    #if os(iOS) || os(macOS) || os(tvOS)
    @Test
    func testOpenURLActionKey() {
        let value = OpenURLActionKey.defaultValue
        value.callAsFunction(URL(string: "https://example.com")!)
    }
    #endif
}
