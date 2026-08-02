//
//  CGRect+ExtensionTests.swift
//  OpenSwiftUICoreTests

import Foundation
import Numerics
import OpenSwiftUICore
import Testing

struct CGRect_ExtensionTests {
    @Test
    func cornerPointsWithNonZeroBasedSlice() {
        let points = [
            CGPoint(x: 100, y: 100),
            CGPoint(x: 200, y: 100),
            CGPoint(x: 200, y: 200),
            CGPoint(x: 100, y: 200),
            CGPoint(x: 3, y: 8),
            CGPoint(x: -2, y: 4),
            CGPoint(x: 6, y: -1),
            CGPoint(x: 1, y: 10),
        ]

        let rect = CGRect(cornerPoints: points[4...7])

        #expect(rect == CGRect(x: -2, y: -1, width: 8, height: 11))
    }

    @Test(arguments: [
        (CGRect(x: 0, y: 0, width: 2, height: 1), CGPoint(x: 1, y: 1), 0.0, 0.0),
        (CGRect(x: 0, y: 0, width: 2, height: 1), CGPoint(x: 1, y: 2), 1.0, 1.0),
        (CGRect(x: 0, y: 0, width: 2, height: 1), CGPoint(x: 3, y: 2), 1.4142135623730951, 1.0),
        (CGRect(x: 0, y: 0, width: 2, height: 1), CGPoint(x: 3, y: 3), 2.23606797749979, 2.0),
        (CGRect(x: 0, y: 0, width: 2, height: 1), CGPoint(x: -3, y: -4), 5.0, 4.0),
        (CGRect(x: 0, y: 0, width: 2, height: 1), CGPoint(x: 1, y: 0.5), -0.5, -0.5),
        (CGRect(x: 0, y: 0, width: 2, height: 1), CGPoint(x: 3, y: 0.5), 1.0, 1.0),

    ])
    func distance(rect: CGRect, point: CGPoint, expectedDistance: CGFloat, expectedPerpendicularDistance: CGFloat) {
        #expect(rect.distance(to: point).isApproximatelyEqual(to: expectedDistance))
        #expect(rect.perpendicularDistance(to: point).isApproximatelyEqual(to: expectedPerpendicularDistance))
    }

    @Test(
        arguments: [
            (CGRect.zero, ""),
            (CGRect(x: 1, y: 2, width: 4, height: 8), "0d0000803f15000000401d000080402500000041")
        ]
    )
    func pbMessage(rect: CGRect, hexString: String) throws {
        try rect.testPBEncoding(hexString: hexString)
        try rect.testPBDecoding(hexString: hexString)
    }
}
