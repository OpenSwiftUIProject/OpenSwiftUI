//
//  SwiftUI.ColorTests.swift
//  OpenSwiftUIBridgeTests

#if canImport(SwiftUI)
import Testing
import SwiftUI
import OpenSwiftUI
import OpenSwiftUIBridge

struct SwiftUI_ColorTests {
    @Test
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    func color() throws {
        let swiftUIWhite = SwiftUI.Color.white
        let openSwiftUIWhite = OpenSwiftUI.Color.white
        #expect(swiftUIWhite.counterpart.resolve(in: .init()) == openSwiftUIWhite.resolve(in: .init()))
        #expect(openSwiftUIWhite.counterpart.resolve(in: .init()) == swiftUIWhite.resolve(in: .init()))
    }
    
    @Test
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    func resolved() throws {
        let swiftUIWhiteResolved = SwiftUI.Color.Resolved.init(red: 1, green: 1, blue: 1)
        let openSwiftUIWhiteResolved = OpenSwiftUI.Color.Resolved.init(red: 1, green: 1, blue: 1)
        
        #expect(swiftUIWhiteResolved.counterpart == openSwiftUIWhiteResolved)
        #expect(openSwiftUIWhiteResolved.counterpart == swiftUIWhiteResolved)
    }
}
#endif
