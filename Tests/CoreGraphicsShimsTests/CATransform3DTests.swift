//
//  CATransform3DTests.swift
//  CoreGraphicsShimsTests

import Testing
import CoreGraphicsShims
import Numerics

@Suite
struct CATransform3DTests {
    
    @Test
    func identityInvert() {
        let identity = CATransform3DIdentity
        let inverted = CATransform3DInvert(identity)
        
        #expect(CATransform3DEqualToTransform(inverted, identity))
    }
    
    @Test
    func translationInvert() {
        let translation = CATransform3DMakeTranslation(10, 20, 30)
        let inverted = CATransform3DInvert(translation)
        let expected = CATransform3DMakeTranslation(-10, -20, -30)
        
        #expect(CATransform3DEqualToTransform(inverted, expected))
    }
    
    @Test
    func scaleInvert() {
        let scale = CATransform3DMakeScale(2, 3, 4)
        let inverted = CATransform3DInvert(scale)
        let expected = CATransform3DMakeScale(1/2, 1/3, 1/4)
        
        // Use approximation for floating-point comparison
        #expect(inverted.m11.isApproximatelyEqual(to: expected.m11))
        #expect(inverted.m22.isApproximatelyEqual(to: expected.m22))
        #expect(inverted.m33.isApproximatelyEqual(to: expected.m33))
    }
    
    @Test
    func invertMultiplicationProperty() {
        // Create a complex transform
        let translation = CATransform3DMakeTranslation(10, 20, 30)
        let scale = CATransform3DMakeScale(2, 3, 4)
        let transform = CATransform3DConcat(translation, scale)
        
        // Test that T * T^-1 = Identity
        let inverted = CATransform3DInvert(transform)
        let result = CATransform3DConcat(transform, inverted)
        
        // Check key elements of result against identity matrix
        #expect(result.m11.isApproximatelyEqual(to: 1.0))
        #expect(result.m22.isApproximatelyEqual(to: 1.0))
        #expect(result.m33.isApproximatelyEqual(to: 1.0))
        #expect(result.m44.isApproximatelyEqual(to: 1.0))
        
        // Check that off-diagonal elements are approximately zero
        #expect(result.m12.isApproximatelyEqual(to: 0.0))
        #expect(result.m13.isApproximatelyEqual(to: 0.0))
        #expect(result.m14.isApproximatelyEqual(to: 0.0))
        #expect(result.m21.isApproximatelyEqual(to: 0.0))
        #expect(result.m23.isApproximatelyEqual(to: 0.0))
        #expect(result.m24.isApproximatelyEqual(to: 0.0))
        #expect(result.m31.isApproximatelyEqual(to: 0.0))
        #expect(result.m32.isApproximatelyEqual(to: 0.0))
        #expect(result.m34.isApproximatelyEqual(to: 0.0))
        #expect(result.m41.isApproximatelyEqual(to: 0.0))
        #expect(result.m42.isApproximatelyEqual(to: 0.0))
        #expect(result.m43.isApproximatelyEqual(to: 0.0))
    }
    
    @Test
    func nonInvertibleMatrix() {
        // Create a singular matrix (not invertible)
        var singular = CATransform3DIdentity
        singular.m11 = 0
        singular.m22 = 0
        
        let result = CATransform3DInvert(singular)
        
        // Should return the same matrix for non-invertible input
        #expect(CATransform3DEqualToTransform(result, singular))
    }

    @Test
    func rotationZ90_affineMapsPoint() {
        let rot = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        let cg = CATransform3DGetAffineTransform(rot)
        let p = CGPoint(x: 1, y: 0)
        let res = p.applying(cg)
        #expect(res.x.isApproximatelyEqual(to: 0.0, absoluteTolerance: 0.001))
        #expect(res.y.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
    }

    @Test
    func rotationAxisZeroIsIdentity() {
        let rot = CATransform3DMakeRotation(1.0, 0, 0, 0)
        #expect(CATransform3DEqualToTransform(rot, CATransform3DIdentity))
    }

    @Test
    func translateOnIdentityEqualsMakeTranslation() {
        let res = CATransform3DTranslate(CATransform3DIdentity, 5, 6, 7)
        let expected = CATransform3DMakeTranslation(5, 6, 7)
        #expect(CATransform3DEqualToTransform(res, expected))
    }

    @Test
    func rotateConcatProperty() {
        let angle = CGFloat.pi / 3
        let ax: CGFloat = 1.0
        let ay: CGFloat = 0.5
        let az: CGFloat = -0.25
        let t = CATransform3DMakeTranslation(10, 20, 30)
        let result = CATransform3DRotate(t, angle, ax, ay, az)
        let expected = CATransform3DConcat(CATransform3DMakeRotation(angle, ax, ay, az), t)
        #expect(result.m11.isApproximatelyEqual(to: expected.m11))
        #expect(result.m12.isApproximatelyEqual(to: expected.m12))
        #expect(result.m21.isApproximatelyEqual(to: expected.m21))
        #expect(result.m22.isApproximatelyEqual(to: expected.m22))
        #expect(result.m41.isApproximatelyEqual(to: expected.m41))
        #expect(result.m42.isApproximatelyEqual(to: expected.m42))
    }
}
