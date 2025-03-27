//
//  EdgeInsetsTests.swift
//  OpenSwiftUICoreTests
//
//  Audited for iOS 18.0
//  Status: Complete

import Testing
import OpenSwiftUICore

struct EdgeInsetsTests {
    // MARK: - Initialization Tests
    
    @Test
    func defaultInit() {
        let insets = EdgeInsets()
        #expect(insets.top == 0)
        #expect(insets.leading == 0)
        #expect(insets.bottom == 0)
        #expect(insets.trailing == 0)
    }
    
    @Test
    func customInit() {
        let insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        #expect(insets.top == 1)
        #expect(insets.leading == 2)
        #expect(insets.bottom == 3)
        #expect(insets.trailing == 4)
    }
    
    @Test
    func valueAndEdgesInit() {
        let allInsets = EdgeInsets(5, edges: .all)
        #expect(allInsets.top == 5)
        #expect(allInsets.leading == 5)
        #expect(allInsets.bottom == 5)
        #expect(allInsets.trailing == 5)
        
        let horizontalInsets = EdgeInsets(3, edges: .horizontal)
        #expect(horizontalInsets.top == 0)
        #expect(horizontalInsets.leading == 3)
        #expect(horizontalInsets.bottom == 0)
        #expect(horizontalInsets.trailing == 3)
        
        let verticalInsets = EdgeInsets(2, edges: .vertical)
        #expect(verticalInsets.top == 2)
        #expect(verticalInsets.leading == 0)
        #expect(verticalInsets.bottom == 2)
        #expect(verticalInsets.trailing == 0)
    }
    
    // MARK: - Static Properties Tests
    
    @Test
    func zero() {
        let zero = EdgeInsets.zero
        #expect(zero.top == 0)
        #expect(zero.leading == 0)
        #expect(zero.bottom == 0)
        #expect(zero.trailing == 0)
    }
    
    // MARK: - Subscript Tests
    
    @Test
    func subscriptAccess() {
        var insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        
        // Get
        #expect(insets[.top] == 1)
        #expect(insets[.leading] == 2)
        #expect(insets[.bottom] == 3)
        #expect(insets[.trailing] == 4)
        
        // Set
        insets[.top] = 5
        insets[.leading] = 6
        insets[.bottom] = 7
        insets[.trailing] = 8
        
        #expect(insets.top == 5)
        #expect(insets.leading == 6)
        #expect(insets.bottom == 7)
        #expect(insets.trailing == 8)
    }
    
    // MARK: - Arithmetic Tests
    
    @Test
    func addition() {
        let insets1 = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        let insets2 = EdgeInsets(top: 5, leading: 6, bottom: 7, trailing: 8)
        let sum = insets1.adding(insets2)
        
        #expect(sum.top == 6)
        #expect(sum.leading == 8)
        #expect(sum.bottom == 10)
        #expect(sum.trailing == 12)
    }
    
    @Test
    func addingOptionalInsets() {
        let insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        var optional = OptionalEdgeInsets()
        optional.top = 5
        optional.leading = 6
        
        let result = insets.adding(optional)
        #expect(result.top == 6)
        #expect(result.leading == 8)
        #expect(result.bottom == 3)
        #expect(result.trailing == 4)
    }
    
    @Test
    func merge() {
        let insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        var optional = OptionalEdgeInsets()
        optional.top = 5
        optional.leading = 6
        
        let result = insets.merge(optional)
        #expect(result.top == 5)
        #expect(result.leading == 6)
        #expect(result.bottom == 3)
        #expect(result.trailing == 4)
    }
    
    @Test
    func negatedInsets() {
        let insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        let negated = insets.negatedInsets
        
        #expect(negated.top == -1)
        #expect(negated.leading == -2)
        #expect(negated.bottom == -3)
        #expect(negated.trailing == -4)
    }
    
    @Test
    func originOffset() {
        let insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        let offset = insets.originOffset
        
        #expect(offset.width == 2)
        #expect(offset.height == 1)
    }
    
    // MARK: - Comparison Tests
    
    @Test
    func formPointwiseMin() {
        var insets = EdgeInsets(top: 3, leading: 4, bottom: 5, trailing: 6)
        let other = EdgeInsets(top: 1, leading: 4, bottom: 7, trailing: 2)
        
        insets.formPointwiseMin(other)
        #expect(insets.top == 1)
        #expect(insets.leading == 4)
        #expect(insets.bottom == 5)
        #expect(insets.trailing == 2)
    }
    
    @Test
    func formPointwiseMax() {
        var insets = EdgeInsets(top: 3, leading: 4, bottom: 5, trailing: 6)
        let other = EdgeInsets(top: 1, leading: 4, bottom: 7, trailing: 2)
        
        insets.formPointwiseMax(other)
        #expect(insets.top == 3)
        #expect(insets.leading == 4)
        #expect(insets.bottom == 7)
        #expect(insets.trailing == 6)
    }
    
    // MARK: - Layout Direction Tests
    
    @Test
    func xFlipIfRightToLeft() {
        var insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        
        // Should not flip for left-to-right
        insets.xFlipIfRightToLeft { .leftToRight }
        #expect(insets.leading == 2)
        #expect(insets.trailing == 4)
        
        // Should flip for right-to-left
        insets.xFlipIfRightToLeft { .rightToLeft }
        #expect(insets.leading == 4)
        #expect(insets.trailing == 2)
    }
    
    // MARK: - Animatable Tests
    
    @Test
    func animatableData() {
        let insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        let data = insets.animatableData
        
        #expect(data.first == 1)
        #expect(data.second.first == 2)
        #expect(data.second.second.first == 3)
        #expect(data.second.second.second == 4)
        
        var newInsets = EdgeInsets()
        newInsets.animatableData = data
        
        #expect(newInsets.top == 1)
        #expect(newInsets.leading == 2)
        #expect(newInsets.bottom == 3)
        #expect(newInsets.trailing == 4)
    }

    // MARK: - ProtobufMessage Tests

    @Test(
        arguments: [
            (EdgeInsets.zero, ""),
            (EdgeInsets(top: 1, leading: 2, bottom: 4, trailing: 8), "0d0000803f15000000401d000080402500000041")
        ]
    )
    func pbMessage(insets: EdgeInsets, hexString: String) throws {
        try insets.testPBEncoding(hexString: hexString)
        try insets.testPBDecoding(hexString: hexString)
    }
}
