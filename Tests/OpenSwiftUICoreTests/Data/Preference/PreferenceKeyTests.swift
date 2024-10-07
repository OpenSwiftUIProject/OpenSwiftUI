//
//  PreferenceKeyTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct PreferenceKeyTests {
    struct AKey: OpenSwiftUICore.PreferenceKey {
        static var defaultValue: Int { 0 }
        static func reduce(value: inout Int, nextValue: () -> Int) {}
    }
    struct BPreference: OpenSwiftUICore.PreferenceKey {
        static var defaultValue: Int { 0 }
        static func reduce(value: inout Int, nextValue: () -> Int) {}
    }
    struct CPreferenceKey: OpenSwiftUICore.PreferenceKey {
        static var defaultValue: Int { 0 }
        static func reduce(value: inout Int, nextValue: () -> Int) {}
    }
    struct PreferenceKey: OpenSwiftUICore.PreferenceKey {
        static var defaultValue: Int { 0 }
        static func reduce(value: inout Int, nextValue: () -> Int) {}
    }
    
    @Test
    func readableName() {
        #expect(AKey.readableName == "A")
        #expect(BPreference.readableName == "B")
        #expect(CPreferenceKey.readableName == "C")
        #expect(PreferenceKey.readableName == "PreferenceKeyTests.PreferenceKey")
    }
    
    struct DemoKey: OpenSwiftUICore.PreferenceKey {
        struct Value: ExpressibleByNilLiteral {
            var value = 0
            init(nilLiteral _: ()) {}
            init(value: Int) { self.value = value }
        }

        static func reduce(value: inout Value, nextValue: () -> Value) {
            value.value = nextValue().value
        }
    }

    @Test
    func preferenceKeyReduce() throws {
        var value = DemoKey.defaultValue
        DemoKey.reduce(value: &value) {
            DemoKey.Value(value: 3)
        }
        #expect(value.value == 3)
    }
}
