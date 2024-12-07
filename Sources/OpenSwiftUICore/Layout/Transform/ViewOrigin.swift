//
//  ViewOrigin.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation

package struct ViewOrigin: Equatable {
    package var value: CGPoint
    
    @inlinable
    package init(invalid: Void) {
        self.init(CGPoint(x: Double.nan, y: Double.nan))
    }
    
    @inlinable
    package init(_ value: CGPoint) {
        self.value = value
    }
    
    @inlinable
    package init() {
        self.init(.zero)
    }
    
    @inlinable
    package var x: CGFloat {
        get { value.x }
        set { value.x = newValue }
    }
    
    @inlinable
    package var y: CGFloat {
        get { value.y }
        set { value.y = newValue }
    }
    
    @inline(__always)
    static let zero = ViewOrigin()
}

extension ViewOrigin {
    package subscript(d: Axis) -> CGFloat {
        get { d == .horizontal ? x : y }
        set { if d == .horizontal { x = newValue } else { y = newValue } }
    }
}

extension ViewOrigin: Animatable {
    package var animatableData: CGPoint.AnimatableData {
        get { value.animatableData }
        set { value.animatableData = newValue }
    }
}
