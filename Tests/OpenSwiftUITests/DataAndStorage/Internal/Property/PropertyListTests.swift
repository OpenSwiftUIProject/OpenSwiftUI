//
//  PropertyListTests.swift
//
//
//  Created by Kyle on 2024/1/1.
//

@testable import OpenSwiftUI
import Testing

struct PropertyListTests {
    @Test
    func description() throws {
        let plist = PropertyList()
        #expect(plist.description == "[]")
    }
}
