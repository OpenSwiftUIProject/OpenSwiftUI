//
//  EnvironmentValuesTest.swift
//
//
//  Created by Kyle on 2023/11/21.
//

#if OPENSWIFTUI_COMPATIBILITY_TEST
import SwiftUI
#else
import OpenSwiftUI
#endif
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
        var env = EnvironmentValues()
        #expect(env.description == "[]")
        
        var bool = env[BoolKey.self]
        #expect(bool == BoolKey.defaultValue)
        #expect(env.description == "[]")
        
        env[BoolKey.self] = bool
        #expect(env.description == "[\(BoolKey.name) = \(bool)]")
        
        env[BoolKey.self] = !bool
        bool = env[BoolKey.self]
        #expect(bool == !BoolKey.defaultValue)
        #expect(env.description == "[\(BoolKey.name) = \(bool), \(BoolKey.name) = \(BoolKey.defaultValue)]")
        
        let value = 1
        env[IntKey.self] = value
        #expect(env.description == "[\(IntKey.name) = \(value), \(BoolKey.name) = \(bool), \(BoolKey.name) = \(BoolKey.defaultValue)]")
    }
}
