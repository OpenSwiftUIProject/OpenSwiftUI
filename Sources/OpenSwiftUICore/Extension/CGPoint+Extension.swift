//
//  CGPoint+Extension.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import Foundation

@_spi(ForOpenSwiftUIOnly) public typealias PlatformPoint = CGPoint

extension CGPoint {
    @inlinable
    package static var infinity: CGPoint {
        .init(x: CGFloat.infinity, y: CGFloat.infinity)
    }

    @inlinable
    package init(_ size: CGSize) {
        self.init(x: size.width, y: size.height)
    }

    @inlinable
    package var isFinite: Bool {
        x.isFinite && y.isFinite
    }

    @inlinable
    package func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }

    @inlinable
    package func offsetBy(dx: CGFloat) -> CGPoint {
        offsetBy(dx: dx, dy: 0)
    }

    @inlinable
    package func offsetBy(dy: CGFloat) -> CGPoint {
        offsetBy(dx: 0, dy: dy)
    }

    @inlinable
    package func offset(by offset: CGSize) -> CGPoint {
        offsetBy(dx: offset.width, dy: offset.height)
    }

    @inlinable
    package func scaledBy(x: CGFloat, y: CGFloat) -> CGPoint {
        CGPoint(x: self.x * x, y: self.y * y)
    }

    @inlinable
    package func scaledBy(x: CGFloat) -> CGPoint {
        scaledBy(x: x, y: 1)
    }

    @inlinable
    package func scaledBy(y: CGFloat) -> CGPoint {
        scaledBy(x: 1, y: y)
    }

    @inlinable
    package func scaled(by scale: CGFloat) -> CGPoint {
        scaledBy(x: scale, y: scale)
    }

    @inlinable
    package var isNaN: Bool {
        x.isNaN || y.isNaN
    }
    
    @inlinable
    package var flushingNaNs: CGPoint {
        CGPoint(x: !x.isNaN ? x : 0, y: !y.isNaN ? y : 0)
    }
    
    @inlinable
    package func approximates(_ other: CGPoint, epsilon: CGFloat) -> Bool {
        x.approximates(other.x, epsilon: epsilon)
        && y.approximates(other.y, epsilon: epsilon)
    }

    @inlinable
    package mutating func clamp(size: CGSize) {
        x.clamp(to: 0...size.width)
        y.clamp(to: 0...size.height)
    }

    @inlinable
    package func clamped(size: CGSize) -> CGPoint {
        var point = self
        point.clamp(size: size)
        return point
    }

    @inlinable
    package mutating func clamp(rect: CGRect) {
        x.clamp(to: rect.x...rect.size.width)
        y.clamp(to: rect.y...rect.size.height)
    }

    @inlinable
    package func clamped(rect: CGRect) -> CGPoint {
        var point = self
        point.clamp(rect: rect)
        return point
    }
}

extension CGPoint {
    @inlinable
    package subscript(d: Axis) -> CGFloat {
        get { d == .horizontal ? x : y }
        set { if d == .horizontal { x = newValue } else { y = newValue } }
    }

    @inlinable
    package init(_ l1: CGFloat, in first: Axis, by l2: CGFloat) {
        self = first == .horizontal ? CGPoint(x: l1, y: l2) : CGPoint(x: l2, y: l1)
    }
}

extension CGPoint: Animatable {    
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        @inlinable
        get { .init(x, y) }
        @inlinable
        set { (x, y) = (newValue.first, newValue.second) }
    }
}

extension CGPoint: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) {
        encoder.cgFloatField(1, x)
        encoder.cgFloatField(2, y)
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        var x: CGFloat = .zero
        var y: CGFloat = .zero
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: x = try decoder.cgFloatField(field)
            case 2: y = try decoder.cgFloatField(field)
            default: try decoder.skipField(field)
            }
        }
        self.init(x: x, y: y)
    }
}
