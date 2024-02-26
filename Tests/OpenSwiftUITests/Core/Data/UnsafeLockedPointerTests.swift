//
//  UnsafeLockedPointerTests.swift
//
//
//  Created by Kyle on 2023/10/19.
//

@testable import OpenSwiftUI
import Testing

struct UnsafeLockedPointerTests {
    @Test
    func basic() {
        let pointer = UnsafeLockedPointer(wrappedValue: 2)
        defer { pointer.destroy() }
        #expect(pointer.wrappedValue == 2)
        pointer.wrappedValue = 3
        #expect(pointer.wrappedValue == 3)
    }

    @Test
    func propertyWrapper() {
        @UnsafeLockedPointer var value = 2
        defer { $value.destroy() }
        #expect(value == 2)
        $value.wrappedValue = 3
        #expect(value == 3)
    }
}
