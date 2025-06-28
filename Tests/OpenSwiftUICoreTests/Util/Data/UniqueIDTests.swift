//
//  UniqueIDTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct UniqueIDTests {
    @Test
    func invalid() {
        #expect(UniqueID.invalid.value == 0)
    }

    @Test
    func different() {
        let id1 = UniqueID()
        let id2 = UniqueID()
        #expect(id1.value != id2.value)
    }
}
