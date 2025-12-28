//
//  CustomRecursiveStringConvertibleTests.swift
//  OpenSwiftUICoreTests

import Testing
@testable import OpenSwiftUICore

struct CustomRecursiveStringConvertibleTests {
    // MARK: - String.tupleOfDoubles Tests
    
    @Test(arguments: [
        // Valid tuples with labeled elements
        ("(x: 1.0, y: 2.0)", [("x", 1.0), ("y", 2.0)]),
        ("(width: 100, height: 200)", [("width", 100.0), ("height", 200.0)]),
        ("(a: 0.5)", [("a", 0.5)]),
        // With negative values
        ("(x: -1.0, y: -2.5)", [("x", -1.0), ("y", -2.5)]),
        // With scientific notation
        ("(value: 1e10)", [("value", 1e10)]),
        // Multiple elements
        ("(a: 1, b: 2, c: 3)", [("a", 1.0), ("b", 2.0), ("c", 3.0)]),
        // With whitespace variations
        ("( x: 1.0 , y: 2.0 )", [("x", 1.0), ("y", 2.0)]),
    ])
    func tupleOfDoublesValid(input: String, expected: [(String, Double)]) {
        let result = input.tupleOfDoubles()
        #expect(result != nil)
        guard let result else { return }
        #expect(result.count == expected.count)
        for (index, element) in result.enumerated() {
            #expect(element.label == expected[index].0)
            #expect(element.value.isApproximatelyEqual(to: expected[index].1))
        }
    }
    
    @Test(arguments: [
        // Missing opening parenthesis
        "x: 1.0, y: 2.0)",
        // Missing closing parenthesis
        "(x: 1.0, y: 2.0",
        // No parentheses
        "x: 1.0, y: 2.0",
        // Invalid double value
        "(x: abc, y: 2.0)",
        // Empty string
        "",
        // Just parentheses with no content - though this might parse to empty array
        // Wrong bracket types
        "[x: 1.0, y: 2.0]",
    ])
    func tupleOfDoublesInvalid(input: String) {
        let result = input.tupleOfDoubles()
        #expect(result == nil)
    }
    
    @Test
    func tupleOfDoublesEmptyParens() {
        // Empty parens should return empty array (not nil)
        let result = "()".tupleOfDoubles()
        #expect(result != nil)
        #expect(result?.isEmpty == true)
    }

    // MARK: - Color.Resolved.name Tests

    @Test(arguments: [
        // Basic colors
        (Float(0), Float(0), Float(0), Float(0), "clear"),
        (Float(0), Float(0), Float(0), Float(1), "black"),
        (Float(1), Float(1), Float(1), Float(1), "white"),
        (Float(8.0 / 256.0), Float(8.0 / 256.0), Float(8.0 / 256.0), Float(1), "gray"),
        (Float(1), Float(0), Float(0), Float(1), "red"),
        (Float(0), Float(1), Float(0), Float(1), "green"),
        (Float(0), Float(0), Float(1), Float(1), "blue"),
        (Float(1), Float(1), Float(0), Float(1), "yellow"),
        (Float(0), Float(1), Float(1), Float(1), "teal"),
        // System colors
        (Float(1), Float(11.0 / 256.0), Float(11.0 / 256.0), Float(1), "system-red"),
        (Float(1), Float(15.0 / 256.0), Float(11.0 / 256.0), Float(1), "system-red-dark"),
        // Extended colors
        (Float(55.0 / 256.0), Float(0), Float(55.0 / 256.0), Float(1), "purple"),
        (Float(1), Float(55.0 / 256.0), Float(0), Float(1), "orange"),
        (Float(55.0 / 256.0), Float(55.0 / 256.0), Float(1), Float(1), "indigo"),
        (Float(1), Float(0), Float(55.0 / 256.0), Float(1), "pink"),
        (Float(12.0 / 256.0), Float(12.0 / 256.0), Float(14.0 / 256.0), Float(64.0 / 256.0), "brown"),
        (Float(12.0 / 256.0), Float(12.0 / 256.0), Float(14.0 / 256.0), Float(76.0 / 256.0), "placeholder-text"),
        // Quantization: slight variations round to named color
        (Float(0.999), Float(0.001), Float(0.001), Float(0.999), "red"),
    ] as [(Float, Float, Float, Float, String)])
    func colorResolvedName(r: Float, g: Float, b: Float, a: Float, expected: String) {
        let color = Color.Resolved(linearRed: r, linearGreen: g, linearBlue: b, opacity: a)
        #expect(color.name == expected)
    }

    @Test
    func colorResolvedNameUnknown() {
        let color = Color.Resolved(linearRed: 0.5, linearGreen: 0.3, linearBlue: 0.7, opacity: 1)
        #expect(color.name == nil)
    }
}

