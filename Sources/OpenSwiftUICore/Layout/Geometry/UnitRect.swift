//
//  UnitRect.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

package import Foundation

package struct UnitRect: Hashable {
    package var x: CGFloat
    package var y: CGFloat
    package var width: CGFloat
    package var height: CGFloat
    
    @inlinable
    package init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    @inlinable
    package init(point: UnitPoint) {
        self.x = point.x
        self.y = point.y
        self.width = .zero
        self.height = .zero
    }
    
    @inlinable
    package func `in`(_ size: CGSize) -> CGRect {
        CGRect(x: x * size.width, y: y * size.height, width: width * size.width, height: height * size.height)
    }
    
    @inlinable
    package func `in`(_ rect: CGRect) -> CGRect {
        CGRect(x: x * rect.width + rect.x, y: y * rect.height + rect.y, width: width * rect.width, height: height * rect.height)
    }
    
    package static let one = UnitRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
}
