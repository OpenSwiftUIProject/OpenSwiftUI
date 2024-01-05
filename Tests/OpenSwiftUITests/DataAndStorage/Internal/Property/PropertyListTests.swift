//
//  PropertyListTests.swift
//
//
//  Created by Kyle on 2024/1/1.
//

@testable import OpenSwiftUI
import Testing

struct PropertyListTests {
    struct BoolKey: PropertyKey {
        static let defaultValue = false
    }
    
    struct IntKey: PropertyKey {
        static let defaultValue = 0
    }
    
    @Test
    func description() throws {
        var plist = PropertyList()
        #expect(plist.description == "[]")
        
        var bool = plist[BoolKey.self]
        #expect(bool == BoolKey.defaultValue)
        #expect(plist.description == "[]")
        
        plist[BoolKey.self] = bool
        #expect(plist.description == "[\(BoolKey.self) = \(bool)]")
        
        plist[BoolKey.self] = !bool
        bool = plist[BoolKey.self]
        #expect(bool == !BoolKey.defaultValue)
        #expect(plist.description == "[\(BoolKey.self) = \(bool), \(BoolKey.self) = \(BoolKey.defaultValue)]")
        
        let value = 1
        plist[IntKey.self] = value
        #expect(plist.description == "[\(IntKey.self) = \(value), \(BoolKey.self) = \(bool), \(BoolKey.self) = \(BoolKey.defaultValue)]")
    }
}
