//
//  ScrollGeometryTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenSwiftUICore
import Testing

struct ScrollGeometryTests {
    // MARK: - Initialization Tests
    
    @Test
    func initialization() {
        let geometry = ScrollGeometry(
            contentOffset: .init(x: 10, y: 20),
            contentSize: .init(width: 100, height: 200),
            contentInsets: .init(top: 5, leading: 5, bottom: 5, trailing: 5),
            containerSize: .init(width: 50, height: 100),
            visibleRect: .init(x: 10, y: 20, width: 50, height: 100)
        )
        
        #expect(geometry.contentOffset == CGPoint(x: 10, y: 20))
        #expect(geometry.contentSize == CGSize(width: 100, height: 200))
        #expect(geometry.contentInsets == EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        #expect(geometry.containerSize == CGSize(width: 50, height: 100))
        #expect(geometry.visibleRect == CGRect(x: 10, y: 20, width: 50, height: 100))
    }
    
    // MARK: - Content Offset Tests
    
    @Test
    func contentOffsetUpdate() {
        var geometry = ScrollGeometry(
            contentOffset: .zero,
            contentSize: .init(width: 100, height: 200),
            contentInsets: .zero,
            containerSize: .init(width: 50, height: 100),
            visibleRect: .init(origin: .zero, size: .init(width: 50, height: 100))
        )
        
        geometry.contentOffset = CGPoint(x: 10, y: 20)
        #expect(geometry.visibleRect.origin == CGPoint(x: 10, y: 20))
    }
    
    // MARK: - Translation Tests
    
    @Test
    func translateWithinBounds() {
        var geometry = ScrollGeometry(
            contentOffset: .zero,
            contentSize: .init(width: 100, height: 200),
            contentInsets: .zero,
            containerSize: .init(width: 50, height: 100),
            visibleRect: .init(origin: .zero, size: .init(width: 50, height: 100))
        )
        
        geometry.translate(
            by: .init(width: 10, height: 20),
            limit: .init(width: 100, height: 200)
        )
        
        #expect(geometry.contentOffset == CGPoint(x: 10, y: 20))
    }
    
    @Test
    func translateBeyondBounds() {
        var geometry = ScrollGeometry(
            contentOffset: .zero,
            contentSize: .init(width: 100, height: 200),
            contentInsets: .zero,
            containerSize: .init(width: 50, height: 100),
            visibleRect: .init(origin: .zero, size: .init(width: 50, height: 100))
        )
        
        geometry.translate(
            by: .init(width: 200, height: 300),
            limit: .init(width: 100, height: 200)
        )
        
        #expect(geometry.contentOffset.x.isApproximatelyEqual(to: 50.0))
        #expect(geometry.contentOffset.y.isApproximatelyEqual(to: 100.0))
    }
    
    // MARK: - Accessibility Tests
    
    @Test
    func outsetForAXWithinLimit() {
        var geometry = ScrollGeometry(
            contentOffset: .init(x: 10, y: 20),
            contentSize: .init(width: 100, height: 200),
            contentInsets: .zero,
            containerSize: .init(width: 50, height: 100),
            visibleRect: .init(x: 10, y: 20, width: 50, height: 100)
        )
        
        let originalWidth = geometry.containerSize.width
        let originalHeight = geometry.containerSize.height
        
        geometry.outsetForAX(limit: .init(width: 40, height: 80))
        
        // Container size should not change as limit is smaller
        #expect(geometry.containerSize.width == originalWidth)
        #expect(geometry.containerSize.height == originalHeight)
    }
    
    @Test
    func outsetForAXBeyondLimit() {
        var geometry = ScrollGeometry(
            contentOffset: .init(x: 10, y: 20),
            contentSize: .init(width: 100, height: 200),
            contentInsets: .zero,
            containerSize: .init(width: 50, height: 100),
            visibleRect: .init(x: 10, y: 20, width: 50, height: 100)
        )
        
        geometry.outsetForAX(limit: .init(width: 200, height: 400))
        
        // Container size should adjust based on limit
        #expect(geometry.containerSize.width > 50)
        #expect(geometry.containerSize.height > 100)
        #expect(geometry.containerSize.width <= 200)
        #expect(geometry.containerSize.height <= 400)
    }
    
    // MARK: - Layout Direction Tests
    
    @Test
    func applyLayoutDirection() {
        var geometry = ScrollGeometry(
            contentOffset: .init(x: 10, y: 20),
            contentSize: .init(width: 100, height: 200),
            contentInsets: .zero,
            containerSize: .init(width: 50, height: 100),
            visibleRect: .init(x: 10, y: 20, width: 50, height: 100)
        )
        
        let originalOffset = geometry.contentOffset
        geometry.applyLayoutDirection(.rightToLeft, contentSize: nil)
        
        // Should adjust for RTL
        #expect(geometry.contentOffset != originalOffset)
    }
}
