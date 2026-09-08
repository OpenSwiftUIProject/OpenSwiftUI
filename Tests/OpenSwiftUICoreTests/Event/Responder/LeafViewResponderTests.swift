//
//  LeafViewResponderTests.swift
//  OpenSwiftUICoreTests

import Foundation
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import Testing

struct LeafViewResponderTests {
    @Test(arguments: [
        CGSize(width: -10, height: 10),
        CGSize(width: 10, height: -10),
        CGSize(width: -10, height: -10),
    ])
    func negativeSizeDoesNotContainPoints(size: CGSize) {
        let points = [
            CGPoint(x: -5, y: 5),
            CGPoint(x: 5, y: -5),
            CGPoint(x: -5, y: -5),
        ]

        #expect(contains(points: points, size: size) == [])
    }

    @Test(arguments: [
        (points: [], expectedRawValue: UInt64(0)),
        (
            points: [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 9, y: 9),
                CGPoint(x: 10, y: 5),
                CGPoint(x: 5, y: 10),
                CGPoint(x: -1, y: 5),
                CGPoint(x: 5, y: -1),
            ],
            expectedRawValue: 0b0000_0011
        ),
    ])
    func containmentReturnsExpectedMask(points: [CGPoint], expectedRawValue: UInt64) {
        #expect(contains(points: points, size: CGSize(width: 10, height: 10)) == BitVector64(rawValue: expectedRawValue))
    }

    @Test(arguments: [64, 65])
    func pointsAtMaskLimitDoNotWrap(count: Int) {
        var points = Array(repeating: CGPoint(x: 5, y: 5), count: count)
        points[0] = CGPoint(x: -1, y: 5)

        #expect(contains(points: points, size: CGSize(width: 10, height: 10)) == BitVector64(rawValue: 0xffff_ffff_ffff_fffe))
    }

    private func contains(points: [CGPoint], size: CGSize) -> BitVector64 {
        let responder: any ContentResponder = TrivialContentResponder()
        return points.withUnsafeBufferPointer { buffer in
            responder.contains(points: buffer, size: size)
        }
    }
}
