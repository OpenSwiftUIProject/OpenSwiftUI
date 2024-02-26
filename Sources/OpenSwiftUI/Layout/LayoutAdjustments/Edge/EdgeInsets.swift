//
//  EdgeInsets.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#if canImport(Darwin)
import CoreGraphics
#else
import Foundation
#endif

/// The inset distances for the sides of a rectangle.
@frozen
public struct EdgeInsets: Equatable {
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
    /// Create edge insets from the equivalent NSDirectionalEdgeInsets.
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

extension EdgeInsets: Animatable, _VectorMath {
    @inlinable
    public var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>> {
        get {
            .init(top, .init(leading, .init(bottom, trailing)))
        }
        set {
            let top = newValue[].0
            let leading = newValue[].1[].0
            let (bottom, trailing) = newValue[].1[].1[]
            self = .init(
                top: top, leading: leading, bottom: bottom, trailing: trailing
            )
        }
    }
}

// MARK: - CodableEdgeInsets

struct CodableEdgeInsets: CodableProxy {
    var base: EdgeInsets

    @inline(__always)
    init(base: EdgeInsets) { self.base = base }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let top = try container.decode(CGFloat.self)
        let leading = try container.decode(CGFloat.self)
        let bottom = try container.decode(CGFloat.self)
        let trailing = try container.decode(CGFloat.self)
        base = EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(base.top)
        try container.encode(base.leading)
        try container.encode(base.bottom)
        try container.encode(base.trailing)
    }
}

// MARK: - EdgeInsets + CodableByProxy

extension EdgeInsets: CodableByProxy {
    var codingProxy: CodableEdgeInsets { CodableEdgeInsets(base: self) }

    static func unwrap(codingProxy: CodableEdgeInsets) -> EdgeInsets { codingProxy.base }
}

// MARK: - Sendable

extension EdgeInsets: Sendable {}
