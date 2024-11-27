//
//  SwiftUI.EnvironmentValues.swift
//  OpenSwiftUIBridgeTests

#if canImport(SwiftUI)
import Testing
import SwiftUI
import OpenSwiftUI
import OpenSwiftUIBridge

struct SwiftUI_EnvironmentValues {
    @Test
    func example() throws {
        var swiftUIEnviromentValues = SwiftUI.EnvironmentValues()
        let openSwiftUIEnviromentValues = OpenSwiftUI.EnvironmentValues()
        #expect(swiftUIEnviromentValues.colorScheme == .light)
        #expect(openSwiftUIEnviromentValues.colorScheme == .light)
        swiftUIEnviromentValues.colorScheme = .dark
        withKnownIssue {
            #expect(swiftUIEnviromentValues.counterpart.colorScheme == .dark)
        }
    }
}
#endif
