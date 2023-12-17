//
//  ViewOrigin.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/17.
//  Lastest Version: iOS 15.5
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
