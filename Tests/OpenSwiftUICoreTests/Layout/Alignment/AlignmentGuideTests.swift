//
//  AlignmentGuideTests.swift
//  OpenSwiftUICoreTests

import Foundation
import Numerics
import OpenSwiftUICore
import Testing

// MARK: - AlignmentIDTests

struct AlignmentIDTests {
    private struct TestAlignment: AlignmentID {
        static func defaultValue(in _: ViewDimensions) -> CGFloat { .zero }
    }

    @Test
    func combineExplicitLinear() throws {
        var value: CGFloat?
        try (0 ... 10).forEach { n in
            TestAlignment._combineExplicit(
                childValue: .init(n),
                n,
                into: &value
            )
            let value = try #require(value)
            #expect(value.isApproximatelyEqual(to: CGFloat(n) / 2))
        }
    }

    @Test
    func combineExplicitSame() throws {
        var value: CGFloat?
        let child = CGFloat.random(in: 0.0 ... 100.0)
        try (0 ... 10).forEach { n in
            TestAlignment._combineExplicit(
                childValue: child,
                n,
                into: &value
            )
            let value = try #require(value)
            #expect(value.isApproximatelyEqual(to: child))
        }
    }

    @Test
    func combineSequence() throws {
        var values: [CGFloat?] = [1, 3, 5]
        let result = TestAlignment.combineExplicit(values) ?? .zero
        #expect(result.isApproximatelyEqual(to: 3.0))

        values.append(nil)
        values.append(nil)
        let result2 = TestAlignment.combineExplicit(values) ?? .zero
        #expect(result2.isApproximatelyEqual(to: 3.0))
    }
}
