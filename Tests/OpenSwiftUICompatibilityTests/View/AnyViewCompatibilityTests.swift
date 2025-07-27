//
//  AnyViewCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

struct AnyViewCompatibilityTests {
    @Test
    func testInitFromValue() {
        let empty = EmptyView()
        #expect(AnyView(_fromValue: empty) != nil)
    }
}
