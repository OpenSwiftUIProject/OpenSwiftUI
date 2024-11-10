//
//  AbsoluteEdgeTests.swift
//  OpenSwiftUICoreTests

import Testing
import OpenSwiftUICore

struct AbsoluteEdgeTests {   
    @Test
    func absoluteEdgeValues() {
        #expect(AbsoluteEdge.top.rawValue == 0)
        #expect(AbsoluteEdge.left.rawValue == 1)
        #expect(AbsoluteEdge.bottom.rawValue == 2)
        #expect(AbsoluteEdge.right.rawValue == 3)
    }
    
    @Test
    func absoluteEdgeSetInitialization() {
        let topSet = AbsoluteEdge.Set(.top)
        let leftSet = AbsoluteEdge.Set(.left)
        let bottomSet = AbsoluteEdge.Set(.bottom)
        let rightSet = AbsoluteEdge.Set(.right)
        
        #expect(topSet.rawValue == 1 << 0)
        #expect(leftSet.rawValue == 1 << 1)
        #expect(bottomSet.rawValue == 1 << 2)
        #expect(rightSet.rawValue == 1 << 3)
    }
    
    @Test
    func absoluteEdgeSetContains() {
        let horizontalSet = AbsoluteEdge.Set.horizontal
        #expect(horizontalSet.contains(.left))
        #expect(horizontalSet.contains(.right))
        #expect(!horizontalSet.contains(.top))
        #expect(!horizontalSet.contains(.bottom))
    }
    
    @Test
    func absoluteEdgeSetFromEdgeSet() {
        // Test LTR layout direction
        let ltrSet = AbsoluteEdge.Set(.leading, layoutDirection: .leftToRight)
        #expect(ltrSet.contains(.left))
        #expect(!ltrSet.contains(.right))
        #expect(!ltrSet.contains(.top))
        #expect(!ltrSet.contains(.bottom))
        
        // Test RTL layout direction
        let rtlSet = AbsoluteEdge.Set(.leading, layoutDirection: .rightToLeft)
        #expect(rtlSet.contains(.right))
        #expect(!rtlSet.contains(.left))
        #expect(!rtlSet.contains(.top))
        #expect(!rtlSet.contains(.bottom))
    }
}
