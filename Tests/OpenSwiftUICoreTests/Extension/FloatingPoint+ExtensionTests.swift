//
//  FloatingPoint+ExtensionTests.swift
//  OpenSwiftUICoreTests

import Testing
import OpenSwiftUICore
import Numerics

struct FloatingPoint_ExtensionTests {
    
    // MARK: - isAlmostEqual(to:tolerance:) Tests
    
    @Test
    func isAlmostEqualWithTolerance() {
        // Test equal values
        #expect(1.0.isAlmostEqual(to: 1.0, tolerance: 0.001))

        // Test nearly equal values within tolerance
        #expect(1.0.isAlmostEqual(to: 1.0001, tolerance: 0.001))
        #expect(1000.0.isAlmostEqual(to: 1000.1, tolerance: 0.001))
        #expect((-1000.0).isAlmostEqual(to: -1000.1, tolerance: 0.001))

        // Test values outside tolerance
        #expect(!1.0.isAlmostEqual(to: 1.002, tolerance: 0.001))
        #expect(!1000.0.isAlmostEqual(to: 1002.0, tolerance: 0.001))

        // Test different scale values
        #expect(0.000001.isAlmostEqual(to: 0.0000010005, tolerance: 0.001))
        #expect(!0.000001.isAlmostEqual(to: 0.0000011, tolerance: 0.001))

        // Test with very small values (near zero)
        let tiny = Double.leastNonzeroMagnitude
        #expect(tiny.isAlmostEqual(to: tiny * 1.0005, tolerance: 0.001))
    }
    
    @Test
    func isAlmostEqualWithNonFiniteValues() {
        // Test infinity equality
        #expect(Double.infinity.isAlmostEqual(to: Double.infinity, tolerance: 0.001))
        #expect((-Double.infinity).isAlmostEqual(to: -Double.infinity, tolerance: 0.001))
        #expect(!Double.infinity.isAlmostEqual(to: -Double.infinity, tolerance: 0.001))

        // Test NaN values
        #expect(!Double.nan.isAlmostEqual(to: Double.nan, tolerance: 0.001))
        #expect(!Double.nan.isAlmostEqual(to: 0.0, tolerance: 0.001))
        #expect(!0.0.isAlmostEqual(to: Double.nan, tolerance: 0.001))

        // Test infinity with finite values
        #expect(Double.infinity.isAlmostEqual(to: Double.greatestFiniteMagnitude, tolerance: 0.001))
        #expect(Double.greatestFiniteMagnitude.isAlmostEqual(to: Double.infinity, tolerance: 0.001))
    }
    
    // MARK: - isAlmostEqual(to:) Tests
    
    @Test
    func isAlmostEqualWithDefaultTolerance() {
        #expect(1.0.isAlmostEqual(to: 1.0))
        #expect(1.0.isAlmostEqual(to: 1.0 + Double.ulpOfOne))
        #expect(!1.0.isAlmostEqual(to: 1.1))
    }
    
    // MARK: - isAlmostZero Tests
    
    @Test
    func isAlmostZeroWithTolerance() {
        // Test zero
        #expect(0.0.isAlmostZero(absoluteTolerance: 0.001))

        // Test small values within tolerance
        #expect(0.0005.isAlmostZero(absoluteTolerance: 0.001))
        #expect((-0.0005).isAlmostZero(absoluteTolerance: 0.001))

        // Test values outside tolerance
        #expect(!0.002.isAlmostZero(absoluteTolerance: 0.001))
        #expect(!(-0.002).isAlmostZero(absoluteTolerance: 0.001))
    }
    
    @Test
    func isAlmostZeroWithDefaultTolerance() {
        // Test zero
        #expect(0.0.isAlmostZero())

        // Test tiny value (should be considered zero)
        #expect((Double.ulpOfOne / 10).isAlmostZero())

        // Test non-zero value
        #expect(!1.0.isAlmostZero())
    }
    
    // MARK: - rescaledAlmostEqual Tests
    
    @Test
    func rescaledAlmostEqual() {
        // Test NaN handling
        #expect(!Double.nan.rescaledAlmostEqual(to: 0.0, tolerance: 0.001))
        #expect(!Double.nan.rescaledAlmostEqual(to: Double.nan, tolerance: 0.001))
        #expect(!0.0.rescaledAlmostEqual(to: Double.nan, tolerance: 0.001))

        // Test infinity equality
        #expect(Double.infinity.rescaledAlmostEqual(to: Double.infinity, tolerance: 0.001))
        #expect(!Double.infinity.rescaledAlmostEqual(to: -Double.infinity, tolerance: 0.001))

        // Test infinity with finite values
        #expect(Double.infinity.rescaledAlmostEqual(to: Double.greatestFiniteMagnitude, tolerance: 0.001))
        #expect(Double.greatestFiniteMagnitude.rescaledAlmostEqual(to: Double.infinity, tolerance: 0.001))

        #expect((-Double.infinity).rescaledAlmostEqual(to: -Double.greatestFiniteMagnitude, tolerance: 0.001))
        #expect((-Double.greatestFiniteMagnitude).rescaledAlmostEqual(to: -Double.infinity, tolerance: 0.001))

        #expect(!Double.infinity.rescaledAlmostEqual(to: Double.greatestFiniteMagnitude.squareRoot(), tolerance: 0.001))
        #expect(!Double.greatestFiniteMagnitude.squareRoot().rescaledAlmostEqual(to: Double.infinity, tolerance: 0.001))
    }
}
