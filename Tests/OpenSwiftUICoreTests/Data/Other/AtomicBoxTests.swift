//
//  AtomicBoxTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct AtomicBoxTests {
    @Test
    func expressibleByNilLiteral() {
        let box: AtomicBox<Int?> = AtomicBox()
        #expect(box.wrappedValue == nil)
        box.wrappedValue = 3
        #expect(box.wrappedValue == 3)
    }
    
    @Test
    func access() {
        @AtomicBox var box: Int = 3
        #expect($box.access { $0.description } == "3")
    }
}
