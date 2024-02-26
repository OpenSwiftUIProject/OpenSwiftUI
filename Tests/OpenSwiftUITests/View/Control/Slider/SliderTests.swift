//
//  SliderTests.swift
//  
//
//  Created by Kyle on 2023/12/16.
//

import Testing
@testable import OpenSwiftUI

struct SliderTests {
    @Test
    func example() {
        let s = Slider(value: .constant(233), in: 200.0 ... 300.0, step: 28.0)
        #expect(abs(s.skipDistance - 0.333) <= 0.001)
        #expect(s.discreteValueCount == 4)
    }
}
