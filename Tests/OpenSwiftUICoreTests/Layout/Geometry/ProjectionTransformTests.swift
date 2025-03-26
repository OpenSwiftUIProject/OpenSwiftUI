//
//  ProjectionTransformTests.swift
//  OpenSwiftUICoreTests

import CoreGraphicsShims
import Foundation
import Numerics
import OpenSwiftUICore
import Testing

struct ProjectionTransformTests {
    // MARK: - Initialization Tests
    
    @Test
    func defaultInit() {
        let transform = ProjectionTransform()
        #expect(transform.m11.isApproximatelyEqual(to: 1.0))
        #expect(transform.m12.isApproximatelyEqual(to: 0.0))
        #expect(transform.m13.isApproximatelyEqual(to: 0.0))
        #expect(transform.m21.isApproximatelyEqual(to: 0.0))
        #expect(transform.m22.isApproximatelyEqual(to: 1.0))
        #expect(transform.m23.isApproximatelyEqual(to: 0.0))
        #expect(transform.m31.isApproximatelyEqual(to: 0.0))
        #expect(transform.m32.isApproximatelyEqual(to: 0.0))
        #expect(transform.m33.isApproximatelyEqual(to: 1.0))
    }
    
    @Test
    func cgAffineTransformInit() {
        let affine = CGAffineTransform(a: 2, b: 3, c: 4, d: 5, tx: 6, ty: 7)
        let transform = ProjectionTransform(affine)
        #expect(transform.m11.isApproximatelyEqual(to: 2))
        #expect(transform.m12.isApproximatelyEqual(to: 3))
        #expect(transform.m21.isApproximatelyEqual(to: 4))
        #expect(transform.m22.isApproximatelyEqual(to: 5))
        #expect(transform.m31.isApproximatelyEqual(to: 6))
        #expect(transform.m32.isApproximatelyEqual(to: 7))
        #expect(transform.m13.isApproximatelyEqual(to: 0))
        #expect(transform.m23.isApproximatelyEqual(to: 0))
        #expect(transform.m33.isApproximatelyEqual(to: 1))
    }
    
    @Test
    func caTransform3DInit() {
        let t3d = CATransform3DMakeTranslation(1, 2, 3)
        let transform = ProjectionTransform(t3d)
        #expect(transform.m11.isApproximatelyEqual(to: 1))
        #expect(transform.m12.isApproximatelyEqual(to: 0))
        #expect(transform.m13.isApproximatelyEqual(to: t3d.m14))
        #expect(transform.m21.isApproximatelyEqual(to: 0))
        #expect(transform.m22.isApproximatelyEqual(to: 1))
        #expect(transform.m23.isApproximatelyEqual(to: t3d.m24))
        #expect(transform.m31.isApproximatelyEqual(to: 1))
        #expect(transform.m32.isApproximatelyEqual(to: 2))
        #expect(transform.m33.isApproximatelyEqual(to: t3d.m44))
    }

    // MARK: - Property Tests
    
    @Test
    func isIdentity() {
        let identity = ProjectionTransform()
        #expect(identity.isIdentity)
        let nonIdentity = ProjectionTransform(CGAffineTransform(translationX: 1, y: 1))
        #expect(!nonIdentity.isIdentity)
    }
    
    @Test
    func isAffine() {
        let affine = ProjectionTransform(CGAffineTransform.identity)
        #expect(affine.isAffine)

        var nonAffine = ProjectionTransform()
        nonAffine.m13 = 0.5
        #expect(!nonAffine.isAffine)
    }
    
    @Test(
        arguments: [
            // Affine transforms
            (ProjectionTransform(CGAffineTransform(scaleX: 2, y: 3)), 6.0),
            (ProjectionTransform(CGAffineTransform(rotationAngle: .pi/4)), 1.0),
            // Non-affine transforms with zero determinant
            (
                ProjectionTransform(
                    m11: 2, m12: 3, m13: 4,
                    m21: 4, m22: 6, m23: 8,
                    m31: 8, m32: 9, m33: 10
                ),
                0.0
            ),
            // Non-affine transforms with non-zero determinant
            (
                ProjectionTransform(
                    m11: 1, m12: 2, m13: 3,
                    m21: 0, m22: 1, m23: 4,
                    m31: 5, m32: 6, m33: 0
                ),
                1.0
            ),
        ]
    )
    func determinant(transform: ProjectionTransform, expectedDet: CGFloat) {
        #expect(transform.determinant.isApproximatelyEqual(to: expectedDet))
    }
    
    // MARK: - Matrix Operation Tests
    
    @Test
    func invert() {
        var transform = ProjectionTransform(CGAffineTransform(scaleX: 2, y: 2))
        let transformInvertResult = transform.invert()
        #expect(transformInvertResult == true)
        #expect(transform.m11.isApproximatelyEqual(to: 0.5))
        #expect(transform.m22.isApproximatelyEqual(to: 0.5))

        var singular = ProjectionTransform()
        singular.m11 = 0
        singular.m22 = 0
        let singularInvertResult = singular.invert()
        #expect(singularInvertResult == false)
    }
    
    @Test
    func inverted() {
        let transform = ProjectionTransform(CGAffineTransform(scaleX: 2, y: 2))
        let inverted = transform.inverted()
        #expect(inverted.m11.isApproximatelyEqual(to: 0.5))
        #expect(inverted.m22.isApproximatelyEqual(to: 0.5))
    }
    
    @Test
    func concatenating() {
        let t1 = ProjectionTransform(CGAffineTransform(translationX: 1, y: 0))
        let t2 = ProjectionTransform(CGAffineTransform(translationX: 0, y: 2))
        let result = t1.concatenating(t2)
        #expect(result.m31.isApproximatelyEqual(to: 1))
        #expect(result.m32.isApproximatelyEqual(to: 2))
    }
    
    // MARK: - Point Transform Tests
    
    @Test
    func applyingToPoint() {
        // Test affine transform
        let transform = ProjectionTransform(CGAffineTransform(translationX: 1, y: 2))
        let point = CGPoint(x: 1, y: 1)
        let transformed = point.applying(transform)
        #expect(transformed.x.isApproximatelyEqual(to: 2))
        #expect(transformed.y.isApproximatelyEqual(to: 3))

        // Test perspective transform
        var perspective = ProjectionTransform()
        perspective.m13 = 0.5
        let perspectivePoint = CGPoint(x: 2, y: 0).applying(perspective)
        // Point should be transformed by perspective
        #expect(!perspectivePoint.x.isApproximatelyEqual(to: 2))
    }
    
    @Test
    func unapplyingToPoint() {
        // Test with invertible transform
        let transform = ProjectionTransform(CGAffineTransform(translationX: 1, y: 2))
        let point = CGPoint(x: 2, y: 3)
        let untransformed = point.unapplying(transform)
        #expect(untransformed.x.isApproximatelyEqual(to: 1.0))
        #expect(untransformed.y.isApproximatelyEqual(to: 1.0))

        // Test with non-invertible transform
        var singular = ProjectionTransform()
        singular.m11 = 0
        singular.m22 = 0
        let originalPoint = CGPoint(x: 1, y: 1)
        let result = originalPoint.unapplying(singular)
        // Should return original point for non-invertible transform
        #expect(result.x.isApproximatelyEqual(to: originalPoint.x))
        #expect(result.y.isApproximatelyEqual(to: originalPoint.y))
    }
    
    // MARK: - Conversion Tests
    
    @Test
    func toCATransform3D() {
        let projection = ProjectionTransform()
        let transform3D = CATransform3D(projection)
        #expect(transform3D.m11.isApproximatelyEqual(to: projection.m11))
        #expect(transform3D.m12.isApproximatelyEqual(to: projection.m12))
        #expect(transform3D.m14.isApproximatelyEqual(to: projection.m13))
        #expect(transform3D.m21.isApproximatelyEqual(to: projection.m21))
        #expect(transform3D.m22.isApproximatelyEqual(to: projection.m22))
        #expect(transform3D.m24.isApproximatelyEqual(to: projection.m23))
        #expect(transform3D.m41.isApproximatelyEqual(to: projection.m31))
        #expect(transform3D.m42.isApproximatelyEqual(to: projection.m32))
        #expect(transform3D.m44.isApproximatelyEqual(to: projection.m33))
    }
    
    @Test
    func toCGAffineTransform() {
        let projection = ProjectionTransform()
        let affine = CGAffineTransform(projection)
        #expect(affine.a.isApproximatelyEqual(to: projection.m11))
        #expect(affine.b.isApproximatelyEqual(to: projection.m12))
        #expect(affine.c.isApproximatelyEqual(to: projection.m21))
        #expect(affine.d.isApproximatelyEqual(to: projection.m22))
        #expect(affine.tx.isApproximatelyEqual(to: projection.m31))
        #expect(affine.ty.isApproximatelyEqual(to: projection.m32))
    }

    // MARK: - ProtobufMessage Tests
    
    @Test(
        arguments: [
            (ProjectionTransform(), ""), // Identity transform
            // Scale transform
            (
                ProjectionTransform(
                    m11: 2, m12: 0, m13: 0,
                    m21: 0, m22: 4, m23: 0,
                    m31: 0, m32: 0, m33: 1
                ),
                "0d000000402d00008040"
            ),
            // Translation transform
            (
                ProjectionTransform(
                    m11: 1, m12: 0, m13: 0,
                    m21: 0, m22: 1, m23: 0,
                    m31: 2, m32: 4, m33: 1
                ),
                "3d000000404500008040"
            ),
            // Perspective transform
            (
                ProjectionTransform(
                    m11: 1, m12: 0, m13: 0.5,
                    m21: 0, m22: 1, m23: 0.5,
                    m31: 0, m32: 0, m33: 1
                ),
                "1d0000003f350000003f"
            )
        ]
    )
    func pbMessage(transform: ProjectionTransform, hexString: String) throws {
        try transform.testPBEncoding(hexString: hexString)
        try transform.testPBDecoding(hexString: hexString)
    }
}
