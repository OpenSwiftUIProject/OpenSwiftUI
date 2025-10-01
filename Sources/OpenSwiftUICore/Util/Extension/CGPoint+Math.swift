//
//  CGPoint+Math.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

public import Foundation
#if canImport(Darwin)
import CoreGraphics
#endif

#if canImport(Darwin)

extension CGPoint {
    package func unapplying(_ m: CGAffineTransform) -> CGPoint {
        if m.isTranslation {
            self - CGSize(width: m.tx, height: m.ty)
        } else {
            applying(m.inverted())
        }
    }
}
#endif

package func distance(_ p0: CGPoint, _ p1: CGPoint) -> CGFloat {
    let dx = p1.x - p0.x
    let dy = p1.y - p0.y
    return sqrt(dx * dx + dy * dy)
}

extension CGPoint {
    package func clamp(min minValue: CGPoint, max maxValue: CGPoint) -> CGPoint {
        CGPoint(
            x: x.clamp(min: minValue.x, max: maxValue.x),
            y: y.clamp(min: minValue.y, max: maxValue.y)
        )
    }
}

extension CGPoint {
    @inlinable
    package static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        lhs.offset(by: rhs)
    }
    
    @inlinable
    package static func - (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        lhs + -rhs
    }
    
    @inlinable
    package static func += (lhs: inout CGPoint, rhs: CGSize) {
        lhs = lhs + rhs
    }
    
    @inlinable
    package static func -= (lhs: inout CGPoint, rhs: CGSize) {
        lhs = lhs - rhs
    }
    
    @inlinable
    package static prefix func - (lhs: CGPoint) -> CGPoint {
        CGPoint(x: -lhs.x, y: -lhs.y)
    }
    
    @inlinable
    package static func - (lhs: CGPoint, rhs: CGPoint) -> CGSize {
        CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
    }
    
    @inlinable
    package static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        lhs.scaled(by: rhs)
    }
    
    @inlinable
    package static func *= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs * rhs
    }
}
