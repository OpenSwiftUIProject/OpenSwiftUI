//
//  EnvironmentValuesOpenURLTests.swift
//  OpenSwiftUITests

import Foundation
@testable import OpenSwiftUI
import Testing

struct EnvironmentValuesOpenURLTests {
    #if os(iOS) || os(visionOS) || os(macOS) || os(tvOS)
    @Test
    func testOpenURLActionKey() {
        let value = OpenURLActionKey.defaultValue
        value.callAsFunction(URL(string: "https://example.com")!)
    }
    #endif
}
