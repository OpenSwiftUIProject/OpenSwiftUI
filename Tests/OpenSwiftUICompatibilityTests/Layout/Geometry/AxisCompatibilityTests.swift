//
//  AxisCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

struct AxisCompatibilityTests {
    @Test
    func example() {
        let h = Axis.horizontal
        let v = Axis.vertical
        #expect(Axis.allCases == [h, v])
        #expect(h.rawValue == 0)
        #expect(v.rawValue == 1)

        #expect(h.description == "horizontal")
        #expect(v.description == "vertical")
        
        let hs = Axis.Set.horizontal
        let vs = Axis.Set.vertical
        #expect(hs.contains(vs) == false)
    }
}
