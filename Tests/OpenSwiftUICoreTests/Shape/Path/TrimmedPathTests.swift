//
//  TrimmedPathTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenSwiftUICore
import Testing
#if canImport(CoreGraphics)
import CoreGraphics
#endif

struct TrimmedPathTests {
    @Test
    func emptyPath() {
        let path = Path()

        #expect(path.trimmedPath(from: 0.25, to: 0.75).isEmpty)
    }

    @Test
    func fullRangeReturnsOriginalPath() {
        let path = Path(CGRect(x: 10, y: 20, width: 30, height: 40))

        #expect(path.trimmedPath(from: 0, to: 1) == path)
        #expect(path.trimmedPath(from: -1, to: 2) == path)
    }

    @Test(arguments: [
        (0.5, 0.5),
        (0.75, 0.25),
    ] as [(CGFloat, CGFloat)])
    func nonIncreasingRangeIsEmpty(from: CGFloat, to: CGFloat) {
        let path = Path(CGRect(x: 10, y: 20, width: 30, height: 40))

        #expect(path.trimmedPath(from: from, to: to).isEmpty)
    }

    #if canImport(CoreGraphics)
    @Test(.disabled("Trim is not implemented yet"))
    func partialRectangle() {
        let trimmedPath = Path(CGRect(x: 0, y: 0, width: 100, height: 100))
            .trimmedPath(from: 0.125, to: 0.375)
        let expectedBounds = CGRect(x: 50, y: 0, width: 50, height: 50)

        #expect(!trimmedPath.isEmpty)
        #expect(trimmedPath.boundingRect == expectedBounds)

        let path = trimmedPath.cgPath

        #expect(path.boundingBoxOfPath == expectedBounds)
        #expect(path.currentPoint == CGPoint(x: 100, y: 50))
    }
    #endif
}
