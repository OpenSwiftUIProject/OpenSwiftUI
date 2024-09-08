//
//  ColorResolvedTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

struct ColorResolvedTests {
    #if OPENSWIFTUI_SUPPORT_2023_API
    @Test(arguments: [
        (Color.RGBColorSpace.sRGB ,0, 0, 0, 0, "#00000000"),
        (Color.RGBColorSpace.sRGB, 0.3, 0.3, 0.3, 0.3, "#4C4C4C4D"),
        (Color.RGBColorSpace.sRGB, 0.5, 0.5, 0.5, 0.5, "#80808080"),
        (Color.RGBColorSpace.sRGB, 1, 1, 1, 1, "#FFFFFFFF"),
        
        (Color.RGBColorSpace.sRGBLinear ,0, 0, 0, 0, "#00000000"),
        (Color.RGBColorSpace.sRGBLinear, 0.3, 0.3, 0.3, 0.3, "#9595954D"),
        (Color.RGBColorSpace.sRGBLinear, 0.5, 0.5, 0.5, 0.5, "#BCBCBC80"),
        (Color.RGBColorSpace.sRGBLinear, 1, 1, 1, 1, "#FFFFFFFF"),
        
        (Color.RGBColorSpace.displayP3 ,0, 0, 0, 0, "#00000000"),
        (Color.RGBColorSpace.displayP3, 0.3, 0.3, 0.3, 0.3, "#4D4C4C4D"),
        (Color.RGBColorSpace.displayP3, 0.5, 0.5, 0.5, 0.5, "#807F7F80"),
        (Color.RGBColorSpace.displayP3, 1, 1, 1, 1, "#FFFFFFFF"),
    ])
    func description(colorSpace: Color.RGBColorSpace, red: Float, green: Float, blue: Float, opacity: Float, expected: String) {
        #if OPENSWIFTUI_COMPATIBILITY_TEST
        guard #available(iOS 17, macOS 14, *) else {
            print("This test is not available")
            return
        }
        #endif
        let resolved = Color.Resolved(colorSpace: colorSpace, red: red, green: green, blue: blue, opacity: opacity)
        #expect(resolved.description == expected)
    }
    #endif
}
