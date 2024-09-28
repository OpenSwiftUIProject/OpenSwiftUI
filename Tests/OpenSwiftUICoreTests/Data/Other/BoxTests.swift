//
//  BoxTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct BoxTests {
    @Test
    func mutableBox() {
        @MutableBox var box = 3
        $box.wrappedValue = 4
        #expect(box == 4)
    }
}
