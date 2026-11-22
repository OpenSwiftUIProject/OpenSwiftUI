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

    // MARK: - Initialization & Introspection

    struct Initialization {
        enum DegenerateInput: CaseIterable, Sendable {
            case empty
            case nullRect
            case nullEllipse
            case nullRoundedRect
            case nullUnevenRoundedRect
            case emptyCGPath
            case emptyMutableCGPath
        }

        @Test(arguments: DegenerateInput.allCases)
        func degenerateInputsNormalizeToEmpty(input: DegenerateInput) {
            let path: Path = switch input {
            case .empty:
                Path()
            case .nullRect:
                Path(CGRect.null)
            case .nullEllipse:
                Path(ellipseIn: .null)
            case .nullRoundedRect:
                Path(roundedRect: .null, cornerRadius: 8)
            case .nullUnevenRoundedRect:
                Path(roundedRect: .null, cornerRadii: .init(topLeading: 8))
            case .emptyCGPath:
                Path(CGMutablePath() as CGPath)
            case .emptyMutableCGPath:
                Path(CGMutablePath())
            }

            #expect(path.isEmpty)
            #expect(path.boundingRect == .null)
            #expect(path.currentPoint == nil)
            #expect(path.rect() == nil)
            #expect(path.roundedRect() == nil)
        }

        enum RectFallbackInput: CaseIterable, Sendable {
            case plainRect
            case zeroCornerRadius
            case zeroCornerSize
            case infiniteEllipse
            case infiniteRoundedRect
        }

        @Test(arguments: RectFallbackInput.allCases)
        func rectAndDegenerateRoundedInitializersStoreRect(input: RectFallbackInput) {
            let rect = CGRect(x: 10, y: 20, width: 80, height: 40)
            let (path, expectedRect): (Path, CGRect) = switch input {
            case .plainRect:
                (Path(rect), rect)
            case .zeroCornerRadius:
                (Path(roundedRect: rect, cornerRadius: 0), rect)
            case .zeroCornerSize:
                (Path(roundedRect: rect, cornerSize: .zero), rect)
            case .infiniteEllipse:
                (Path(ellipseIn: .infinite), .infinite)
            case .infiniteRoundedRect:
                (Path(roundedRect: .infinite, cornerRadius: 10), .infinite)
            }

            #expect(path.rect() == expectedRect)
        }

        @Test(arguments: [
            (CGRect(x: 0, y: 0, width: 40, height: 40), true),
            (CGRect(x: 0, y: 0, width: 40, height: 20), false),
        ])
        func roundedRectIntrospection(ellipseRect: CGRect, isCircle: Bool) {
            let ellipse = Path(ellipseIn: ellipseRect)
            #expect(ellipse.rect() == nil)
            if isCircle {
                #expect(ellipse.roundedRect() == FixedRoundedRect(ellipseRect, cornerRadius: 20, style: .circular))
            } else {
                #expect(ellipse.roundedRect() == nil)
            }

            let rounded = Path(roundedRect: ellipseRect, cornerSize: CGSize(width: 6, height: 8), style: .continuous)
            #expect(rounded.rect() == nil)
            #expect(rounded.roundedRect() == FixedRoundedRect(ellipseRect, cornerSize: CGSize(width: 6, height: 8), style: .continuous))
        }

        @Test
        func mutableCGPathAndBuilderClosureCopyIndependently() {
            let mutable = CGMutablePath()
            mutable.move(to: CGPoint(x: 0, y: 0))
            mutable.addLine(to: CGPoint(x: 10, y: 20))
            let fromMutable = Path(mutable)
            mutable.addLine(to: CGPoint(x: 100, y: 200))

            let fromClosure = Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 10, y: 20))
            }

            #expect(fromMutable == fromClosure)
            #expect(fromMutable.boundingRect == CGRect(x: 0, y: 0, width: 10, height: 20))
        }
    }

    // MARK: - Subpaths & Element Construction

    struct ElementsAndSubpaths {
        @Test
        func curveElementsAndCopyOnWrite() {
            var path = Path()
            path.move(to: CGPoint(x: 1, y: 2))
            path.addLine(to: CGPoint(x: 3, y: 4))
            let snapshot = path

            path.addQuadCurve(to: CGPoint(x: 7, y: 8), control: CGPoint(x: 5, y: 6))
            path.addCurve(to: CGPoint(x: 13, y: 14), control1: CGPoint(x: 9, y: 10), control2: CGPoint(x: 11, y: 12))
            path.closeSubpath()

            #expect(elements(of: path) == [
                .move(to: CGPoint(x: 1, y: 2)),
                .line(to: CGPoint(x: 3, y: 4)),
                .quadCurve(to: CGPoint(x: 7, y: 8), control: CGPoint(x: 5, y: 6)),
                .curve(to: CGPoint(x: 13, y: 14), control1: CGPoint(x: 9, y: 10), control2: CGPoint(x: 11, y: 12)),
                .closeSubpath,
            ])
            #expect(elements(of: snapshot) == [
                .move(to: CGPoint(x: 1, y: 2)),
                .line(to: CGPoint(x: 3, y: 4)),
            ])
            #expect(snapshot.currentPoint == CGPoint(x: 3, y: 4))
        }

        @Test(arguments: [
            ([], true, nil as CGPoint?),
            ([CGPoint(x: 1, y: 2), CGPoint(x: 5, y: 6), CGPoint(x: 9, y: 10)], false, CGPoint(x: 9, y: 10)),
        ])
        func addLines(points: [CGPoint], expectsEmpty: Bool, expectedCurrent: CGPoint?) {
            var path = Path()
            path.addLines(points)

            #expect(path.isEmpty == expectsEmpty)
            #expect(path.currentPoint == expectedCurrent)
        }

        @Test(arguments: [
            ([] as [CGRect], CGRect.null, nil as CGRect?),
            ([CGRect(x: 0, y: 0, width: 10, height: 20)], CGRect(x: 0, y: 0, width: 10, height: 20), CGRect(x: 0, y: 0, width: 10, height: 20)),
            ([CGRect(x: 0, y: 0, width: 10, height: 10), CGRect(x: 20, y: 30, width: 10, height: 10)], CGRect(x: 0, y: 0, width: 30, height: 40), nil),
        ])
        func addRects(rects: [CGRect], expectedBounds: CGRect, expectedSingleRect: CGRect?) {
            var path = Path()
            path.addRects(rects)

            #expect(path.boundingRect == expectedBounds)
            #expect(path.rect() == expectedSingleRect)
        }

        enum BufferedPrimitive: CaseIterable, Sendable {
            case rect, ellipse, roundedRect
        }

        @Test(arguments: BufferedPrimitive.allCases)
        func bufferedPrimitivesPreserveNegativeRectSizes(primitive: BufferedPrimitive) {
            let rect = CGRect(x: 10, y: 20, width: -6, height: -8)
            let transform = CGAffineTransform(translationX: 100, y: 200)
            var path = Path()
            path.move(to: CGPoint(x: 107, y: 216))

            switch primitive {
            case .rect:
                path.addRect(rect, transform: transform)
            case .ellipse:
                path.addEllipse(in: rect, transform: transform)
            case .roundedRect:
                path.addRoundedRect(in: rect, cornerSize: CGSize(width: 1, height: 2), style: .circular, transform: transform)
            }

            #expect(path.boundingRect == CGRect(x: 104, y: 212, width: 6, height: 8))
        }

        enum ArcKind: CaseIterable, Sendable {
            case startEndAngles
            case relativeDelta
            case tangentCorner
        }

        @Test(arguments: ArcKind.allCases)
        func arcsPreserveTransformedEndpoints(kind: ArcKind) throws {
            var path = Path()
            let transform = CGAffineTransform(translationX: 5, y: 7)

            let expectedStart: CGPoint
            let expectedEnd: CGPoint
            switch kind {
            case .startEndAngles:
                path.addArc(
                    center: CGPoint(x: 20, y: 30),
                    radius: 10,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false,
                    transform: transform
                )
                expectedStart = CGPoint(x: 35, y: 37)
                expectedEnd = CGPoint(x: 25, y: 47)
            case .relativeDelta:
                path.addRelativeArc(
                    center: CGPoint(x: 20, y: 30),
                    radius: 10,
                    startAngle: .degrees(0),
                    delta: .degrees(90),
                    transform: transform
                )
                expectedStart = CGPoint(x: 35, y: 37)
                expectedEnd = CGPoint(x: 25, y: 47)
            case .tangentCorner:
                path.move(to: CGPoint(x: 5, y: 7))
                path.addArc(
                    tangent1End: CGPoint(x: 10, y: 0),
                    tangent2End: CGPoint(x: 10, y: 10),
                    radius: 4,
                    transform: transform
                )
                expectedStart = CGPoint(x: 5, y: 7)
                expectedEnd = CGPoint(x: 15, y: 11)
            }

            let recorded = elements(of: path)
            #expect(recorded.first == .move(to: expectedStart))
            let end = try #require(path.currentPoint)
            #expect(abs(end.x - expectedEnd.x) < 1e-5)
            #expect(abs(end.y - expectedEnd.y) < 1e-5)
        }

        @Test(arguments: [false, true])
        func addPathIntoEmptyAndNonEmptyBase(intoEmpty: Bool) {
            let child = Path(CGRect(x: 0, y: 0, width: 10, height: 10))
            let offset = CGAffineTransform(translationX: 20, y: 30)

            var path = intoEmpty ? Path() : Path(CGRect(x: 0, y: 0, width: 5, height: 5))
            path.addPath(child, transform: offset)
            path.addPath(Path())

            if intoEmpty {
                #expect(path.rect() == CGRect(x: 20, y: 30, width: 10, height: 10))
            } else {
                #expect(path.boundingRect == CGRect(x: 0, y: 0, width: 30, height: 40))
            }
        }
    }

    // MARK: - Containment

    struct Containment {
        @Test(arguments: [
            (CGPoint(x: 30, y: 30), true),  // Center
            (CGPoint(x: 10, y: 30), false), // Left boundary
            (CGPoint(x: 50, y: 30), false), // Right boundary
            (CGPoint(x: 11, y: 21), false), // Bounding-box corner outside ellipse
        ])
        func ellipseInteriorAndBoundary(point: CGPoint, expected: Bool) {
            let ellipse = Path(ellipseIn: CGRect(x: 10, y: 20, width: 40, height: 20))
            #expect(ellipse.contains(point) == expected)
        }

        @Test(arguments: [
            (CGPoint(x: 111, y: 221), true),  // Top-leading radius 0 (sharp corner)
            (CGPoint(x: 209, y: 221), false), // Top-trailing radius 10 (outside arc)
            (CGPoint(x: 205, y: 225), true),  // Top-trailing radius 10 (inside arc)
            (CGPoint(x: 111, y: 319), false), // Bottom-leading radius 20 (outside arc)
            (CGPoint(x: 202, y: 312), false), // Bottom-trailing radius 30 (outside arc)
            (CGPoint(x: 200, y: 310), true),  // Bottom-trailing radius 30 (inside arc)
        ])
        func unevenRoundedRectCorners(point: CGPoint, expected: Bool) {
            var path = Path()
            path.addRoundedRect(
                in: CGRect(x: 10, y: 20, width: 100, height: 100),
                cornerRadii: RectangleCornerRadii(topLeading: 0, bottomLeading: 20, bottomTrailing: 30, topTrailing: 10),
                style: .circular,
                transform: CGAffineTransform(translationX: 100, y: 200)
            )
            #expect(path.contains(point) == expected)
        }

        @Test(arguments: [false, true])
        func windingVersusEvenOddFillRule(eoFill: Bool) {
            let concentric = CGMutablePath()
            concentric.addRect(CGRect(x: 0, y: 0, width: 100, height: 100))
            concentric.addRect(CGRect(x: 25, y: 25, width: 50, height: 50))
            let path = Path(concentric)
            let queries = [CGPoint(x: 10, y: 10), CGPoint(x: 50, y: 50), CGPoint(x: 110, y: 50)]

            #expect(path.contains(queries[0], eoFill: eoFill))
            #expect(path.contains(queries[1], eoFill: eoFill) == !eoFill)
            #expect(!path.contains(queries[2], eoFill: eoFill))
            #expect((path.contains(points: queries, eoFill: eoFill).rawValue & 0b111) == (eoFill ? 0b001 : 0b011))
        }

        @Test(arguments: [0, 1, 64, 65])
        func batchContainmentMaskAndOrigin(count: Int) {
            let path = Path(CGRect(x: 0, y: 0, width: 10, height: 10))
            var points = Array(repeating: CGPoint(x: 25, y: 35), count: count)
            if count > 0 {
                points[0] = CGPoint(x: 35, y: 35)
            }
            let mask = path.contains(points: points, origin: CGPoint(x: 20, y: 30))
            #expect(mask.rawValue == (count < 2 ? 0 : 0xffff_ffff_ffff_fffe))
        }
    }

    // MARK: - Transforms & Coordinate Spaces

    struct Transforms {
        enum TransformMethod: CaseIterable, Sendable {
            case applying
            case offsetBy
            case mapPoints
        }

        @Test(arguments: TransformMethod.allCases)
        func translationMethodsPreserveGeometry(method: TransformMethod) {
            let base = Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: 10, y: 20), control: CGPoint(x: 5, y: 30))
                path.addCurve(to: CGPoint(x: 40, y: 50), control1: CGPoint(x: 20, y: 60), control2: CGPoint(x: 30, y: 70))
                path.closeSubpath()
            }

            let translated: Path = switch method {
            case .applying:
                base.applying(CGAffineTransform(translationX: 100, y: 200))
            case .offsetBy:
                base.offsetBy(dx: 100, dy: 200)
            case .mapPoints:
                base.mapPoints { points in
                    for i in points.indices {
                        points[i].x += 100
                        points[i].y += 200
                    }
                }
            }

            #expect(elements(of: translated) == [
                .move(to: CGPoint(x: 100, y: 200)),
                .quadCurve(to: CGPoint(x: 110, y: 220), control: CGPoint(x: 105, y: 230)),
                .curve(to: CGPoint(x: 140, y: 250), control1: CGPoint(x: 120, y: 260), control2: CGPoint(x: 130, y: 270)),
                .closeSubpath,
            ])
        }

        @Test
        func identityOffsetAndShearMapPoints() {
            let rectPath = Path(CGRect(x: 0, y: 0, width: 10, height: 20))
            #expect(rectPath.offsetBy(dx: 0, dy: 0) == rectPath)
            #expect(rectPath.applying(.identity) == rectPath)

            let sheared = rectPath.mapPoints { points in
                for i in points.indices {
                    points[i].x += points[i].y
                }
            }
            #expect(sheared.rect() == nil)
            #expect(sheared.boundingRect == CGRect(x: 0, y: 0, width: 30, height: 20))
        }

        @Test
        func coordinateSpaceConversion() {
            var transform = ViewTransform()
            transform.appendCoordinateSpace(name: "canvas")
            transform.appendTranslation(CGSize(width: 3, height: 4))
            var path = Path(CGRect(x: 1, y: 2, width: 10, height: 20))

            path.convert(to: .named("canvas"), transform: transform)
            #expect(path.boundingRect == CGRect(x: -2, y: -2, width: 10, height: 20))

            path.convert(from: .named("canvas"), transform: transform)
            #expect(path.boundingRect == CGRect(x: 1, y: 2, width: 10, height: 20))
        }
    }

    // MARK: - Path Operations

    struct Operations {
        @Test
        func shapeConformanceReturnsSelf() {
            let path = Path(CGRect(x: 5, y: 6, width: 20, height: 30))
            #expect(path.path(in: CGRect(x: 0, y: 0, width: 500, height: 500)) == path)
        }

        enum TrivialUnionScenario: CaseIterable, Sendable {
            case ignoresEmpty
            case outerKeepsSelf
            case innerAdoptsOuter
            case disjointCombinesBoth
        }

        @Test(arguments: TrivialUnionScenario.allCases)
        func formTrivialUnion(scenario: TrivialUnionScenario) {
            let outer = Path(CGRect(x: 0, y: 0, width: 100, height: 100))
            let inner = Path(CGRect(x: 20, y: 20, width: 40, height: 40))
            let disjoint = Path(CGRect(x: 200, y: 0, width: 50, height: 50))

            switch scenario {
            case .ignoresEmpty:
                var path = inner
                path.formTrivialUnion(Path())
                #expect(path == inner)
            case .outerKeepsSelf:
                var path = outer
                path.formTrivialUnion(inner)
                #expect(path == outer)
            case .innerAdoptsOuter:
                var path = inner
                path.formTrivialUnion(outer)
                #expect(path == outer)
            case .disjointCombinesBoth:
                var path = inner
                path.formTrivialUnion(disjoint)
                #expect(path.contains(CGPoint(x: 30, y: 30)))
                #expect(!path.contains(CGPoint(x: 120, y: 30)))
                #expect(path.contains(CGPoint(x: 220, y: 20)))
            }
        }

        @Test(arguments: [
            (0.0, CGRect(x: 0, y: 0, width: 20, height: 20)),
            (0.5, CGRect(x: 10, y: 20, width: 30, height: 40)),
            (1.0, CGRect(x: 20, y: 40, width: 40, height: 60)),
        ])
        func mixInterpolatesCompatiblePaths(fraction: CGFloat, expectedBounds: CGRect) throws {
            let start = Path(CGRect(x: 0, y: 0, width: 20, height: 20))
            let end = Path(CGRect(x: 20, y: 40, width: 40, height: 60))
            let mixed = try #require(start.mix(with: end, by: fraction))
            #expect(mixed.boundingRect == expectedBounds)
        }

        #if canImport(Darwin)
        @Test(arguments: [
            (CGLineCap.butt, CGRect(x: 0, y: -5, width: 100, height: 10)),
            (CGLineCap.square, CGRect(x: -5, y: -5, width: 110, height: 10)),
        ])
        func strokedPathLineWidthAndCap(lineCap: CGLineCap, expectedBounds: CGRect) {
            #expect(Path().strokedPath(StrokeStyle(lineWidth: 10)).isEmpty)

            let segment = Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 100, y: 0))
            }
            let stroked = segment.strokedPath(StrokeStyle(lineWidth: 10, lineCap: lineCap))
            #expect(stroked.boundingRect == expectedBounds)
        }

        enum FillBooleanOp: CaseIterable, Sendable {
            case union
            case intersection
            case subtracting
            case symmetricDifference
        }

        @Test(arguments: FillBooleanOp.allCases)
        func booleanRegionOperations(op: FillBooleanOp) {
            let lhs = Path(CGRect(x: 0, y: 0, width: 100, height: 100))
            let rhs = Path(CGRect(x: 50, y: 0, width: 100, height: 100))

            let (result, inLeftOnly, inOverlap, inRightOnly): (Path, Bool, Bool, Bool) = switch op {
            case .union:
                (lhs.union(rhs), true, true, true)
            case .intersection:
                (lhs.intersection(rhs), false, true, false)
            case .subtracting:
                (lhs.subtracting(rhs), true, false, false)
            case .symmetricDifference:
                (lhs.symmetricDifference(rhs), true, false, true)
            }

            #expect(result.contains(CGPoint(x: 25, y: 50)) == inLeftOnly)
            #expect(result.contains(CGPoint(x: 75, y: 50)) == inOverlap)
            #expect(result.contains(CGPoint(x: 125, y: 50)) == inRightOnly)
        }

        @Test
        func lineClippingNormalizationAndDilation() {
            let line = Path { path in
                path.move(to: CGPoint(x: 0, y: 50))
                path.addLine(to: CGPoint(x: 100, y: 50))
            }
            let mask = Path(CGRect(x: 25, y: 0, width: 50, height: 100))

            #expect(line.lineIntersection(mask).boundingRect == CGRect(x: 25, y: 50, width: 50, height: 0))
            #expect(line.lineSubtraction(mask).boundingRect == CGRect(x: 0, y: 50, width: 100, height: 0))

            let rect = Path(CGRect(x: 10, y: 20, width: 30, height: 40))
            #expect(rect.normalized().contains(CGPoint(x: 25, y: 40)))
            #expect(rect.dilatedGlyphPath(with: .zero) == rect)
            // Glyph dilation expands horizontally by ±width and vertically from baseline by [0, 2 * height].
            #expect(rect.dilatedGlyphPath(with: CGSize(width: 2, height: 3)).boundingRect == CGRect(x: 8, y: 20, width: 34, height: 46))
        }
        #endif
    }

    // MARK: - String, CGPath & Protobuf Representations

    struct Representations {
        @Test(arguments: [
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
        ])
        func validStringRoundTrip(input: String, expectedDescription: String) {
            #expect(Path(input)?.description == expectedDescription)
        }

        @Test(arguments: ["0 0 z", "0 m", "1 2 3 4 5 6 7 m", "10 20 rx"])
        func invalidStringReturnsNil(input: String) {
            #expect(Path(input) == nil)
        }

        enum StorageSample: CaseIterable, Sendable {
            case empty
            case rect
            case ellipse
            case circularRoundedRect
            case continuousRoundedRect
            case customSubpath

            var path: Path {
                let rect = CGRect(x: 10, y: 20, width: 80, height: 40)
                return switch self {
                case .empty:
                    Path()
                case .rect:
                    Path(rect)
                case .ellipse:
                    Path(ellipseIn: rect)
                case .circularRoundedRect:
                    Path(roundedRect: rect, cornerSize: CGSize(width: 10, height: 8), style: .circular)
                case .continuousRoundedRect:
                    Path(roundedRect: rect, cornerSize: CGSize(width: 10, height: 8), style: .continuous)
                case .customSubpath:
                    Path { path in
                        path.move(to: CGPoint(x: 1, y: 2))
                        path.addLine(to: CGPoint(x: 3, y: 4))
                        path.addQuadCurve(to: CGPoint(x: 7, y: 8), control: CGPoint(x: 5, y: 6))
                        path.addCurve(to: CGPoint(x: 13, y: 14), control1: CGPoint(x: 9, y: 10), control2: CGPoint(x: 11, y: 12))
                        path.closeSubpath()
                    }
                }
            }
        }

        @Test(arguments: StorageSample.allCases)
        func cgPathMatchesBounds(sample: StorageSample) {
            let path = sample.path
            let cgBounds = path.cgPath.boundingBoxOfPath

            if sample == .empty {
                #expect(cgBounds == .null)
                #expect(path.description == "inf inf m inf inf l inf inf l inf inf l h")
            } else {
                let expected = path.boundingRect
                #expect(abs(cgBounds.origin.x - expected.origin.x) < 1e-5)
                #expect(abs(cgBounds.origin.y - expected.origin.y) < 1e-5)
                #expect(abs(cgBounds.size.width - expected.size.width) < 1e-5)
                #expect(abs(cgBounds.size.height - expected.size.height) < 1e-5)
            }
        }

        @Test(arguments: StorageSample.allCases)
        func protobufRoundTrip(sample: StorageSample) throws {
            let original = sample.path
            let encoded = try ProtobufEncoder.encoding(original)
            var decoder = ProtobufDecoder(encoded)
            let decoded = try Path(from: &decoder)
            #expect(decoded == original)
        }
    }
}

private func elements(of path: Path) -> [Path.Element] {
    var result: [Path.Element] = []
    path.forEach { result.append($0) }
    return result
}
