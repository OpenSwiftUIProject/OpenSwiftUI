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
}
