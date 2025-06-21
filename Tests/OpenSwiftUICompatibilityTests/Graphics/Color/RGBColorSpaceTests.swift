//
//  RGBColorSpaceTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import Numerics

struct RGBColorSpaceTests {
    struct IO {
        var input: (hue: Double, saturation: Double, brightness: Double)
        var output: (red: Double, green: Double, blue: Double)
    }
    
    @available(OpenSwiftUI_v5_0, *)
    @Test(arguments:
        [
            IO(input: (0.0, 0.0, 0.0), output: (0.0, 0.0, 0.0)), // Black
            IO(input: (0.0, 0.0, 1.0), output: (1.0, 1.0, 1.0)), // White
            IO(input: (0.0, 1.0, 1.0), output: (1.0, 0.0, 0.0)), // Red
            IO(input: (1.0/3.0, 1.0, 1.0), output: (0.0, 1.0, 0.0)), // Green
            IO(input: (2.0/3.0, 1.0, 1.0), output: (0.0, 0.0, 1.0)), // Blue
            IO(input: (1.0, 1.0, 1.0), output: (1.0, 0.0, 0.0)), // Red
            IO(input: (1.0/6.0, 1.0, 1.0), output: (1.0, 1.0, 0.0)), // Yellow
            IO(input: (0.5, 1.0, 1.0), output: (0.0, 1.0, 1.0)), // Cyan
            IO(input: (5.0/6.0, 1.0, 1.0), output: (1.0, 0.0, 1.0)), // Magenta
            IO(input: (0.0, 0.0, 0.5), output: (0.5, 0.5, 0.5)), // Gray
            IO(input: (0.0, 1.0, 0.5), output: (0.5, 0.0, 0.0)), // Dark Red
            IO(input: (1.0/3.0, 1.0, 0.5), output: (0.0, 0.5, 0.0)), // Dark Green
            IO(input: (2.0/3.0, 1.0, 0.5), output: (0.0, 0.0, 0.5)), // Dark Blue
        ]
    )
    func testHSBToRGB(_ io: IO) {
        let color = Color(hue: io.input.hue, saturation: io.input.saturation, brightness: io.input.brightness)
        let resoved = color.resolve(in: .init())
        #expect(Double(resoved.red).isApproximatelyEqual(to: io.output.red))
        #expect(Double(resoved.green).isApproximatelyEqual(to: io.output.green))
        #expect(Double(resoved.blue).isApproximatelyEqual(to: io.output.blue))
    }
}
