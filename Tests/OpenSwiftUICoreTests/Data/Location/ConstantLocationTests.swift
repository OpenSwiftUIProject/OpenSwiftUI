//
//  ConstantLocationTests.swift
//
//
//  Created by Kyle on 2023/11/8.
//

@testable import OpenSwiftUICore
import Testing

struct ConstantLocationTests {
    @Test
    func constantLocation() throws {
        let location = ConstantLocation(value: 0)
        #expect(location.wasRead == true)
        #expect(location.get() == 0)
        location.wasRead = false
        location.set(1, transaction: .init())
        #expect(location.wasRead == true)
        #expect(location.get() == 0)
    }
}
