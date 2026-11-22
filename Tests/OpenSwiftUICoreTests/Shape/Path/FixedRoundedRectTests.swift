//
//  FixedRoundedRectTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenCoreGraphicsShims
@testable import OpenSwiftUICore
import Testing

@Suite(.tags(.aigc))
struct FixedRoundedRectTests {

    // MARK: - Initialization & Properties

    @Test
    func initializersAndEquality() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)
        let plain = FixedRoundedRect(rect)
        #expect(plain.rect == rect)
        #expect(plain.cornerSize == .zero)
        #expect(plain.style == .circular)

        let uniform = FixedRoundedRect(rect, cornerRadius: 12, style: .circular)
        #expect(uniform == FixedRoundedRect(rect, cornerSize: CGSize(width: 12, height: 12), style: .circular))
        #expect(uniform != FixedRoundedRect(rect, cornerRadius: 12, style: .continuous))
        #expect(uniform != FixedRoundedRect(rect, cornerRadius: 15, style: .circular))
    }

    @Test(arguments: [
        (CGSize.zero, RoundedCornerStyle.circular, false, true, false),
        (CGSize(width: 10, height: 10), .circular, true, true, false),
        (CGSize(width: 10, height: 10), .continuous, true, true, true),
        (CGSize.zero, .continuous, false, true, false),
        (CGSize(width: 10, height: 0), .circular, true, false, false),
    ])
    func cornerFlags(
        cornerSize: CGSize,
        style: RoundedCornerStyle,
        isRounded: Bool,
        isUniform: Bool,
        needsContinuousCorners: Bool
    ) {
        let value = FixedRoundedRect(CGRect(x: 0, y: 0, width: 100, height: 50), cornerSize: cornerSize, style: style)
        #expect(value.isRounded == isRounded)
        #expect(value.isUniform == isUniform)
        #expect(value.needsContinuousCorners == needsContinuousCorners)
    }

    @Test(arguments: [
        (CGSize(width: 10, height: 15), CGSize(width: 10, height: 15), 10.0),
        (CGSize(width: 30, height: 30), CGSize(width: 25, height: 25), 25.0),
        (CGSize(width: 40, height: 10), CGSize(width: 25, height: 10), 25.0),
    ])
    func clampedCornerDimensions(input: CGSize, expectedSize: CGSize, expectedRadius: CGFloat) {
        let value = FixedRoundedRect(CGRect(x: 0, y: 0, width: 100, height: 50), cornerSize: input, style: .circular)
        #expect(value.clampedCornerSize == expectedSize)
        #expect(value.clampedCornerRadius == expectedRadius)
    }

    // MARK: - Transforms & Insets

    @Test(arguments: [
        (CGSize.zero, CGRect(x: 0, y: 0, width: 100, height: 50), CGSize(width: 10, height: 10)),
        (CGSize(width: 5, height: 12), CGRect(x: 5, y: 12, width: 90, height: 26), CGSize(width: 5, height: 0)),
        (CGSize(width: 60, height: 30), nil as CGRect?, nil as CGSize?),
    ])
    func insetBy(delta: CGSize, expectedRect: CGRect?, expectedCornerSize: CGSize?) {
        let base = FixedRoundedRect(CGRect(x: 0, y: 0, width: 100, height: 50), cornerRadius: 10, style: .circular)
        let result = base.insetBy(dx: delta.width, dy: delta.height)
        #expect(result?.rect == expectedRect)
        #expect(result?.cornerSize == expectedCornerSize)
    }

    @Test
    func applyingAffineTransformPreservesCornerSigns() {
        let base = FixedRoundedRect(
            CGRect(x: 10, y: 20, width: 40, height: 30),
            cornerSize: CGSize(width: -4, height: 6),
            style: .continuous
        )
        let scaled = base.applying(CGAffineTransform(scaleX: -2, y: 3))
        #expect(scaled.rect == CGRect(x: -100, y: 60, width: 80, height: 90))
        #expect(scaled.cornerSize == CGSize(width: -8, height: 18))
        #expect(scaled.style == .continuous)
    }

    // MARK: - Intersection & Containment

    @Test(arguments: [
        (CGRect(x: 50, y: 25, width: 20, height: 10), true),
        (CGRect(x: 90, y: 40, width: 20, height: 20), true),
        (CGRect(x: 200, y: 200, width: 20, height: 10), false),
    ])
    func hasIntersection(query: CGRect, expected: Bool) {
        let base = FixedRoundedRect(CGRect(x: 0, y: 0, width: 100, height: 50), cornerRadius: 10, style: .circular)
        #expect(base.hasIntersection(query) == expected)
    }

    @Test(arguments: [
        (CGPoint(x: 50, y: 50), true),   // Center
        (CGPoint(x: 50, y: 1), true),    // Near top edge
        (CGPoint(x: 5, y: 5), true),     // Inside rounded corner
        (CGPoint(x: 1, y: 1), false),    // Cut off by top-left corner
        (CGPoint(x: 99, y: 99), false),  // Cut off by bottom-right corner
        (CGPoint(x: 200, y: 200), false),
    ])
    func containsPoint(point: CGPoint, expected: Bool) {
        let rounded = FixedRoundedRect(CGRect(x: 0, y: 0, width: 100, height: 100), cornerRadius: 10, style: .circular)
        #expect(rounded.contains(point) == expected)
    }

    enum ContainedShapeKind: CaseIterable, Sendable {
        case innerRect
        case outerRect
        case circleEllipse
        case nonCircleEllipse
        case innerRoundedRect
        case customLinePath
    }

    @Test(arguments: ContainedShapeKind.allCases)
    func containsPathWithOffset(kind: ContainedShapeKind) {
        let container = FixedRoundedRect(CGRect(x: 0, y: 0, width: 100, height: 100), cornerRadius: 20, style: .circular)
        let offset = CGSize(width: 10, height: 10)

        let (candidate, expected): (Path, Bool) = switch kind {
        case .innerRect:
            (Path(CGRect(x: 10, y: 10, width: 60, height: 60)), true)
        case .outerRect:
            (Path(CGRect(x: 0, y: 0, width: 95, height: 95)), false)
        case .circleEllipse:
            // Circle of diameter 100 at (-10, -10) shifts to (0, 0, 100, 100) with radius 50 >= 20
            (Path(ellipseIn: CGRect(x: -10, y: -10, width: 100, height: 100)), true)
        case .nonCircleEllipse:
            (Path(ellipseIn: CGRect(x: 10, y: 20, width: 60, height: 40)), true)
        case .innerRoundedRect:
            (Path(roundedRect: CGRect(x: 10, y: 10, width: 60, height: 60), cornerRadius: 5, style: .circular), true)
        case .customLinePath:
            (Path { p in p.move(to: CGPoint(x: 10, y: 10)); p.addLine(to: CGPoint(x: 50, y: 50)) }, true)
        }

        #expect(container.contains(path: candidate, offsetBy: offset) == expected)
    }

    @Test
    func containsUsesShortestDimensionForClamping() {
        let pill = FixedRoundedRect(CGRect(x: 0, y: 0, width: 100, height: 20), cornerSize: CGSize(width: 50, height: 10), style: .circular)
        #expect(pill.contains(rect: CGRect(x: 4, y: 4, width: 92, height: 12)))
        #expect(!pill.contains(rect: CGRect(x: 1, y: 1, width: 98, height: 18)))
    }

    // MARK: - CGPath & Protobuf

    @Test(arguments: [RoundedCornerStyle.circular, .continuous])
    func cgPathAndProtobufRoundTrip(style: RoundedCornerStyle) throws {
        let original = FixedRoundedRect(
            CGRect(x: 5, y: 10, width: 80, height: 40),
            cornerSize: CGSize(width: 8, height: 6),
            style: style
        )

        let bounds = original.cgPath.boundingBoxOfPath
        #expect(abs(bounds.origin.x - 5) < 1e-5)
        #expect(abs(bounds.origin.y - 10) < 1e-5)
        #expect(abs(bounds.size.width - 80) < 1e-5)
        #expect(abs(bounds.size.height - 40) < 1e-5)

        let encoded = try ProtobufEncoder.encoding(original)
        var decoder = ProtobufDecoder(encoded)
        let decoded = try FixedRoundedRect(from: &decoder)
        #expect(decoded == original)

        #expect(RoundedCornerStyle(protobufValue: style.protobufValue) == style)
        #expect(RoundedCornerStyle(protobufValue: 99) == nil)
    }

    // MARK: - RectangleCornerRadii

    @Test
    func rectangleCornerRadiiAccessorsAndAnimatableData() {
        var radii = RectangleCornerRadii(topLeading: 1, bottomLeading: 2, bottomTrailing: 3, topTrailing: 4)
        #expect(radii.topLeft == 1)
        #expect(radii.bottomLeft == 2)
        #expect(radii.bottomRight == 3)
        #expect(radii.topRight == 4)

        radii.topLeading = 10
        radii.bottomLeading = 20
        radii.bottomTrailing = 30
        radii.topTrailing = 40

        var copy = RectangleCornerRadii()
        copy.animatableData = radii.animatableData
        #expect(copy == radii)
    }

    #if canImport(Darwin)
    @Test(arguments: [
        (CGRect(x: 0, y: 0, width: 100, height: 100), 10.0, RoundedCornerStyle.circular),
        (CGRect(x: 10, y: 20, width: 80, height: 60), 15.0, RoundedCornerStyle.continuous),
        (CGRect(x: 10, y: 20, width: -80, height: -60), 15.0, RoundedCornerStyle.circular),
    ])
    func withTemporaryPathPreservesRawRect(rect: CGRect, cornerRadius: CGFloat, style: RoundedCornerStyle) {
        let roundedRect = FixedRoundedRect(rect, cornerRadius: cornerRadius, style: style)
        let boundingRect = roundedRect.withTemporaryPath { $0.storage.boundingRect }
        #expect(boundingRect.origin == rect.origin)
        #expect(boundingRect.size == rect.size)
    }
    #endif
}
