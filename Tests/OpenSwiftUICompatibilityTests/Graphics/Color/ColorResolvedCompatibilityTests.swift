//
//  ColorResolvedCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
#if OPENSWIFTUI
@_spi(ForTestOnly)
import OpenSwiftUI
#endif

struct ColorResolvedCompatibilityTests {
    @Test(arguments: [
        (Color.RGBColorSpace.sRGB, 0, 0, 0, 0, "#00000000", "#00000000"),
        (Color.RGBColorSpace.sRGB, 0.01, 0.02, 0.03, 0.04, "#0305080A", "#0305080A"),
        (Color.RGBColorSpace.sRGB, 0.3, 0.3, 0.3, 0.3, "#4C4C4C4D", "#4D4D4D4D"),
        (Color.RGBColorSpace.sRGB, 0.412, 0.508, 0.690, 0.748, "#6982B0BF", "#6982B0BF"),
        (Color.RGBColorSpace.sRGB, 0.6, 0.6, 0.6, 0.6, "#99999999", "#99999999"),
        (Color.RGBColorSpace.sRGB, 1, 1, 1, 1, "#FFFFFFFF", "#FFFFFFFF"),
        (Color.RGBColorSpace.sRGBLinear, 0, 0, 0, 0, "#00000000", "#00000000"),
        (Color.RGBColorSpace.sRGBLinear, 0.01, 0.02, 0.03, 0.04, "#1927300A", "#1927300A"),
        (Color.RGBColorSpace.sRGBLinear, 0.3, 0.3, 0.3, 0.3, "#9595954D", "#9595954D"),
        (Color.RGBColorSpace.sRGBLinear, 0.412, 0.508, 0.690, 0.748, "#ACBDD8BF", "#ACBDD8BF"),
        (Color.RGBColorSpace.sRGBLinear, 0.6, 0.6, 0.6, 0.6, "#CBCBCB99", "#CBCBCB99"),
        (Color.RGBColorSpace.sRGBLinear, 1, 1, 1, 1, "#FFFFFFFF", "#FFFFFFFF"),
        (Color.RGBColorSpace.displayP3, 0, 0, 0, 0, "#00000000", "#00000000"),
        (Color.RGBColorSpace.displayP3, 0.01, 0.02, 0.03, 0.04, "#0205080A", "#0205080A"),
        (Color.RGBColorSpace.displayP3, 0.3, 0.3, 0.3, 0.3, "#4D4C4C4D", "#4D4C4C4D"),
        (Color.RGBColorSpace.displayP3, 0.412, 0.508, 0.690, 0.748, "#6382B4BF", "#6382B4BF"),
        (Color.RGBColorSpace.displayP3, 0.6, 0.6, 0.6, 0.6, "#99999999", "#99999999"),
        (Color.RGBColorSpace.displayP3, 1, 1, 1, 1, "#FFFFFFFF", "#FFFFFFFF"),
    ])
    func description(
        colorSpace: Color.RGBColorSpace,
        red: Float,
        green: Float,
        blue: Float,
        opacity: Float,
        swiftUIExpected: String,
        openSwiftUIExpected: String
    ) {
        #if OPENSWIFTUI
        Update.locked {
            Color.Resolved._alignWithSwiftUIImplementation = false
            let resolved = Color.Resolved(colorSpace: colorSpace, red: red, green: green, blue: blue, opacity: opacity)
            #expect(resolved.description == openSwiftUIExpected)

            Color.Resolved._alignWithSwiftUIImplementation = true
            let resolved2 = Color.Resolved(colorSpace: colorSpace, red: red, green: green, blue: blue, opacity: opacity)
            #expect(resolved2.description == swiftUIExpected)
        }
        #else
        guard #available(iOS 17, macOS 14, *) else {
            print("This test is not available")
            return
        }
        let resolved = Color.Resolved(colorSpace: colorSpace, red: red, green: green, blue: blue, opacity: opacity)
        #expect(resolved.description == swiftUIExpected)
        #endif
    }
}
