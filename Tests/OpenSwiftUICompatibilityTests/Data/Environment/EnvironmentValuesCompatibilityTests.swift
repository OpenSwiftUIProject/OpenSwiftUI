//
//  EnvironmentValuesCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

struct EnvironmentValuesCompatibilityTests {
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
        func compareDictDescription(result: String, initial: String, expectNew: String) {
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
        }
        
        var env = EnvironmentValues()
        
        let initialDescription = env.description
        
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
