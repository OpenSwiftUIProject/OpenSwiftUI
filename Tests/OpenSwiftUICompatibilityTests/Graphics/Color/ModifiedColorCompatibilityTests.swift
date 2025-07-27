//
//  ModifiedColorCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import Numerics

struct ModifiedColorCompatibilityTests {
    @available(OpenSwiftUI_v1_0, *)
    @Test(arguments:
        [
            (Color.red, 0.334, 0.334, "33% red"),
            (Color.red, 0.336, 0.336, "34% red"),
            (Color.red.opacity(0.3), 0.5, 0.15, "50% 30% red"),
        ]
    )
    func opacity(_ color: Color, _ opacity: Double, _ expectedOpacity: Float, _ expectedDescription: String) {
        let opacityColor = color.opacity(opacity)
        #expect(opacityColor.resolve(in: .init()).opacity == expectedOpacity)
        #expect(opacityColor.description == expectedDescription)
    }
}
