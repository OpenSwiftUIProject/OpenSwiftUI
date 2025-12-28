//
//  FixedRoundedRectTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUICore
import Foundation
import Testing

struct FixedRoundedRectTests {
    // MARK: - Initialization

    @Test
    func initWithRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)
        let roundedRect = FixedRoundedRect(rect)
        #expect(roundedRect.rect == rect)
        #expect(roundedRect.cornerSize == .zero)
        #expect(roundedRect.style == .circular)
    }

    @Test
    func initWithCornerSize() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let cornerSize = CGSize(width: 10, height: 15)
        let roundedRect = FixedRoundedRect(rect, cornerSize: cornerSize, style: .continuous)
        #expect(roundedRect.rect == rect)
        #expect(roundedRect.cornerSize == cornerSize)
        #expect(roundedRect.style == .continuous)
    }

    @Test
    func initWithCornerRadius() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let roundedRect = FixedRoundedRect(rect, cornerRadius: 12, style: .circular)
        #expect(roundedRect.rect == rect)
        #expect(roundedRect.cornerSize == CGSize(width: 12, height: 12))
        #expect(roundedRect.style == .circular)
    }

    // MARK: - Properties

    @Test
    func isRounded() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let notRounded = FixedRoundedRect(rect)
        #expect(notRounded.isRounded == false)

        let rounded = FixedRoundedRect(rect, cornerRadius: 10, style: .circular)
        #expect(rounded.isRounded == true)

        let partiallyRounded = FixedRoundedRect(rect, cornerSize: CGSize(width: 5, height: 0), style: .circular)
        #expect(partiallyRounded.isRounded == true)
    }

    @Test
    func isUniform() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let uniform = FixedRoundedRect(rect, cornerRadius: 10, style: .circular)
        #expect(uniform.isUniform == true)

        let nonUniform = FixedRoundedRect(rect, cornerSize: CGSize(width: 10, height: 15), style: .circular)
        #expect(nonUniform.isUniform == false)
    }

    @Test
    func needsContinuousCorners() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let circularRounded = FixedRoundedRect(rect, cornerRadius: 10, style: .circular)
        #expect(circularRounded.needsContinuousCorners == false)

        let continuousRounded = FixedRoundedRect(rect, cornerRadius: 10, style: .continuous)
        #expect(continuousRounded.needsContinuousCorners == true)

        let continuousNotRounded = FixedRoundedRect(rect, cornerRadius: 0, style: .continuous)
        #expect(continuousNotRounded.needsContinuousCorners == false)
    }

    @Test
    func clampedCornerSize() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        // Corner size fits within rect
        let normal = FixedRoundedRect(rect, cornerSize: CGSize(width: 10, height: 10), style: .circular)
        #expect(normal.clampedCornerSize == CGSize(width: 10, height: 10))

        // Corner size exceeds half of smaller dimension (height=50, so max=25)
        let oversized = FixedRoundedRect(rect, cornerSize: CGSize(width: 30, height: 30), style: .circular)
        #expect(oversized.clampedCornerSize == CGSize(width: 25, height: 25))

        // Non-uniform corner size
        let nonUniform = FixedRoundedRect(rect, cornerSize: CGSize(width: 40, height: 10), style: .circular)
        #expect(nonUniform.clampedCornerSize == CGSize(width: 25, height: 10))
    }

    @Test
    func clampedCornerRadius() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let normal = FixedRoundedRect(rect, cornerRadius: 10, style: .circular)
        #expect(normal.clampedCornerRadius == 10)

        let oversized = FixedRoundedRect(rect, cornerRadius: 30, style: .circular)
        #expect(oversized.clampedCornerRadius == 25)
    }

    // MARK: - Equality

    @Test
    func equality() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let a = FixedRoundedRect(rect, cornerRadius: 10, style: .circular)
        let b = FixedRoundedRect(rect, cornerRadius: 10, style: .circular)
        let c = FixedRoundedRect(rect, cornerRadius: 10, style: .continuous)
        let d = FixedRoundedRect(rect, cornerRadius: 15, style: .circular)
        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }

    // MARK: - Transformations

    @Test
    func insetBy() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let roundedRect = FixedRoundedRect(rect, cornerRadius: 10, style: .circular)

        let inset = roundedRect.insetBy(dx: 5, dy: 5)
        #expect(inset != nil)
        #expect(inset?.rect == CGRect(x: 5, y: 5, width: 90, height: 40))
        #expect(inset?.cornerSize == CGSize(width: 5, height: 5))

        // Zero inset returns self
        let noInset = roundedRect.insetBy(dx: 0, dy: 0)
        #expect(noInset == roundedRect)

        // Inset that makes rect empty returns nil
        let tooMuchInset = roundedRect.insetBy(dx: 60, dy: 30)
        #expect(tooMuchInset == nil)
    }

    @Test
    func hasIntersection() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let roundedRect = FixedRoundedRect(rect, cornerRadius: 10, style: .circular)

        #expect(roundedRect.hasIntersection(CGRect(x: 50, y: 25, width: 20, height: 10)) == true)
        #expect(roundedRect.hasIntersection(CGRect(x: 200, y: 200, width: 20, height: 10)) == false)
        #expect(roundedRect.hasIntersection(CGRect(x: 90, y: 40, width: 20, height: 20)) == true)
    }

    // MARK: - Contains

    @Test
    func containsFixedRoundedRect() {
        let outer = FixedRoundedRect(
            CGRect(x: 0, y: 0, width: 100, height: 100),
            cornerRadius: 10,
            style: .circular
        )
        let inner = FixedRoundedRect(
            CGRect(x: 10, y: 10, width: 80, height: 80),
            cornerRadius: 5,
            style: .circular
        )
        let outside = FixedRoundedRect(
            CGRect(x: 200, y: 200, width: 50, height: 50),
            cornerRadius: 5,
            style: .circular
        )

        #expect(outer.contains(inner) == true)
        #expect(outer.contains(outside) == false)
        #expect(inner.contains(outer) == false)
    }

    @Test
    func containsRect() {
        let roundedRect = FixedRoundedRect(
            CGRect(x: 0, y: 0, width: 100, height: 100),
            cornerRadius: 10,
            style: .circular
        )

        #expect(roundedRect.contains(rect: CGRect(x: 20, y: 20, width: 60, height: 60)) == true)
        #expect(roundedRect.contains(rect: CGRect(x: 200, y: 200, width: 10, height: 10)) == false)
    }

    #if canImport(Darwin)
    @Test(arguments: [
        (CGPoint(x: 50, y: 50), true),   // Center point - inside
        (CGPoint(x: 200, y: 200), false), // Point clearly outside
        (CGPoint(x: 50, y: 1), true),    // Near top edge - inside
        (CGPoint(x: 1, y: 50), true),    // Near left edge - inside
        (CGPoint(x: 5, y: 5), true),     // Corner region - inside rounded corner
        (CGPoint(x: 1, y: 1), false),    // Corner - outside due to rounding
        (CGPoint(x: 99, y: 99), false),  // Bottom-right corner - outside due to rounding
        (CGPoint(x: 95, y: 95), true),   // Bottom-right corner region - inside
    ] as [(CGPoint, Bool)])
    func containsPoint(point: CGPoint, expected: Bool) {
        let roundedRect = FixedRoundedRect(
            CGRect(x: 0, y: 0, width: 100, height: 100),
            cornerRadius: 10,
            style: .circular
        )
        #expect(roundedRect.contains(point) == expected)
    }

    @Test(arguments: [
        (CGRect(x: 0, y: 0, width: 100, height: 100), 10.0, RoundedCornerStyle.circular),
        (CGRect(x: 10, y: 20, width: 80, height: 60), 15.0, RoundedCornerStyle.continuous),
        (CGRect(x: 0, y: 0, width: 50, height: 50), 5.0, RoundedCornerStyle.circular),
    ] as [(CGRect, CGFloat, RoundedCornerStyle)])
    func withTemporaryPath(rect: CGRect, cornerRadius: CGFloat, style: RoundedCornerStyle) {
        let roundedRect = FixedRoundedRect(rect, cornerRadius: cornerRadius, style: style)
        let boundingRect = roundedRect.withTemporaryPath { path in
            path.storage.boundingRect
        }
        #expect(boundingRect.origin.x == rect.origin.x)
        #expect(boundingRect.origin.y == rect.origin.y)
        #expect(boundingRect.size.width == rect.size.width)
        #expect(boundingRect.size.height == rect.size.height)
    }
    #endif
}
