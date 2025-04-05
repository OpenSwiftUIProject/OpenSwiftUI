//
//  EdgeTests.swift
//  OpenSwiftUICoreTests
//
//  Audited for iOS 18.0
//  Status: Complete

import Testing
import OpenSwiftUICore

struct EdgeTests {
    // MARK: - Basic Edge Tests
    
    @Test
    func edgeRawValues() {
        #expect(Edge.top.rawValue == 0)
        #expect(Edge.leading.rawValue == 1)
        #expect(Edge.bottom.rawValue == 2)
        #expect(Edge.trailing.rawValue == 3)
    }
    
    @Test
    func edgeCaseIterable() {
        let allCases = Edge.allCases
        #expect(allCases.count == 4)
        #expect(allCases.contains(.top))
        #expect(allCases.contains(.leading))
        #expect(allCases.contains(.bottom))
        #expect(allCases.contains(.trailing))
    }
    
    @Test
    func edgeOpposite() {
        #expect(Edge.top.opposite == .bottom)
        #expect(Edge.leading.opposite == .trailing)
        #expect(Edge.bottom.opposite == .top)
        #expect(Edge.trailing.opposite == .leading)
    }
    
    // MARK: - Edge.Set Tests
    
    @Test
    func edgeSetInitialization() {
        let topSet = Edge.Set(.top)
        let leadingSet = Edge.Set(.leading)
        let bottomSet = Edge.Set(.bottom)
        let trailingSet = Edge.Set(.trailing)
        
        #expect(topSet.rawValue == 1 << 0)
        #expect(leadingSet.rawValue == 1 << 1)
        #expect(bottomSet.rawValue == 1 << 2)
        #expect(trailingSet.rawValue == 1 << 3)
    }
    
    @Test
    func edgeSetStaticProperties() {
        #expect(Edge.Set.top.rawValue == 1 << 0)
        #expect(Edge.Set.leading.rawValue == 1 << 1)
        #expect(Edge.Set.bottom.rawValue == 1 << 2)
        #expect(Edge.Set.trailing.rawValue == 1 << 3)
        
        #expect(Edge.Set.all == [.top, .leading, .bottom, .trailing])
        #expect(Edge.Set.horizontal == [.leading, .trailing])
        #expect(Edge.Set.vertical == [.top, .bottom])
    }
    
    @Test
    func edgeSetContains() {
        let allSet = Edge.Set.all
        #expect(allSet.contains(.top))
        #expect(allSet.contains(.leading))
        #expect(allSet.contains(.bottom))
        #expect(allSet.contains(.trailing))
        
        let horizontalSet = Edge.Set.horizontal
        #expect(!horizontalSet.contains(.top))
        #expect(horizontalSet.contains(.leading))
        #expect(!horizontalSet.contains(.bottom))
        #expect(horizontalSet.contains(.trailing))
        
        let verticalSet = Edge.Set.vertical
        #expect(verticalSet.contains(.top))
        #expect(!verticalSet.contains(.leading))
        #expect(verticalSet.contains(.bottom))
        #expect(!verticalSet.contains(.trailing))
    }
    
    @Test
    func edgeSetFromAxes() {
        let horizontalSet = Edge.Set(Axis.Set.horizontal)
        #expect(horizontalSet == .horizontal)
        
        let verticalSet = Edge.Set(Axis.Set.vertical)
        #expect(verticalSet == .vertical)
        
        let allSet = Edge.Set(Axis.Set.both)
        #expect(allSet == [.horizontal, .vertical])
        #expect(allSet == .all)
    }
    
    @Test
    func edgeSetViewDebugValue() throws {
        let allSet = Edge.Set.all
        let debugValue = try #require(allSet.viewDebugValue as? [Edge])
        #expect(debugValue.count == 4)
        #expect(debugValue.contains(.top) == true)
        #expect(debugValue.contains(.leading) == true)
        #expect(debugValue.contains(.bottom) == true)
        #expect(debugValue.contains(.trailing) == true)
        
        let horizontalSet = Edge.Set.horizontal
        let horizontalDebugValue = try #require(horizontalSet.viewDebugValue as? [Edge])
        #expect(horizontalDebugValue.count == 2)
        #expect(horizontalDebugValue.contains(.leading) == true)
        #expect(horizontalDebugValue.contains(.trailing) == true)
        #expect(horizontalDebugValue.contains(.top) == false)
        #expect(horizontalDebugValue.contains(.bottom) == false)
    }
    
    // MARK: - Edge Initialization Tests
    
    @Test
    func initFromVerticalEdge() {
        let topEdge = Edge(_vertical: .top)
        #expect(topEdge == .top)
        
        let bottomEdge = Edge(_vertical: .bottom)
        #expect(bottomEdge == .bottom)
        
        // Test internal initializer
        let internalTopEdge = Edge(_vertical: .top)
        #expect(internalTopEdge == .top)
    }
    
    @Test
    func initFromHorizontalEdge() {
        let leadingEdge = Edge(_horizontal: .leading)
        #expect(leadingEdge == .leading)
        
        let trailingEdge = Edge(_horizontal: .trailing)
        #expect(trailingEdge == .trailing)
        
        // Test internal initializer
        let internalLeadingEdge = Edge(_horizontal: .leading)
        #expect(internalLeadingEdge == .leading)
    }
    
    // MARK: - HorizontalEdge Tests
    
    @Test
    func horizontalEdgeRawValues() {
        #expect(HorizontalEdge.leading.rawValue == 0)
        #expect(HorizontalEdge.trailing.rawValue == 1)
    }
    
    @Test
    func horizontalEdgeCaseIterable() {
        let allCases = HorizontalEdge.allCases
        #expect(allCases.count == 2)
        #expect(allCases.contains(.leading))
        #expect(allCases.contains(.trailing))
    }
    
    @Test
    func horizontalEdgeSetInitialization() {
        let leadingSet = HorizontalEdge.Set(.leading)
        let trailingSet = HorizontalEdge.Set(.trailing)
        
        #expect(leadingSet.rawValue == 1 << 0)
        #expect(trailingSet.rawValue == 1 << 1)
    }
    
    @Test
    func horizontalEdgeSetStaticProperties() {
        #expect(HorizontalEdge.Set.leading.rawValue == 1 << 0)
        #expect(HorizontalEdge.Set.trailing.rawValue == 1 << 1)
        #expect(HorizontalEdge.Set.all == [.leading, .trailing])
    }
    
    @Test
    func horizontalEdgeSetContains() {
        let allSet = HorizontalEdge.Set.all
        #expect(allSet.contains(.leading))
        #expect(allSet.contains(.trailing))
        
        let leadingSet = HorizontalEdge.Set.leading
        #expect(leadingSet.contains(.leading))
        #expect(!leadingSet.contains(.trailing))
    }
    
    // MARK: - VerticalEdge Tests
    
    @Test
    func verticalEdgeRawValues() {
        #expect(VerticalEdge.top.rawValue == 0)
        #expect(VerticalEdge.bottom.rawValue == 1)
    }
    
    @Test
    func verticalEdgeCaseIterable() {
        let allCases = VerticalEdge.allCases
        #expect(allCases.count == 2)
        #expect(allCases.contains(.top))
        #expect(allCases.contains(.bottom))
    }
    
    @Test
    func verticalEdgeSetInitialization() {
        let topSet = VerticalEdge.Set(.top)
        let bottomSet = VerticalEdge.Set(.bottom)
        
        #expect(topSet.rawValue == 1 << 0)
        #expect(bottomSet.rawValue == 1 << 1)
    }
    
    @Test
    func verticalEdgeSetStaticProperties() {
        #expect(VerticalEdge.Set.top.rawValue == 1 << 0)
        #expect(VerticalEdge.Set.bottom.rawValue == 1 << 1)
        #expect(VerticalEdge.Set.all == [.top, .bottom])
    }
    
    @Test
    func verticalEdgeSetContains() {
        let allSet = VerticalEdge.Set.all
        #expect(allSet.contains(.top))
        #expect(allSet.contains(.bottom))
        
        let topSet = VerticalEdge.Set.top
        #expect(topSet.contains(.top))
        #expect(!topSet.contains(.bottom))
    }
}

