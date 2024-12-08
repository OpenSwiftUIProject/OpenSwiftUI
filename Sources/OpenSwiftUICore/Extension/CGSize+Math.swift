//
//  CGSize+Math.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import Foundation

extension CGSize {
    @inlinable
    prefix package static func - (operand: CGSize) -> CGSize {
        var result = operand
        result.width = -result.width
        result.height = -result.height
        return result
    }
    
    @inlinable
    package static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs.width += rhs.width
        lhs.height += rhs.height
    }
    
    @inlinable
    package static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        var result = lhs
        result += rhs
        return result
    }
    
    @inlinable
    package static func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs.width -= rhs.width
        lhs.height -= rhs.height
    }
    
    @inlinable
    package static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        var result = lhs
        result -= rhs
        return result
    }
    
    @inlinable
    package static func *= (lhs: inout CGSize, rhs: Double) {
        lhs.width *= CGFloat(rhs)
        lhs.height *= CGFloat(rhs)
    }
    
    @inlinable
    package static func * (lhs: CGSize, rhs: Double) -> CGSize {
        var result = lhs
        result *= rhs
        return result
    }
    
    @inlinable
    package static func /= (lhs: inout CGSize, rhs: Double) {
        lhs *= 1 / rhs
    }
    
    @inlinable
    package static func / (lhs: CGSize, rhs: Double) -> CGSize {
        var result = lhs
        result /= rhs
        return result
    }
}

package func mix(_ lhs: CGSize, _ rhs: CGSize, by t: Double) -> CGSize {
    CGSize(
        width: (rhs.width - lhs.width) * t + lhs.width,
        height: (rhs.height - lhs.height) * t + lhs.height
    )
}
