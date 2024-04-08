//
//  SliderTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUI
import Testing

struct SliderTests {
    @Test
    func example() {
        let s = Slider(value: .constant(233), in: 200.0 ... 300.0, step: 28.0)
        #expect(abs(s.skipDistance - 0.333) <= 0.001)
        #expect(s.discreteValueCount == 4)
    }
}
