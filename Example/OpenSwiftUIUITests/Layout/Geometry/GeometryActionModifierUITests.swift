//
//  GeometryActionModifierUITests.swift
//  OpenSwiftUIUITests

import Testing
@testable import TestingHost

@MainActor
struct GeometryActionModifierUITests {
    @Test
    func example() {
        openSwiftUIAssertSnapshot(of: GeometryActionModifierExample())
    }
}
