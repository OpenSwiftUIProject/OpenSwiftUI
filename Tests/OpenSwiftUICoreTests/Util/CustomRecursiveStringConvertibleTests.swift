//
//  CustomRecursiveStringConvertibleTests.swift
//  OpenSwiftUICoreTests

import Testing
@testable import OpenSwiftUICore

struct CustomRecursiveStringConvertibleTests {
    // MARK: - recursiveDescriptionName Tests

    private struct PrivateType {}
    struct SimpleType {}
    struct GenericType<T> {}

    @Test(arguments: [
        (PrivateType.self, "PrivateType"),
        (SimpleType.self, "SimpleType"),
        (GenericType<Int>.self, "GenericType"),
        (Int.self, "Int"),
        (String.self, "String"),
        (Array<Int>.self, "Array"),
        (Dictionary<String, Int>.self, "Dictionary"),
        ((Int, String).self, "Int,"),
    ] as [(Any.Type, String)])
    func recursiveDescriptionNameTests(type: Any.Type, expected: String) {
        #expect(recursiveDescriptionName(type) == expected)
    }

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

    // MARK: - Sequence.roundedAttributes Tests

    @Test
    func roundedAttributesSimpleDouble() {
        let attrs: [(name: String, value: String)] = [
            (name: "width", value: "100.123456789"),
            (name: "height", value: "200.0"),
        ]
        let result = attrs.roundedAttributes()
        #expect(result.count == 2)
        // 100.123456789 * 256 = 25631.60493... → rounds to 25632 → 25632/256 = 100.125
        #expect(result[0].name == "width")
        #expect(result[0].value == "100.125")
        #expect(result[1].name == "height")
        #expect(result[1].value == "200.0")
    }

    @Test
    func roundedAttributesTupleOfDoubles() {
        let attrs: [(name: String, value: String)] = [
            (name: "position", value: "(x: 10.123456, y: 20.987654)"),
        ]
        let result = attrs.roundedAttributes()
        #expect(result.count == 1)
        #expect(result[0].name == "position")
        // 10.123456 * 256 = 2591.60 → 2592 → 10.125
        // 20.987654 * 256 = 5372.84 → 5373 → 20.98828125
        #expect(result[0].value == "(x: 10.125, y: 20.98828125)")
    }

    @Test
    func roundedAttributesColorDetection() {
        // Color with RGBA values that match "red"
        let attrs: [(name: String, value: String)] = [
            (name: "foregroundColor", value: "(1.0, 0.0, 0.0, 1.0)"),
        ]
        let result = attrs.roundedAttributes()
        #expect(result.count == 1)
        #expect(result[0].name == "foregroundColor")
        #expect(result[0].value == "red")
    }

    @Test
    func roundedAttributesColorNotMatched() {
        // Color values that don't match any known color
        let attrs: [(name: String, value: String)] = [
            (name: "someColor", value: "(0.5, 0.3, 0.7, 1.0)"),
        ]
        let result = attrs.roundedAttributes()
        #expect(result.count == 1)
        #expect(result[0].name == "someColor")
        // Should fall back to tuple format with rounded values
        #expect(result[0].value == "(0.5, 0.30078125, 0.69921875, 1.0)")
    }

    @Test
    func roundedAttributesNonNumeric() {
        // Non-numeric values should be returned unchanged
        let attrs: [(name: String, value: String)] = [
            (name: "title", value: "Hello World"),
            (name: "isEnabled", value: "true"),
        ]
        let result = attrs.roundedAttributes()
        #expect(result.count == 2)
        #expect(result[0].name == "title")
        #expect(result[0].value == "Hello World")
        #expect(result[1].name == "isEnabled")
        #expect(result[1].value == "true")
    }
}
