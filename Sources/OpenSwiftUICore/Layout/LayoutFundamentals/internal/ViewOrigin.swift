//
//  ViewOrigin.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

package import Foundation

package struct ViewOrigin: Equatable {
    var value: CGPoint
    
    @inline(__always)
    static var zero: ViewOrigin { ViewOrigin(value: .zero) }
}

extension ViewOrigin: Animatable {
    package var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(value.x, value.y) }
        set { value = .init(x: newValue.first, y: newValue.second) }
    }
}
