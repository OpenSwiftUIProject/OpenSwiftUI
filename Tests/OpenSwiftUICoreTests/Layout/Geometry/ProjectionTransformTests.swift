//
//  ProjectionTransformTests.swift
//  OpenSwiftUICoreTests

import Testing
import OpenSwiftUICore
import Numerics
import Foundation
#if canImport(QuartzCore)
import QuartzCore
#endif

struct ProjectionTransformTests {
    // MARK: - Initialization Tests
    
    @Test
    func defaultInit() {
        let transform = ProjectionTransform()
        #expect(transform.m11 == 1.0)
        #expect(transform.m12 == 0.0)
        #expect(transform.m13 == 0.0)
        #expect(transform.m21 == 0.0)
        #expect(transform.m22 == 1.0)
        #expect(transform.m23 == 0.0)
        #expect(transform.m31 == 0.0)
        #expect(transform.m32 == 0.0)
        #expect(transform.m33 == 1.0)
    }
    
    #if canImport(QuartzCore)
    @Test
    func cgAffineTransformInit() {
        let affine = CGAffineTransform(a: 2, b: 3, c: 4, d: 5, tx: 6, ty: 7)
        let transform = ProjectionTransform(affine)
        #expect(transform.m11 == 2)
        #expect(transform.m12 == 3)
        #expect(transform.m21 == 4)
        #expect(transform.m22 == 5)
        #expect(transform.m31 == 6)
        #expect(transform.m32 == 7)
        #expect(transform.m13 == 0)
        #expect(transform.m23 == 0)
        #expect(transform.m33 == 1)
    }
    
    @Test
    func caTransform3DInit() {
        let t3d = CATransform3DMakeTranslation(1, 2, 3)
        let transform = ProjectionTransform(t3d)
        #expect(transform.m11 == 1)
        #expect(transform.m12 == 0)
        #expect(transform.m13 == t3d.m14)
        #expect(transform.m21 == 0)
        #expect(transform.m22 == 1)
        #expect(transform.m23 == t3d.m24)
        #expect(transform.m31 == 1)
        #expect(transform.m32 == 2)
        #expect(transform.m33 == t3d.m44)
    }
    #endif
    
    // MARK: - Property Tests
    
    @Test
    func isIdentity() {
        let identity = ProjectionTransform()
        #expect(identity.isIdentity)
        
        #if canImport(QuartzCore)
        let nonIdentity = ProjectionTransform(CGAffineTransform(translationX: 1, y: 1))
        #expect(!nonIdentity.isIdentity)
        #endif
    }
    
    @Test
    func isAffine() {
        #if canImport(QuartzCore)
        let affine = ProjectionTransform(CGAffineTransform.identity)
        #expect(affine.isAffine)
        #endif
        
        var nonAffine = ProjectionTransform()
        nonAffine.m13 = 0.5
        #expect(!nonAffine.isAffine)
    }
    
    #if canImport(QuartzCore)
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
    #else
    @Test(
        arguments: [
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
    #endif

    
    // MARK: - Matrix Operation Tests
    
    @Test
    func invert() {
        #if canImport(QuartzCore)
        var transform = ProjectionTransform(CGAffineTransform(scaleX: 2, y: 2))
        let transformInvertResult = transform.invert()
        #expect(transformInvertResult == true)
        #expect(transform.m11 == 0.5)
        #expect(transform.m22 == 0.5)
        #endif
        
        var singular = ProjectionTransform()
        singular.m11 = 0
        singular.m22 = 0
        let singularInvertResult = singular.invert()
        #expect(singularInvertResult == false)
    }
    
    @Test
    func inverted() {
        #if canImport(QuartzCore)
        let transform = ProjectionTransform(CGAffineTransform(scaleX: 2, y: 2))
        let inverted = transform.inverted()
        #expect(inverted.m11 == 0.5)
        #expect(inverted.m22 == 0.5)
        #endif
    }
    
    @Test
    func concatenating() {
        #if canImport(QuartzCore)
        let t1 = ProjectionTransform(CGAffineTransform(translationX: 1, y: 0))
        let t2 = ProjectionTransform(CGAffineTransform(translationX: 0, y: 2))
        let result = t1.concatenating(t2)
        #expect(result.m31 == 1)
        #expect(result.m32 == 2)
        #endif
    }
    
    // MARK: - Point Transform Tests
    
    @Test
    func applyingToPoint() {
        #if canImport(QuartzCore)
        // Test affine transform
        let transform = ProjectionTransform(CGAffineTransform(translationX: 1, y: 2))
        let point = CGPoint(x: 1, y: 1)
        let transformed = point.applying(transform)
        #expect(transformed.x == 2)
        #expect(transformed.y == 3)
        #endif
        
        // Test perspective transform
        var perspective = ProjectionTransform()
        perspective.m13 = 0.5
        let perspectivePoint = CGPoint(x: 2, y: 0).applying(perspective)
        #expect(perspectivePoint.x != 2)  // Point should be transformed by perspective
    }
    
    @Test
    func unapplyingToPoint() {
        #if canImport(QuartzCore)
        // Test with invertible transform
        let transform = ProjectionTransform(CGAffineTransform(translationX: 1, y: 2))
        let point = CGPoint(x: 2, y: 3)
        let untransformed = point.unapplying(transform)
        #expect(untransformed.x == 1)
        #expect(untransformed.y == 1)
        #endif
        
        // Test with non-invertible transform
        var singular = ProjectionTransform()
        singular.m11 = 0
        singular.m22 = 0
        let originalPoint = CGPoint(x: 1, y: 1)
        let result = originalPoint.unapplying(singular)
        #expect(result == originalPoint)  // Should return original point for non-invertible transform
    }
    
    #if canImport(QuartzCore)
    // MARK: - Conversion Tests
    
    @Test
    func toCATransform3D() {
        let projection = ProjectionTransform()
        let transform3D = CATransform3D(projection)
        #expect(transform3D.m11 == projection.m11)
        #expect(transform3D.m12 == projection.m12)
        #expect(transform3D.m14 == projection.m13)
        #expect(transform3D.m21 == projection.m21)
        #expect(transform3D.m22 == projection.m22)
        #expect(transform3D.m24 == projection.m23)
        #expect(transform3D.m41 == projection.m31)
        #expect(transform3D.m42 == projection.m32)
        #expect(transform3D.m44 == projection.m33)
    }
    
    @Test
    func toCGAffineTransform() {
        let projection = ProjectionTransform()
        let affine = CGAffineTransform(projection)
        #expect(affine.a == projection.m11)
        #expect(affine.b == projection.m12)
        #expect(affine.c == projection.m21)
        #expect(affine.d == projection.m22)
        #expect(affine.tx == projection.m31)
        #expect(affine.ty == projection.m32)
    }
    #endif
    
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
