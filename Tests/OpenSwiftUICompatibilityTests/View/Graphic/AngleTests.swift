//
//  AngleTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

struct AngleTests {
    private func helper(radians: Double, degrees: Double) {
        let a1 = Angle(radians: radians)
        #expect(a1.radians == radians)
        #expect(a1.degrees == degrees)
        #expect(a1.animatableData == radians * 128)
        let a2 = Angle(degrees: degrees)
        #expect(a2.radians == radians)
        #expect(a2.degrees == degrees)
        #expect(a1 == a2)
        #expect(a1.animatableData * 2 == (a2 * 2).animatableData)
        var a3 = a1
        a3.animatableData *= 2
        var a4 = a1
        a4.radians *= 2
        #expect(a3 == a4)
    }

    @Test
    func zero() {
        helper(radians: .zero, degrees: .zero)
    }

    @Test
    func rightAngle() {
        helper(radians: .pi / 2, degrees: 90)
    }

    @Test
    func halfCircle() {
        helper(radians: .pi, degrees: 180)
    }

    func circle() {
        helper(radians: .pi * 2, degrees: 360)
    }
}
