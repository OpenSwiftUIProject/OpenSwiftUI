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
}

