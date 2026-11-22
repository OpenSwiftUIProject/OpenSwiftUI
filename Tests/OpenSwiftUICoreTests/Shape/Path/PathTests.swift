//
//  PathTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenCoreGraphicsShims
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

    @Test
    func protobufRoundTrip() throws {
        var customPath = Path()
        customPath.move(to: CGPoint(x: 1, y: 2))
        customPath.addLine(to: CGPoint(x: 3, y: 4))
        customPath.addQuadCurve(to: CGPoint(x: 7, y: 8), control: CGPoint(x: 5, y: 6))
        customPath.addCurve(to: CGPoint(x: 13, y: 14), control1: CGPoint(x: 9, y: 10), control2: CGPoint(x: 11, y: 12))
        customPath.closeSubpath()

        let cases: [Path] = [
            Path(),
            Path(CGRect(x: 1, y: 2, width: 30, height: 40)),
            Path(ellipseIn: CGRect(x: 3, y: 4, width: 20, height: 10)),
            Path(roundedRect: CGRect(x: 0, y: 0, width: 50, height: 30), cornerSize: CGSize(width: 6, height: 8), style: .continuous),
            customPath,
        ]

        for original in cases {
            let encoded = try ProtobufEncoder.encoding(original)
            var decoder = ProtobufDecoder(encoded)
            let decoded = try Path(from: &decoder)
            #expect(decoded == original)
        }
    }

    @Test
    func cgPathAcrossStorages() {
        #expect(Path().cgPath.boundingBoxOfPath == .null)

        let rect = CGRect(x: 10, y: 20, width: 80, height: 40)
        #expect(Path(rect).cgPath == CGPath(rect: rect, transform: nil))
        let ellipseBounds = Path(ellipseIn: rect).cgPath.boundingBoxOfPath
        #expect(abs(ellipseBounds.origin.x - 10) < 1e-6)
        #expect(abs(ellipseBounds.origin.y - 20) < 1e-6)
        #expect(abs(ellipseBounds.size.width - 80) < 1e-6)
        #expect(abs(ellipseBounds.size.height - 40) < 1e-6)

        let circular = Path(roundedRect: rect, cornerSize: CGSize(width: 10, height: 8), style: .circular).cgPath
        let circularBounds = circular.boundingBoxOfPath
        #expect(abs(circularBounds.origin.x - 10) < 1e-6)
        #expect(abs(circularBounds.origin.y - 20) < 1e-6)
        #expect(abs(circularBounds.size.width - 80) < 1e-6)
        #expect(abs(circularBounds.size.height - 40) < 1e-6)
        #expect(abs(circular.currentPoint.x - 90) < 1e-6)
        #expect(abs(circular.currentPoint.y - 40) < 1e-6)

        let continuous = Path(roundedRect: rect, cornerSize: CGSize(width: 10, height: 8), style: .continuous).cgPath
        let continuousBounds = continuous.boundingBoxOfPath
        #expect(abs(continuousBounds.origin.x - 10) < 1e-5)
        #expect(abs(continuousBounds.origin.y - 20) < 1e-5)
        #expect(abs(continuousBounds.size.width - 80) < 1e-5)
        #expect(abs(continuousBounds.size.height - 40) < 1e-5)

        let oversizedCircular = FixedRoundedRect(rect, cornerSize: CGSize(width: 100, height: 100), style: .circular).cgPath
        #expect(abs(oversizedCircular.boundingBoxOfPath.size.width - 80) < 1e-6)
        #expect(abs(oversizedCircular.boundingBoxOfPath.size.height - 40) < 1e-6)

        var custom = Path()
        custom.move(to: CGPoint(x: 2, y: 3))
        custom.addLine(to: CGPoint(x: 12, y: 23))
        #expect(custom.cgPath.boundingBoxOfPath == CGRect(x: 2, y: 3, width: 10, height: 20))
    }

    @Test
    func stringRepresentationAndParsing() {
        #expect(Path().description == "inf inf m inf inf l inf inf l inf inf l h")

        let validCases: [(String, String)] = [
            ("100 0 m 200 100 l h", "100 0 m 200 100 l h"),
            ("0 0 m 50 0 100 100 q", "0 0 m 50 0 100 100 q"),
            ("0 0 m 25 0 75 100 100 100 c", "0 0 m 25 0 75 100 100 100 c"),
            ("0 0 m 50 0 100 100 q 200 0 t", "0 0 m 50 0 100 100 q 150 200 200 0 q"),
            ("0 0 m 50 50 100 100 v", "0 0 m 0 0 50 50 100 100 c"),
            ("0 0 m 25 0 100 100 y", "0 0 m 25 0 100 100 100 100 c"),
            ("10 20 30 40 re", "10 20 m 40 20 l 40 60 l 10 60 l h"),
            ("-10 -20 m 0.5 1.5 l", "-10 -20 m 0.5 1.5 l"),
            ("0\t0\nm\r\n100\t100\tl", "0 0 m 100 100 l"),
            ("100 200m", "100 200 m"),
            ("1.5e2 -2.5e1 m", "150 -25 m"),
        ]

        for (input, expected) in validCases {
            let parsed = Path(input)
            #expect(parsed != nil)
            #expect(parsed?.description == expected)
        }

        #expect(Path("Inf -inf m") != nil)

        for invalid in ["0 0 z", "0 m", "1 2 3 4 5 6 7 m", "10 20 rx"] {
            #expect(Path(invalid) == nil)
        }
    }

    @Test
    func appendingElementsPreservesControlsAndOriginalCopy() {
        var path = Path()
        path.move(to: CGPoint(x: 1, y: 2))
        path.addLine(to: CGPoint(x: 3, y: 4))
        let original = path
        path.addQuadCurve(to: CGPoint(x: 7, y: 8), control: CGPoint(x: 5, y: 6))
        path.addCurve(to: CGPoint(x: 13, y: 14), control1: CGPoint(x: 9, y: 10), control2: CGPoint(x: 11, y: 12))
        path.closeSubpath()

        var elements: [Path.Element] = []
        path.forEach { elements.append($0) }
        #expect(elements == [
            .move(to: CGPoint(x: 1, y: 2)),
            .line(to: CGPoint(x: 3, y: 4)),
            .quadCurve(to: CGPoint(x: 7, y: 8), control: CGPoint(x: 5, y: 6)),
            .curve(to: CGPoint(x: 13, y: 14), control1: CGPoint(x: 9, y: 10), control2: CGPoint(x: 11, y: 12)),
            .closeSubpath,
        ])
        var originalElements: [Path.Element] = []
        original.forEach { originalElements.append($0) }
        #expect(originalElements == [
            .move(to: CGPoint(x: 1, y: 2)),
            .line(to: CGPoint(x: 3, y: 4)),
        ])
        #expect(original.currentPoint == CGPoint(x: 3, y: 4))
    }

    enum BufferedShape: CaseIterable {
        case rect, ellipse, roundedRect
    }

    @Test(arguments: BufferedShape.allCases)
    func bufferedShapesPreserveNegativeRectSizes(shape: BufferedShape) {
        let rect = CGRect(x: 10, y: 20, width: -6, height: -8)
        let transform = CGAffineTransform(translationX: 100, y: 200)
        var path = Path()
        // Keep the append operation on the buffer path.
        path.move(to: CGPoint(x: 107, y: 216))
        switch shape {
        case .rect:
            path.addRect(rect, transform: transform)
        case .ellipse:
            path.addEllipse(in: rect, transform: transform)
        case .roundedRect:
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: 1, height: 2), style: .circular, transform: transform)
        }

        #expect(path.boundingRect == CGRect(x: 104, y: 212, width: 6, height: 8))
    }

    @Test
    func transformedRoundedRectPreservesAsymmetricCorners() {
        var path = Path()
        path.addRoundedRect(
            in: CGRect(x: 10, y: 20, width: 100, height: 100),
            cornerRadii: RectangleCornerRadii(topLeading: 0, bottomLeading: 20, bottomTrailing: 30, topTrailing: 10),
            style: .circular,
            transform: CGAffineTransform(translationX: 100, y: 200)
        )

        #expect(path.boundingRect == CGRect(x: 110, y: 220, width: 100, height: 100))
        #expect(path.contains(CGPoint(x: 111, y: 221)))
        #expect(!path.contains(CGPoint(x: 209, y: 221)))
        #expect(path.contains(CGPoint(x: 205, y: 225)))
        #expect(!path.contains(CGPoint(x: 111, y: 319)))
        #expect(path.contains(CGPoint(x: 118, y: 312)))
        #expect(!path.contains(CGPoint(x: 202, y: 312)))
        #expect(path.contains(CGPoint(x: 200, y: 310)))
    }

    @Test(arguments: [false, true])
    func transformedArcPreservesEndpoints(relative: Bool) throws {
        var path = Path()
        let transform = CGAffineTransform(translationX: 5, y: 7)
        if relative {
            path.addRelativeArc(
                center: CGPoint(x: 20, y: 30),
                radius: 10,
                startAngle: .degrees(0),
                delta: .degrees(90),
                transform: transform
            )
        } else {
            path.addArc(
                center: CGPoint(x: 20, y: 30),
                radius: 10,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false,
                transform: transform
            )
        }

        var elements: [Path.Element] = []
        path.forEach { elements.append($0) }
        #expect(elements.first == .move(to: CGPoint(x: 35, y: 37)))
        let end = try #require(path.currentPoint)
        // Storage can encode arc angles as Float.
        #expect(abs(end.x - 25) < 1e-6)
        #expect(abs(end.y - 47) < 1e-6)
    }

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
        #expect((path.contains(points: points, eoFill: eoFill).rawValue & 0b111) == (eoFill ? 0b001 : 0b011))
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
}
