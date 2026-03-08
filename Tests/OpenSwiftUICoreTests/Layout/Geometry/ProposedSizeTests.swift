//
//  ProposedSizeTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenSwiftUICore
import Testing

struct ProposedSizeTests {
    // MARK: - Static Properties Tests
    
    @Test
    func staticProperties() {
        let zero = _ProposedSize.zero
        #expect(zero.width == 0)
        #expect(zero.height == 0)
        
        let infinity = _ProposedSize.infinity
        #expect(infinity.width == .infinity)
        #expect(infinity.height == .infinity)
        
        let unspecified = _ProposedSize.unspecified
        #expect(unspecified.width == nil)
        #expect(unspecified.height == nil)
    }
    
    // MARK: - Initialization Tests
    
    @Test
    func defaultInit() {
        let size = _ProposedSize()
        #expect(size.width == nil)
        #expect(size.height == nil)
    }
    
    @Test
    func initWithOptionals() {
        let size1 = _ProposedSize(width: 100, height: 200)
        #expect(size1.width == 100)
        #expect(size1.height == 200)
        
        let size2 = _ProposedSize(width: nil, height: 200)
        #expect(size2.width == nil)
        #expect(size2.height == 200)
        
        let size3 = _ProposedSize(width: 100, height: nil)
        #expect(size3.width == 100)
        #expect(size3.height == nil)
    }
    
    @Test
    func initWithCGSize() {
        let cgSize = CGSize(width: 100, height: 200)
        let size = _ProposedSize(cgSize)
        #expect(size.width == 100)
        #expect(size.height == 200)
    }
    
    @Test
    func initWithAxisAndValues() {
        let horizontal = _ProposedSize(100, in: .horizontal, by: 200)
        #expect(horizontal.width == 100)
        #expect(horizontal.height == 200)
        
        let vertical = _ProposedSize(100, in: .vertical, by: 200)
        #expect(vertical.width == 200)
        #expect(vertical.height == 100)
    }
    
    // MARK: - Dimension Fixing Tests
    
    @Test
    func fixingUnspecifiedDimensions() {
        let size = _ProposedSize(width: nil, height: 200)
        let defaults = CGSize(width: 50, height: 100)
        
        let fixed = size.fixingUnspecifiedDimensions(at: defaults)
        #expect(fixed.width == 50)
        #expect(fixed.height == 200)
        
        let defaultFixed = size.fixingUnspecifiedDimensions()
        #expect(defaultFixed.width == 10.0)
        #expect(defaultFixed.height == 200)
    }
    
    // MARK: - Scaling Tests
    
    @Test
    func scaling() {
        let size = _ProposedSize(width: 100, height: 200)
        let scaled = size.scaled(by: 2)
        #expect(scaled.width == 200)
        #expect(scaled.height == 400)
        
        let partialSize = _ProposedSize(width: nil, height: 200)
        let partialScaled = partialSize.scaled(by: 2)
        #expect(partialScaled.width == nil)
        #expect(partialScaled.height == 400)
    }
    
    // MARK: - Inset Tests
    
    @Test
    func insetByEdgeInsets() {
        let size = _ProposedSize(width: 100, height: 200)
        let insets = EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
        let inset = size.inset(by: insets)
        #expect(inset.width == 60) // 100 - (20 + 20)
        #expect(inset.height == 180) // 200 - (10 + 10)
        
        // Test with nil dimensions
        let partialSize = _ProposedSize(width: nil, height: 200)
        let partialInset = partialSize.inset(by: insets)
        #expect(partialInset.width == nil)
        #expect(partialInset.height == 180)
        
        // Test with nan dimensions
        let nanSize = _ProposedSize(width: .nan, height: 200)
        let nanInset = nanSize.inset(by: insets)
        #expect(nanInset.width == 0)
        #expect(nanInset.height == 180)
    }
    
    // MARK: - Axis Access Tests
    
    @Test
    func axisSubscript() {
        var size = _ProposedSize(width: 100, height: 200)
        
        // Get
        #expect(size[.horizontal] == 100)
        #expect(size[.vertical] == 200)
        
        // Set
        size[.horizontal] = 300
        size[.vertical] = 400
        #expect(size.width == 300)
        #expect(size.height == 400)
    }
    
    // MARK: - CGSize Conversion Tests
    
    @Test
    func cgSizeConversion() {
        let size = _ProposedSize(width: 100, height: 200)
        let cgSize = CGSize(size)
        #expect(cgSize?.width == 100)
        #expect(cgSize?.height == 200)
        
        let partialSize = _ProposedSize(width: nil, height: 200)
        #expect(CGSize(partialSize) == nil)
    }
    
    // MARK: - Hashable Tests
    
    @Test
    func hashableConformance() {
        let size1 = _ProposedSize(width: 100, height: 200)
        let size2 = _ProposedSize(width: 100, height: 200)
        let size3 = _ProposedSize(width: 200, height: 100)
        
        #expect(size1 == size2)
        #expect(size1 != size3)
        #expect(size1.hashValue != size3.hashValue)
        
        var hasher = Hasher()
        size1.hash(into: &hasher)
        let hash1 = hasher.finalize()
        
        hasher = Hasher()
        size2.hash(into: &hasher)
        let hash2 = hasher.finalize()
        
        #expect(hash1 == hash2)
    }
}