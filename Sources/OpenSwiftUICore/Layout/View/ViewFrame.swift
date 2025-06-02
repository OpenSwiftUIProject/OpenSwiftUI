//
//  ViewFrame.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation

package struct ViewFrame: Equatable {
    package var origin: ViewOrigin
    package var size: ViewSize
    
    @inlinable
    package init(origin: ViewOrigin, size: ViewSize) {
        self.origin = origin
        self.size = size
    }
    
    @inlinable
    package init(size: ViewSize) {
        self.origin = ViewOrigin()
        self.size = size
    }
}

extension ViewFrame {
    package mutating func round(toMultipleOf m: CGFloat) {
        var rect = CGRect(self)
        rect.roundCoordinatesToNearestOrUp(toMultipleOf: m)
        origin = rect.origin
        size.value = rect.size
    }
}

extension ViewFrame: Animatable {
    package var animatableData: CGRect.AnimatableData {
        get { .init(origin.animatableData, size.animatableData) }
        set { (origin.animatableData, size.animatableData) = (newValue.first, newValue.second) }
    }
}

extension CGRect {
    package init(_ frame: ViewFrame) {
        self.init(origin: frame.origin, size: frame.size.value)
    }
}
