//
//  LocationTests.swift
//
//
//  Created by Kyle on 2023/11/8.
//

@testable import OpenSwiftUI
import Testing

struct LocationTests {
    @Test
    func location() {
        struct L: Location {
            typealias Value = Int
            var wasRead = false
            func get() -> Int { 0 }
            func set(_: Int, transaction _: Transaction) {}
        }
        let location = L()
        let (value, result) = location.update()
        #expect((value, result) == (0, true))
    }
}
