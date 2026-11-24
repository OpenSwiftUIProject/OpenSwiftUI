//
//  WebPathContainmentTests.swift
//  OpenSwiftUICoreTests

#if os(WASI)
import Foundation
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
struct WebPathContainmentTests {
    @Test
    func translatedRectangle() {
        let path = Path(CGRect(x: 10, y: 20, width: 30, height: 40))
        let hits = path.contains(
            points: [CGPoint(x: 120, y: 230), CGPoint(x: 100, y: 230)],
            origin: CGPoint(x: 100, y: 200)
        )
        #expect(hits[0])
        #expect(!hits[1])
    }

    @Test(arguments: [false, true])
    func ellipseDoesNotHitBoundingBoxCorners(eoFill: Bool) {
        let path = Path(ellipseIn: CGRect(x: 0, y: 0, width: 20, height: 10))
        let hits = path.contains(
            points: [
                CGPoint(x: 110, y: 205),
                CGPoint(x: 101, y: 201),
                CGPoint(x: 119, y: 205),
                CGPoint(x: 121, y: 205),
            ],
            eoFill: eoFill,
            origin: CGPoint(x: 100, y: 200)
        )
        #expect(hits[0])
        #expect(!hits[1])
        #expect(hits[2])
        #expect(!hits[3])
    }

    @Test
    func emptyAndDegeneratePathsDoNotHit() {
        let points = [CGPoint.zero, CGPoint(x: 5, y: 5)]
        #expect(Path().contains(points: points).rawValue == 0)
        #expect(Path(ellipseIn: .zero).contains(points: points).rawValue == 0)
        #expect(Path(roundedRect: .zero, cornerRadius: 2).contains(points: points).rawValue == 0)
        let rounded = Path(roundedRect: CGRect(x: 0, y: 0, width: 10, height: 10), cornerRadius: 2)
        let roundedHits = rounded.contains(points: points)
        #expect(!roundedHits[0])
        #expect(roundedHits[1])
    }
}
#endif
