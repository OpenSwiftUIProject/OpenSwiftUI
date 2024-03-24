//
//  ViewOrigin.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

import Foundation

struct ViewOrigin: Equatable {
    var value: CGPoint
    
    @inline(__always)
    static var zero: ViewOrigin { ViewOrigin(value: .zero) }
}

extension ViewOrigin: Animatable {
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(value.x, value.y) }
        set { value = .init(x: newValue.first, y: newValue.second) }
    }
}
