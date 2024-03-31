//
//  PreferenceListTests.swift
//
//
//  Created by Kyle on 2024/2/4.
//

@testable import OpenSwiftUI
import Testing

struct PreferenceListTests {
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
            value = nextValue()
        }
        
        enum Value { case a, b }
        static var defaultValue: Value { .a }
    }
    
    
    @Test("Test description and subscript with zero seed")
    func subscriptAndDescriptionWithZeroSeed() {
        var list = PreferenceList()
        #expect(list.description == "empty: []")
        list[IntKey.self] = PreferenceList.Value(value: 1, seed: .empty)
        #expect(list.description == "empty: [IntKey = 1]")
        list[DoubleKey.self] = PreferenceList.Value(value: 1.0, seed: .empty)
        #expect(list.description == "empty: [DoubleKey = 1.0, IntKey = 1]")
        list[IntKey.self] = PreferenceList.Value(value: 2, seed: .empty)
        #expect(list.description == "empty: [IntKey = 2, DoubleKey = 1.0]")
        list[DoubleKey.self] = PreferenceList.Value(value: 1.0, seed: .empty)
        #expect(list.description == "empty: [DoubleKey = 1.0, IntKey = 2]")
        list[EnumKey.self] = PreferenceList.Value(value: .a, seed: .empty)
        #expect(list.description == "empty: [EnumKey = a, DoubleKey = 1.0, IntKey = 2]")
    }
    
    @Test("Test description and subscript with seed")
    func subscriptAndDescriptionWithSeed() {
        var list = PreferenceList()
        #expect(list.description == "empty: []")
        list[IntKey.self] = PreferenceList.Value(value: 1, seed: .init(value: 1))
        #expect(list.description == "1: [IntKey = 1]")
        list[DoubleKey.self] = PreferenceList.Value(value: 1.0, seed: .init(value: 2))
        #expect(list.description == "547159728: [DoubleKey = 1.0, IntKey = 1]")
        list[IntKey.self] = PreferenceList.Value(value: 2, seed: .init(value: 3))
        #expect(list.description == "3634229150: [IntKey = 2, DoubleKey = 1.0]")
        list[DoubleKey.self] = PreferenceList.Value(value: 1.0, seed: .init(value: 4))
        #expect(list.description == "1218402493: [DoubleKey = 1.0, IntKey = 2]")
        list[EnumKey.self] = PreferenceList.Value(value: .a, seed: .init(value: 5))
        #expect(list.description == "1817264013: [EnumKey = a, DoubleKey = 1.0, IntKey = 2]")
    }
}
