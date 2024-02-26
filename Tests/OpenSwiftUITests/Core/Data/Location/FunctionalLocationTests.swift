//
//  FunctionalLocationTests.swift
//
//
//  Created by Kyle on 2023/11/8.
//

@testable import OpenSwiftUI
import Testing

struct FunctionalLocationTests {
    @Test
    func functionalLocation() {
        class V {
            var count = 0
        }
        let value = V()
        let location = FunctionalLocation {
            value.count
        } setValue: { newCount, _ in
            value.count = newCount * newCount
        }
        #expect(location.wasRead == true)
        #expect(location.get() == 0)
        location.wasRead = false
        location.set(2, transaction: .init())
        #expect(location.wasRead == true)
        #expect(location.get() == 4)
    }
}
