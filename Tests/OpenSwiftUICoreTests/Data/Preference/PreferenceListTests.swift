//
//  PreferenceListTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct PreferenceListTests {
    struct AKey: PreferenceKey {
        static let defaultValue = 0
        static func reduce(value _: inout Int, nextValue _: () -> Int) {}
        static var _includesRemovedValues: Bool { true }
    }

    struct B: PreferenceKey {
        static let defaultValue = 0
        static func reduce(value _: inout Int, nextValue _: () -> Int) {}
    }
    
    struct C: PreferenceKey {
        static let defaultValue = 0
        static func reduce(value _: inout Int, nextValue _: () -> Int) {}
        static var _includesRemovedValues: Bool { true }
    }
    
    @Test
    func filterRemoved() {
        var list = PreferenceList()
        list[AKey.self] = .init(value: 0, seed: .invalid)
        list[B.self] = .init(value: 1, seed: .empty)
        list[C.self] = .init(value: 2, seed: .empty)
        #expect(list.description == "invalid: [C = 2, B = 1, AKey = 0]")
        list.filterRemoved()
        #expect(list.description == "invalid: [AKey = 0, C = 2]")
    }
    
    @Test
    func description() {
        var list = PreferenceList()
        list[AKey.self] = .init(value: 2, seed: .invalid)
        list[B.self] = .init(value: 2, seed: .empty)
        #expect(list.description == "invalid: [B = 2, AKey = 2]")
    }
    
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
