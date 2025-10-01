//
//  CGSize+Extension.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

public import Foundation

extension CGSize {
    @inlinable
    package init(_ point: CGPoint) {
        self.init(width: point.x, height: point.y)
    }
    
    @inlinable
    package func scaledBy(x: CGFloat = 1, y: CGFloat = 1) -> CGSize {
        CGSize(
            width: width == 0 ? 0 : width * x,
            height: height == 0 ? 0 : height * y
        )
    }
    
    @inlinable
    package func scaled(by scale: CGFloat) -> CGSize {
        self.scaledBy(x: scale, y: scale)
    }
    
    @inlinable
    package func scaled(by scale: CGSize) -> CGSize {
        self.scaledBy(x: scale.width, y: scale.height)
    }
    
    @inlinable
    package func increasedBy(dWidth: CGFloat = 0, dHeight: CGFloat = 0) -> CGSize {
        CGSize(width: width + dWidth, height: height + dHeight)
    }
    
    @inlinable
    package var isFinite: Bool {
        width.isFinite && height.isFinite
    }
    
    @inlinable
    package var isNan: Bool {
        width.isNaN || height.isNaN
    }
    
    @inlinable
    package var hasZero: Bool {
        width == 0 || height == 0
    }
    
    @inlinable
    package var isNegative: Bool {
        width < 0 || height < 0
    }
    
    @inlinable
    package var isNonEmpty: Bool {
        width > 0 && height > 0
    }
    
    @inlinable
    package var flushingNaNs: CGSize {
        CGSize(
            width: !width.isNaN ? width : 0,
            height: !height.isNaN ? height : 0
        )
    }
    
    @inlinable
    package var flushingNegatives: CGSize {
        CGSize(
            width: max(width, 0.0),
            height: max(height, 0.0)
        )
    }
    
    @inlinable
    package func approximates(_ other: CGSize, epsilon: CGFloat) -> Bool {
        width.approximates(other.width, epsilon: epsilon)
        && height.approximates(other.height, epsilon: epsilon)
    }
}

extension CGSize {
    @inlinable
    package subscript(d: Axis) -> CGFloat {
        get { d == .horizontal ? width : height }
        set { if d == .horizontal { width = newValue } else { height = newValue } }
    }
    
    @inlinable
    package init(_ l1: CGFloat, in first: Axis, by l2: CGFloat) {
        self = first == .horizontal ? CGSize(width: l1, height: l2) : CGSize(width: l2, height: l1)
    }
}

extension CGSize {
    @inlinable
    package func contains(point p: CGPoint) -> Bool {
        !(p.x < 0) && !(p.y < 0) && p.x < width && p.y < height
    }
    
    @inlinable
    func containsAny(of points: [CGPoint]) -> Bool {
        for p in points where contains(point: p) {
            return true
        }
        return false
    }
}

extension CGSize {
    package static let invalidValue: CGSize = CGSize(width: Double.nan, height: Double.nan)
}

package struct HashableSize: Equatable, Hashable {
    package var width: CGFloat
    package var height: CGFloat
    package init(_ value: CGSize) {
        self.width = value.width
        self.height = value.height
    }
    package var value: CGSize {
        get { CGSize(width: width, height: height) }
        set { (width, height) = (newValue.width, newValue.height) }
    }
}

extension CGSize: Animatable {
    public typealias AnimatableData = AnimatablePair<CGFloat, CGFloat>
    
    public var animatableData: AnimatableData {
        @inlinable
        get { .init(width, height) }
        @inlinable
        set { (width, height) = newValue[] }
    }
}

extension CGSize: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) {
        encoder.cgFloatField(1, width)
        encoder.cgFloatField(2, height)
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        var width: CGFloat = .zero
        var height: CGFloat = .zero
        while let field = try decoder.nextField() {
            switch field.tag {
                case 1: width = try decoder.cgFloatField(field)
                case 2: height = try decoder.cgFloatField(field)
                default: try decoder.skipField(field)
            }
        }
        self.init(width: width, height: height)
    }
}

extension CGSize {
    @inlinable
    package static func + (lhs: CGSize, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: rhs.x + lhs.width, y: rhs.y + lhs.height)
    }
}
