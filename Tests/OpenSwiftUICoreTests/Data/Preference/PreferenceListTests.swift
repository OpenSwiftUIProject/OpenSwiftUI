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
}
