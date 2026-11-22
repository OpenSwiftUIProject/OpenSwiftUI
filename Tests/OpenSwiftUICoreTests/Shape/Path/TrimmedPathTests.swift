//
//  TrimmedPathTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenCoreGraphicsShims
import OpenSwiftUICore
import Testing

@Suite(.tags(.aigc))
struct TrimmedPathTests {
    @Test
    func emptyPathRemainsEmpty() {
        #expect(Path().trimmedPath(from: 0.25, to: 0.75).isEmpty)
    }

    @Test(arguments: [
        (0.0, 1.0),
        (-0.5, 1.5),
    ])
    func fullOrSupersetRangeReturnsOriginalPath(from: CGFloat, to: CGFloat) {
        let path = Path(CGRect(x: 10, y: 20, width: 30, height: 40))
        #expect(path.trimmedPath(from: from, to: to) == path)
    }

    @Test(arguments: [
        (0.5, 0.5),
        (0.75, 0.25),
    ])
    func nonIncreasingRangeReturnsEmptyPath(from: CGFloat, to: CGFloat) {
        let path = Path(CGRect(x: 10, y: 20, width: 30, height: 40))
        #expect(path.trimmedPath(from: from, to: to).isEmpty)
    }

    @Test(arguments: [
        // Perimeter of 100x100 rect starts at (0, 0) -> (100, 0) -> (100, 100) -> (0, 100) -> (0, 0)
        (0.0, 0.25, CGRect(x: 0, y: 0, width: 100, height: 0), CGPoint(x: 100, y: 0)),
        (0.125, 0.375, CGRect(x: 50, y: 0, width: 50, height: 50), CGPoint(x: 100, y: 50)),
        (0.5, 0.75, CGRect(x: 0, y: 100, width: 100, height: 0), CGPoint(x: 0, y: 100)),
    ])
    func partialSquarePerimeterSegments(
        from: CGFloat,
        to: CGFloat,
        expectedBounds: CGRect,
        expectedCurrentPoint: CGPoint
    ) {
        let trimmed = Path(CGRect(x: 0, y: 0, width: 100, height: 100))
            .trimmedPath(from: from, to: to)

        #expect(!trimmed.isEmpty)
        #expect(trimmed.boundingRect == expectedBounds)

        let cgPath = trimmed.cgPath
        #expect(cgPath.boundingBoxOfPath == expectedBounds)
        #expect(cgPath.currentPoint == expectedCurrentPoint)
    }
}
