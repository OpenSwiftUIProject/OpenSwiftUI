//
//  MutableBoxTests.swift
//
//
//  Created by Kyle on 2023/10/17.
//

@testable import OpenSwiftUI
import Testing

struct MutableBoxTests {
    @Test
    func wrappedValue() {
        @MutableBox var box = 3
        $box.wrappedValue = 4
        #expect(box == 4)
    }
}
