//
//  PreferenceKeyTests.swift
//
//
//  Created by Kyle on 2023/10/11.
//

@testable import OpenSwiftUI
import Testing

struct PreferenceKeyTests {
    struct DemoKey: PreferenceKey {
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
