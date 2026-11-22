//
//  String+ExtensionTests.swift
//  OpenSwiftUICoreTests

import CoreFoundation
import Foundation
@testable import OpenSwiftUICore
import Testing

struct String_ExtensionTests {
    @Test
    func cfStringRoundTrip() throws {
        let cases = [
            "",
            "100 0 m 200 100 l h",
            "OpenSwiftUI 路径 🚀",
        ]

        for expected in cases {
            let cfString = expected.cfString
            #expect(CFGetTypeID(cfString) == CFStringGetTypeID())
            #expect(String(cfString: cfString) == expected)
        }

        let created = try #require(
            CFStringCreateWithCString(nil, "0 0 m 10 20 l", CFStringBuiltInEncodings.UTF8.rawValue)
        )
        #expect(String(cfString: created) == "0 0 m 10 20 l")
    }
}
