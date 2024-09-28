//
//  UniqueIDTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct UniqueIDTests {
    @Test
    func exmpla() {
        #expect(UniqueID.invalid.value == 0)
        let initialID = UniqueID()
        #expect(UniqueID().value == initialID.value + 1)
    }

}
