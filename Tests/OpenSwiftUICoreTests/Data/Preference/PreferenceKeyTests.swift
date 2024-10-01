//
//  PreferenceKeyTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct PreferenceKeyTests {
    @Test
    func readableName() {
        struct AKey: OpenSwiftUICore.PreferenceKey {
            static var defaultValue: Int { 0 }
            static func reduce(value: inout Int, nextValue: () -> Int) {}
        }
        #expect(AKey.readableName == "A")
        
        struct BPreference: OpenSwiftUICore.PreferenceKey {
            static var defaultValue: Int { 0 }
            static func reduce(value: inout Int, nextValue: () -> Int) {}
        }
        #expect(BPreference.readableName == "B")
        
        struct CPreferenceKey: OpenSwiftUICore.PreferenceKey {
            static var defaultValue: Int { 0 }
            static func reduce(value: inout Int, nextValue: () -> Int) {}
        }
        #expect(BPreference.readableName == "C")
        
        struct PreferenceKey: OpenSwiftUICore.PreferenceKey {
            static var defaultValue: Int { 0 }
            static func reduce(value: inout Int, nextValue: () -> Int) {}
        }
        #expect(PreferenceKey.readableName == "PreferenceKey")
    }
}
