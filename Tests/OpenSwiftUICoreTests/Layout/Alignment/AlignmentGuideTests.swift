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

// MARK: - AlignmentKeyTests

struct AlignmentKeyTests {
    private struct ZeroAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            .zero
        }
    }

    private struct SumAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.size.width + context.size.height
        }
    }

    @Test
    func typeAndAxis() {
        let horizontalKey1 = AlignmentKey(id: ZeroAlignment.self, axis: .horizontal)
        let horizontalKey2 = AlignmentKey(id: SumAlignment.self, axis: .horizontal)
        let verticalKey1 = AlignmentKey(id: ZeroAlignment.self, axis: .vertical)
        let verticalKey2 = AlignmentKey(id: SumAlignment.self, axis: .vertical)

        #expect(horizontalKey1.axis == .horizontal)
        #expect(horizontalKey2.axis == .horizontal)
        #expect(verticalKey1.axis == .vertical)
        #expect(verticalKey2.axis == .vertical)

        #expect(horizontalKey1.id == ZeroAlignment.self)
        #expect(verticalKey1.id == ZeroAlignment.self)
        #expect(horizontalKey2.id == SumAlignment.self)
        #expect(verticalKey2.id == SumAlignment.self)
    }

    @Test
    func fraction() {
        let key1 = AlignmentKey(id: ZeroAlignment.self, axis: .horizontal)
        let key2 = AlignmentKey(id: SumAlignment.self, axis: .horizontal)
        #expect(key1.fraction.isApproximatelyEqual(to: .zero))
        #expect(key2.fraction.isApproximatelyEqual(to: 2.0))
    }
}
