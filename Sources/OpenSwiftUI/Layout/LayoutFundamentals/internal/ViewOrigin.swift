//
//  ViewOrigin.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

import Foundation

struct ViewOrigin: Equatable {
    var value: CGPoint
}

extension ViewOrigin: Animatable {
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(value.x, value.y) }
        set { value = .init(x: newValue.first, y: newValue.second) }
    }
}
