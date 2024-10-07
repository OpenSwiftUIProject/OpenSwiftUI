//
//  ColorResolvedTests.swift
//  OpenSwiftUITests

#if canImport(Darwin)

@testable import OpenSwiftUICore
import Testing

struct ColorResolvedTests {
    @Test
    func kitColor() {
        let r1 = Color.Resolved(colorSpace: .sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        let r2 = Color.Resolved(colorSpace: .sRGBLinear, red: 1, green: 1, blue: 1, opacity: 1)
        
        #expect(r2.kitColor === r1.kitColor)
        
        let r3 = Color.Resolved(colorSpace: .sRGB, red: 0.3, green: 0.3, blue: 0.3, opacity: 0.3)
        #expect(r3.kitColor !== r1.kitColor)
    }
}
#endif
