//
//  EdgeInsets.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/8.
//  Lastest Version: iOS 15.5
//  Status: WIP

import Foundation

@frozen public struct EdgeInsets: Equatable {
    public var top: CGFloat
    public var leading: CGFloat
    public var bottom: CGFloat
    public var trailing: CGFloat

    @inlinable
    @inline(__always)
    public init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }

    @inlinable
    @inline(__always)
    public init() {
        self.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    }

    @inline(__always)
    init(_ value: CGFloat, edges: Edge.Set) {
        self.init(
            top: edges.contains(.top) ? value : 0,
            leading: edges.contains(.leading) ? value : 0,
            bottom: edges.contains(.bottom) ? value : 0,
            trailing: edges.contains(.trailing) ? value : 0
        )
    }

    func `in`(edges: Edge.Set) -> EdgeInsets {
        EdgeInsets(
            top: edges.contains(.top) ? top : 0,
            leading: edges.contains(.leading) ? leading : 0,
            bottom: edges.contains(.bottom) ? bottom : 0,
            trailing: edges.contains(.trailing) ? trailing : 0
        )
    }

    mutating func formPointwiseMin(insets: EdgeInsets) {
        if insets.top < top { top = insets.top }
        if insets.leading < leading { leading = insets.leading }
        if insets.bottom < bottom { bottom = insets.bottom }
        if insets.trailing < trailing { trailing = insets.trailing }
    }
//  codingProxy
}

extension EdgeInsets {
    @usableFromInline
    @inline(__always)
    init(_all all: CGFloat) {
        self.init(top: all, leading: all, bottom: all, trailing: all)
    }
}

#if canImport(Darwin)
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
extension EdgeInsets {
    @inline(__always)
    @available(watchOS, unavailable)
    public init(_ nsEdgeInsets: NSDirectionalEdgeInsets) {
        self.init(
            top: nsEdgeInsets.top,
            leading: nsEdgeInsets.leading,
            bottom: nsEdgeInsets.bottom,
            trailing: nsEdgeInsets.trailing
        )
    }
}

extension NSDirectionalEdgeInsets {
    @inline(__always)
    @available(watchOS, unavailable)
    public init(_ edgeInsets: EdgeInsets) {
        self.init(
            top: edgeInsets.top,
            leading: edgeInsets.leading,
            bottom: edgeInsets.bottom,
            trailing: edgeInsets.trailing
        )
    }
}
#endif


extension EdgeInsets/*: Animatable, _VectorMath*/ {
//    public typealias AnimatableData = AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>>
//    public var animatableData: EdgeInsets.AnimatableData {
//        @inlinable get {
//            .init(top, .init(leading, .init(bottom, trailing)))
//        }
//        @inlinable set {
//            let top = newValue[].0
//            let leading = newValue[].1[].0
//            let (bottom, trailing) = newValue[].1[].1[]
//            self = .init(
//                top: top, leading: leading, bottom: bottom, trailing: trailing
//            )
//        }
//    }
}

// MARK: - EdgeInsets + CodableByProxy

//struct CodableEdgeInsets: CodableProxy {
//    typealias Base = EdgeInsets
//    var base : EdgeInsets
//}
//
//extension EdgeInsets : CodableByProxy {
//    typealias CodingProxy = CodableEdgeInsets
//
//}

// MARK: - Sendable

extension EdgeInsets : Sendable {}
