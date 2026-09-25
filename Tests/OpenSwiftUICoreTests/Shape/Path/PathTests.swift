//
//  PathTests.swift
//  OpenSwiftUICoreTests

#if canImport(CoreGraphics)
import CoreGraphics
#endif
import Foundation
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
struct PathTests {
    @Test(arguments: [0, 1, 64, 65])
    func containmentPreservesMaskAndOrigin(count: Int) {
        let path = Path(CGRect(x: 0, y: 0, width: 10, height: 10))
        var points = Array(repeating: CGPoint(x: 25, y: 35), count: count)
        if count > 0 {
            points[0] = CGPoint(x: 35, y: 35)
        }
        let mask = path.contains(points: points, origin: CGPoint(x: 20, y: 30))
        #expect(mask.rawValue == (count < 2 ? 0 : 0xffff_ffff_ffff_fffe))
    }

    @Test
    func ellipseExcludesBoundary() {
        let path = Path(ellipseIn: CGRect(x: 10, y: 20, width: 40, height: 20))
        #expect(path.contains(CGPoint(x: 30, y: 30)))
        #expect(!path.contains(CGPoint(x: 10, y: 30)))
        #expect(!path.contains(CGPoint(x: 50, y: 30)))
        #expect(!path.contains(CGPoint(x: 11, y: 21)))
    }

    @Test
    func coordinateConversionUpdatesPath() {
        var transform = ViewTransform()
        transform.appendCoordinateSpace(name: "path")
        transform.appendTranslation(CGSize(width: 3, height: 4))
        var path = Path(CGRect(x: 1, y: 2, width: 10, height: 20))

        path.convert(to: .named("path"), transform: transform)
        #expect(path.boundingRect == CGRect(x: -2, y: -2, width: 10, height: 20))

        path.convert(from: .named("path"), transform: transform)
        #expect(path.boundingRect == CGRect(x: 1, y: 2, width: 10, height: 20))
    }

    #if canImport(CoreGraphics)
    @Test(arguments: [false, true])
    func fillRule(eoFill: Bool) {
        let outline = CGMutablePath()
        outline.addRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        outline.addRect(CGRect(x: 25, y: 25, width: 50, height: 50))
        let path = Path(outline)
        let points = [CGPoint(x: 10, y: 10), CGPoint(x: 50, y: 50), CGPoint(x: 110, y: 50)]

        #expect(path.contains(points[0], eoFill: eoFill))
        #expect(path.contains(points[1], eoFill: eoFill) == !eoFill)
        #expect(!path.contains(points[2], eoFill: eoFill))
        #expect(path.contains(points: points, eoFill: eoFill).rawValue == (eoFill ? 0b001 : 0b011))
    }

    @Test(arguments: [false, true])
    func transformedCurvePreservesControlsAndOwnership(useAffineTransform: Bool) {
        let path: Path = {
            let outline = CGMutablePath()
            outline.move(to: CGPoint(x: 0, y: 0))
            outline.addQuadCurve(to: CGPoint(x: 10, y: 20), control: CGPoint(x: 5, y: 30))
            outline.addCurve(to: CGPoint(x: 40, y: 50), control1: CGPoint(x: 20, y: 60), control2: CGPoint(x: 30, y: 70))
            outline.closeSubpath()
            return Path(outline)
        }()
        let mapped: Path
        if useAffineTransform {
            mapped = path.applying(CGAffineTransform(translationX: 100, y: 200))
        } else {
            mapped = path.mapPoints { points in
                for index in points.indices {
                    points[index].x += 100
                    points[index].y += 200
                }
            }
        }
        var elements: [Path.Element] = []
        mapped.forEach { elements.append($0) }
        #expect(elements == [
            .move(to: CGPoint(x: 100, y: 200)),
            .quadCurve(to: CGPoint(x: 110, y: 220), control: CGPoint(x: 105, y: 230)),
            .curve(to: CGPoint(x: 140, y: 250), control1: CGPoint(x: 120, y: 260), control2: CGPoint(x: 130, y: 270)),
            .closeSubpath,
        ])
    }

    @Test
    func pathUnionKeepsDisjointRegions() {
        var path = Path(CGRect(x: 0, y: 0, width: 10, height: 10))
        let original = path
        path.formTrivialUnion(Path(CGRect(x: 20, y: 0, width: 10, height: 10)))
        #expect(path.contains(CGPoint(x: 5, y: 5)))
        #expect(!path.contains(CGPoint(x: 15, y: 5)))
        #expect(path.contains(CGPoint(x: 25, y: 5)))
        #expect(original.boundingRect == CGRect(x: 0, y: 0, width: 10, height: 10))
    }
    #endif
}
