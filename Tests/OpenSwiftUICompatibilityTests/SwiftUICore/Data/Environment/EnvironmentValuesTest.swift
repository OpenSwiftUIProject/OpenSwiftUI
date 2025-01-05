//
//  EnvironmentValuesTest.swift
//
//
//  Created by Kyle on 2023/11/21.
//

import Testing

struct EnvironmentValuesTest {
    struct BoolKey: EnvironmentKey {
        fileprivate static var name: String { "EnvironmentPropertyKey<BoolKey>" }
        
        static let defaultValue = false
    }
    
    struct IntKey: EnvironmentKey {
        fileprivate static var name: String { "EnvironmentPropertyKey<IntKey>" }

        static let defaultValue = 0
    }
    
    @Test
    func descriptionWithoutTracker() throws {
        #if os(macOS) && OPENSWIFTUI_COMPATIBILITY_TEST
        // FIXME: The env.description will always be "[]" on macOS 13
        if #unavailable(macOS 14) {
            var env = EnvironmentValues()
            #expect(env.description == "[]")
            var bool = env[BoolKey.self]
            #expect(bool == BoolKey.defaultValue)
            #expect(env.description == "[]")
            
            env[BoolKey.self] = bool
            #expect(env.description == "[]")
            
            env[BoolKey.self] = !bool
            bool = env[BoolKey.self]
            #expect(bool == !BoolKey.defaultValue)
            #expect(env.description == "[]")
            
            let value = 1
            env[IntKey.self] = value
            #expect(env.description == "[]")
            return
        }
        #endif
        func compareDictDescription(result: String, initial: String, expectNew: String) {
            #if canImport(Darwin)
            guard #available(iOS 16.0, macOS 13.0, *) else {
                #expect(result == expectNew)
                return
            }
            guard initial != "[]" else {
                #expect(result == expectNew)
                return
            }
            guard let expectNewContent = expectNew.wholeMatch(of: /\[(.*)\]/)?.output.1 else {
                Issue.record("Non empty string and does not contain [] in expectNew")
                return
            }
            if expectNewContent.isEmpty {
                #expect(result == initial)
            } else {
                let expectResult = "[\(expectNewContent), " + initial.dropFirst()
                #expect(result == expectResult)
            }
            #else
            #expect(result == expectNew)
            #endif
        }
        
        var env = EnvironmentValues()
        
        let initialDescription = env.description
        if #unavailable(iOS 18, macOS 15) {
            #expect(env.description == "[]")
        }
        
        var bool = env[BoolKey.self]
        #expect(bool == BoolKey.defaultValue)
        compareDictDescription(result: env.description, initial: initialDescription, expectNew: "[]")
        
        env[BoolKey.self] = bool
        compareDictDescription(result: env.description, initial: initialDescription, expectNew: "[\(BoolKey.name) = \(bool)]")
        
        env[BoolKey.self] = !bool
        bool = env[BoolKey.self]
        #expect(bool == !BoolKey.defaultValue)
        compareDictDescription(result: env.description, initial: initialDescription, expectNew: "[\(BoolKey.name) = \(bool), \(BoolKey.name) = \(BoolKey.defaultValue)]")
        
        let value = 1
        env[IntKey.self] = value
        compareDictDescription(result: env.description, initial: initialDescription, expectNew: "[\(IntKey.name) = \(value), \(BoolKey.name) = \(bool), \(BoolKey.name) = \(BoolKey.defaultValue)]")
    }
}
