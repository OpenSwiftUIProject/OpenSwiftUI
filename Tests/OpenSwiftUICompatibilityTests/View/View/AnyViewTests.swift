//
//  AnyViewTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

struct AnyViewTests {
    @Test
    func testInitFromValue() {
        let empty = EmptyView()
        #expect(AnyView(_fromValue: empty) != nil)
    }
}
