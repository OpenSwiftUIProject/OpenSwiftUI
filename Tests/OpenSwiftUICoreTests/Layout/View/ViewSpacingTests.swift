//
//  ViewSpacingTests.swift
//  OpenSwiftUICoreTests

import Numerics
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

struct ViewSpacingTests {
    // MARK: - Initialization Tests
    
    @Test
    func packageInitialization() {
        // Test package initializer with Spacing
        let spacing = Spacing.all(10)
        let viewSpacing = ViewSpacing(spacing)
        
        #expect(viewSpacing.description == #"""
        Spacing [
          (default, top) : 10.0
          (default, left) : 10.0
          (default, bottom) : 10.0
          (default, right) : 10.0
        ]
        """#)

        // Test package initializer with Spacing and layout direction
        let rtlViewSpacing = ViewSpacing(spacing, layoutDirection: .rightToLeft)
        let ltrViewSpacing = ViewSpacing(spacing, layoutDirection: .leftToRight)
        
        // Different layout directions with symmetric spacing should behave the same
        let distance1 = rtlViewSpacing.distance(to: ViewSpacing.zero, along: .horizontal)
        let distance2 = ltrViewSpacing.distance(to: ViewSpacing.zero, along: .horizontal)
        #expect(distance1.isApproximatelyEqual(to: distance2))
    }
    
    // MARK: - Layout Direction Tests
    
    @Test
    func layoutDirection() {
        // Create asymmetric spacing
        let leftSpacing = Spacing(minima: [
            Spacing.Key(category: nil, edge: .left): .distance(2),
            Spacing.Key(category: nil, edge: .right): .distance(3),
        ])
        
        // Create view spacing with different layout directions
        let ltrViewSpacing = ViewSpacing(leftSpacing, layoutDirection: .leftToRight)
        let rtlViewSpacing = ViewSpacing(leftSpacing, layoutDirection: .rightToLeft)
        
        // Test that distance calculation respects layout direction
        let targetSpacing = ViewSpacing(.zero)
        let ltrDistance = ltrViewSpacing.distance(to: targetSpacing, along: .horizontal)
        let rtlDistance = rtlViewSpacing.distance(to: targetSpacing, along: .horizontal)
        
        // The distances should be different due to different layout directions
        #expect(ltrDistance.isApproximatelyEqual(to: 3))
        #expect(rtlDistance.isApproximatelyEqual(to: 2))
    }
    
    // MARK: - Spacing Value Tests
    
    @Test
    func spacingValues() {
        let spacing = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(10),
            Spacing.Key(category: nil, edge: .left): .distance(20),
            Spacing.Key(category: nil, edge: .bottom): .distance(30),
            Spacing.Key(category: nil, edge: .right): .distance(40),
        ])
        
        let viewSpacing = ViewSpacing(spacing)
        
        let horizontalViewSpacing = ViewSpacing(.zero)
        let verticalViewSpacing = ViewSpacing(.zero)
        
        let horizontalDistance = viewSpacing.distance(to: horizontalViewSpacing, along: .horizontal)
        let verticalDistance = viewSpacing.distance(to: verticalViewSpacing, along: .vertical)
        
        #expect(horizontalDistance.isApproximatelyEqual(to: 40))
        #expect(verticalDistance.isApproximatelyEqual(to: 30))
    }
    
    // MARK: - Default Spacing Value Tests
    
    @Test
    func defaultSpacing() {
        // Create custom spacing with no common edges
        let spacing1 = Spacing(minima: [
            Spacing.Key(category: .textToText, edge: .top): .distance(888),
        ])
        let spacing2 = Spacing(minima: [
            Spacing.Key(category: .textBaseline, edge: .bottom): .distance(999),
        ])
        
        let viewSpacing1 = ViewSpacing(spacing1)
        let viewSpacing2 = ViewSpacing(spacing2)
        
        // Since there are no common edges, the default spacing value should be used
        let horizontalDistance = viewSpacing1.distance(to: viewSpacing2, along: .horizontal)
        let verticalDistance = viewSpacing1.distance(to: viewSpacing2, along: .vertical)

        #expect(horizontalDistance.isApproximatelyEqual(to: defaultSpacingValue.width))
        #expect(verticalDistance.isApproximatelyEqual(to: defaultSpacingValue.height))
    }
    
    // MARK: - Description Tests
    
    @Test
    func description() {
        let zeroDescription = ViewSpacing.zero.description
        #expect(zeroDescription.description == #"""
        Spacing [
          (default, top) : 0.0
          (default, left) : 0.0
          (default, bottom) : 0.0
          (default, right) : 0.0
        ]
        """#)

        let customSpacing = Spacing(minima: [
            Spacing.Key(category: nil, edge: .left): .distance(42),
        ])
        #expect(ViewSpacing(customSpacing).description == #"""
        Spacing [
          (default, left) : 42.0
        ]
        """#)

        let emptySpacing = Spacing(minima: [:])
        #expect(emptySpacing.description == #"""
        Spacing (empty)
        """#)
    }
    
    // MARK: - Edge Incorporation Tests
    
    @Test
    func edgeIncorporation() {
        // Create spacing with values for specific edges
        let spacing1 = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(10),
            Spacing.Key(category: nil, edge: .left): .distance(20),
        ])
        
        let spacing2 = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(30),
            Spacing.Key(category: nil, edge: .right): .distance(40),
        ])
        
        var viewSpacing1 = ViewSpacing(spacing1)
        let viewSpacing2 = ViewSpacing(spacing2)
        
        // Incorporate only the top edge
        viewSpacing1.formUnion(viewSpacing2, edges: .top)
        
        // Top should be taken from spacing2 (larger), but left should remain from spacing1
        let result = viewSpacing1.spacing
        
        let topValue = result.minima[Spacing.Key(category: nil, edge: .top)]
        let leftValue = result.minima[Spacing.Key(category: nil, edge: .left)]
        let rightValue = result.minima[Spacing.Key(category: nil, edge: .right)]
        
        #expect(topValue?.value?.isApproximatelyEqual(to: 30.0) == true)
        #expect(leftValue?.value?.isApproximatelyEqual(to: 20.0) == true)
        #expect(rightValue == nil) // Right edge should not be incorporated
    }
}
