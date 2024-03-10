//
//  AlignmentIDTests.swift
//
//
//  Created by Kyle on 2023/12/16.
//

@testable import OpenSwiftUI
import Testing
import Foundation

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
            // TODO: use swift-numerics
            // https://github.com/apple/swift-testing/issues/165
            #expect(abs(value - CGFloat(n) / 2) <= 0.0001)
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
            #expect(abs(value - child) <= 0.0001)
        }
    }
}
