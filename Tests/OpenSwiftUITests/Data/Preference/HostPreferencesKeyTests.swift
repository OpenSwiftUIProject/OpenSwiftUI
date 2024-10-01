//
//  HostPreferencesKeyTests.swift
//
//
//  Created by Kyle on 2024/2/4.
//

@testable import OpenSwiftUI
import Testing

struct HostPreferencesKeyTests {
    struct IntKey: PreferenceKey {
        static var defaultValue: Int { 0 }
        
        static func reduce(value: inout Int, nextValue: () -> Int) {
            value += nextValue()
        }
    }
    
    struct DoubleKey: PreferenceKey {
        static var defaultValue: Double { 0.0 }
        
        static func reduce(value: inout Double, nextValue: () -> Double) {
            value += nextValue()
        }
    }
    
    struct EnumKey: PreferenceKey {
        static func reduce(value: inout Value, nextValue: () -> Value) {
            let newValue = (value.rawValue + nextValue().rawValue) % Value.allCases.count
            value = .init(rawValue: newValue)!
        }
        
        enum Value: Int, CaseIterable { case a, b, c, d }
        static var defaultValue: Value { .a }
    }
    
    struct IntKey2: PreferenceKey {
        static var defaultValue: Int { 0 }
        
        static func reduce(value: inout Int, nextValue: () -> Int) {
            value *= nextValue()
        }
    }
    
    struct DoubleKey2: PreferenceKey {
        static var defaultValue: Double { 0.0 }
        
        static func reduce(value: inout Double, nextValue: () -> Double) {
            value *= nextValue()
        }
    }
    
    @Test
    func nodeID() {
        let id0 = HostPreferencesKey.makeNodeId()
        let id1 = HostPreferencesKey.makeNodeId()
        let id2 = HostPreferencesKey.makeNodeId()
        #expect(id1 == (id0 + 1))
        #expect(id2 == (id1 + 1))
    }
    
    @Test(arguments: [
        ([1, 2, 3, 4], [3, 12], [1.0, 2.0, 3.0, 4.0], [3.0, 12.0], [EnumKey.Value.a, .b, .c, .d], [EnumKey.Value.b, .a]),
        ([0, 4, 5, 6], [4, 30], [0.0, 1.0, 2.0, 3.0], [1.0, 6.0], [EnumKey.Value.a, .c, .d, .b], [EnumKey.Value.c, .d]),
        ([1, 7, 0, 5], [8, 0], [2.0, 1.5, 0.0, 5.0], [3.5, 0.0], [EnumKey.Value.c, .a, .b, .d], [EnumKey.Value.c, .b]),
    ])
    func reduce(
        intValues: [Int], expectedIntValues: [Int],
        doubleValues: [Double], expectedDoubleValues: [Double],
        enumValues: [EnumKey.Value], expectedEnumValues: [EnumKey.Value]
    ) {
        var value = HostPreferencesKey.defaultValue
        value[IntKey.self] = .init(value: intValues[0], seed: .init(value: 1))
        value[EnumKey.self] = .init(value: enumValues[0], seed: .init(value: 2))
        value[DoubleKey.self] = .init(value: doubleValues[0], seed: .init(value: 3))
        #expect(value.description == """
        372598479: [DoubleKey = \(doubleValues[0]), EnumKey = \(enumValues[0]), IntKey = \(intValues[0])]
        """)
        HostPreferencesKey.reduce(value: &value) {
            var nextValue = HostPreferencesKey.defaultValue
            nextValue[IntKey2.self] = .init(value: intValues[2], seed: .init(value: 4))
            nextValue[EnumKey.self] = .init(value: enumValues[1], seed: .init(value: 5))
            nextValue[DoubleKey2.self] = .init(value: doubleValues[2], seed: .init(value: 6))
            #expect(nextValue.description == """
            3126765658: [DoubleKey2 = \(doubleValues[2]), EnumKey = \(enumValues[1]), IntKey2 = \(intValues[2])]
            """)
            return nextValue
        }
        #expect(value.description == """
        1584719037: [IntKey2 = \(intValues[2]), DoubleKey2 = \(doubleValues[2]), IntKey = \(intValues[0]), EnumKey = \(expectedEnumValues[0]), DoubleKey = \(doubleValues[0])]
        """)
        HostPreferencesKey.reduce(value: &value) {
            var nextValue = HostPreferencesKey.defaultValue
            nextValue[DoubleKey.self] = .init(value: doubleValues[1], seed: .init(value: 7))
            nextValue[EnumKey.self] = .init(value: enumValues[2], seed: .init(value: 8))
            nextValue[IntKey.self] = .init(value: intValues[1], seed: .init(value: 9))
            #expect(nextValue.description == """
            1190677337: [IntKey = \(intValues[1]), EnumKey = \(enumValues[2]), DoubleKey = \(doubleValues[1])]
            """)
            nextValue[DoubleKey2.self] = .init(value: doubleValues[3], seed: .init(value: 7))
            nextValue[EnumKey.self] = .init(value: enumValues[3], seed: .init(value: 8))
            nextValue[IntKey2.self] = .init(value: intValues[3], seed: .init(value: 9))
            #expect(nextValue.description == """
            1148928659: [IntKey2 = \(intValues[3]), EnumKey = \(enumValues[3]), DoubleKey = \(doubleValues[1]), IntKey = \(intValues[1]), DoubleKey2 = \(doubleValues[3])]
            """)
            return nextValue
        }
        #expect(value.description == """
        2384310348: [DoubleKey = \(expectedDoubleValues[0]), EnumKey = \(expectedEnumValues[1]), IntKey = \(expectedIntValues[0]), DoubleKey2 = \(expectedDoubleValues[1]), IntKey2 = \(expectedIntValues[1])]
        """)
    }
}
