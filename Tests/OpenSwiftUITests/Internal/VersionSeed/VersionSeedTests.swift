//
//  VersionSeedTests.swift
//
//
//  Created by Kyle on 2024/1/5.
//

@testable import OpenSwiftUI
import Testing

struct VersionSeedTests {
    @Test(arguments: [
        (0, "empty"),
        (UInt32.max, "invalid"),
        (2, "2"),
    ])
    func description(value: UInt32, expectedDescription: String) {
        let seed = VersionSeed(value: value)
        #expect(seed.description == expectedDescription)
    }
}
