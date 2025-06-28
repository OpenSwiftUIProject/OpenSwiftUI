//
//  CGRect+Extension.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import Foundation
#if canImport(Darwin)
public import CoreGraphics
#endif

// MARK: CGRect + Extensions

extension CGRect {
    @inlinable
    package var x: CGFloat {
        get { origin.x }
        set { origin.x = newValue }
    }
    
    @inlinable
    package var y: CGFloat {
        get { origin.y }
        set { origin.y = newValue }
    }
    
    @inlinable
    package var center: CGPoint {
        get { CGPoint(x: x + width / 2, y: y + height / 2) }
        set { x = newValue.x - width / 2; y = newValue.y - height / 2 }
    }
    
    @inlinable
    package init(size: CGSize) {
        self.init(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    @inlinable
    package init(center: CGPoint, size: CGSize) {
        self.init(
            x: center.x - size.width * 0.5,
            y: center.y - size.height * 0.5,
            width: size.width, height: size.height
        )
    }
    
    @inlinable
    package var isFinite: Bool {
        x.isFinite && y.isFinite && width.isFinite && height.isFinite
    }
    
    @inlinable
    package func flushNullToZero() -> CGRect {
        isNull ? .zero : self
    }
    
    @inlinable
    package func offset(by offset: CGSize) -> CGRect {
        offsetBy(dx: offset.width, dy: offset.height)
    }
    
    @inlinable
    package func scaledBy(x: CGFloat = 1, y: CGFloat = 1) -> CGRect {
        if isNull || isInfinite {
            return self
        }
        return CGRect(x: x * self.x, y: y * self.y, width: width * x, height: height * y)
    }
    
    @inlinable
    package func scaled(by scale: CGFloat) -> CGRect {
        scaledBy(x: scale, y: scale)
    }
    
    @inlinable
    package func hasIntersection(_ rect: CGRect) -> Bool {
        !intersection(rect).isEmpty
    }
    
    @inlinable
    package var maxXY: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }
    
    @inlinable
    package var minXY: CGPoint {
        CGPoint(x: minX, y: minY)
    }
}

// MARK: CGRect + OpenSwiftUI Extensions

extension CGRect {
    @inlinable
    package init(position: CGPoint, size: CGSize, anchor: UnitPoint) {
        self.init(
            x: position.x - size.width * anchor.x,
            y: position.y - size.height * anchor.y,
            width: size.width,
            height: size.height
        )
    }
    
    @inlinable
    package subscript(axis: Axis) -> ClosedRange<CGFloat> {
        guard !isNull else { return 0 ... 0 }
        let x0 = origin[axis], x1 = x0 + size[axis]
        var lower = min(x0, x1), upper = max(x0, x1)
        if !(lower <= upper) {
            (lower, upper) = (0, 0)
        }
        return ClosedRange(uncheckedBounds: (lower: lower, upper: upper))
    }
    
    @inlinable
    package subscript(edge: Edge) -> CGFloat {
        switch edge {
            case .leading: return minX
            case .trailing: return maxX
            case .top: return minY
            case .bottom: return maxY
        }
    }
    
    @inlinable
    package mutating func finalizeLayoutDirection(_ layoutDirection: LayoutDirection, parentSize: CGSize) {
        guard layoutDirection == .rightToLeft else { return }
        origin.x = parentSize.width - maxX
    }
    
    package func distance(to other: CGRect, in axis: Axis) -> CGFloat {
        let selfOrigin = origin[axis]
        let selfSize = size[axis]
        let otherOrigin = other.origin[axis]
        let otherSize = other.size[axis]
        
        return abs((otherOrigin + otherSize) - (selfSize / 2 + selfOrigin)) - (selfSize / 2 + otherSize)
    }
}

extension CGRect {
    package var cornerPoints: [CGPoint] {
        [
            origin,
            origin.offsetBy(dx: width),
            origin.offsetBy(dx: width, dy: height),
            origin.offsetBy(dy: height),
        ]
    }
    
    package init(cornerPoints p: ArraySlice<CGPoint>) {
        let p0 = p[0]
        let p1 = p[1]
        let p2 = p[2]
        let p3 = p[3]
        
        let minX = min(min(p0.x, p1.x), min(p2.x, p3.x))
        let minY = min(min(p0.y, p1.y), min(p2.y, p3.y))
        let maxX = max(max(p0.x, p1.x), max(p2.x, p3.x))
        let maxY = max(max(p0.y, p1.y), max(p2.y, p3.y))
        
        self.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    package init?(exactCornerPoints p: [CGPoint]) {
        let p0 = p[0]
        let p1 = p[1]
        let p2 = p[2]
        let p3 = p[3]
        guard p0.x == p3.x && p1.x == p2.x && p0.y == p1.y && p2.y == p3.y else {
            return nil
        }
        self.init(x: p0.x, y: p0.y, width: p1.x - p0.x, height: p2.y - p0.y)
    }
    
    package init(cornerPoints p: [CGPoint]) {
        self.init(cornerPoints: p[0...3])
    }

    package func mapCorners(f: (inout [CGPoint]) -> Void) -> CGRect {
        if isNull || isInfinite {
            return self
        }
        var cornerPoints = cornerPoints
        f(&cornerPoints)
        return CGRect(cornerPoints: cornerPoints)
    }
}

extension CGRect {
    /// Returns the minimum distance from the rectangle to the given point
    package func distance(to point: CGPoint) -> CGFloat {
        let dx = abs(point.x - midX) - width / 2
        let dy = abs(point.y - midY) - height / 2
        if min(dx, dy) <= 0 {
            return max(dx, dy)
        } else {
            return sqrt(dx * dx + dy * dy)
        }
    }
    
    /// Returns the perpendicular distance from the point to the nearest edge or corner
    package func perpendicularDistance(to point: CGPoint) -> CGFloat {
        let dx = abs(point.x - midX) - width / 2
        let dy = abs(point.y - midY) - height / 2
        return max(dx, dy)
    }
    
    package func containsAny(of points: [CGPoint]) -> Bool {
        points.contains { contains($0) }
    }
}

package struct LoggableRect: CustomStringConvertible {
    private var rect: CGRect
    
    package init(_ rect: CGRect) {
        self.rect = rect
    }
    
    package var description: String {
        "(\(rect.x), \(rect.y), \(rect.width), \(rect.height))"
    }
}

extension CGRect {
    package var loggable: LoggableRect {
        LoggableRect(self)
    }
}

// MARK: CGRect + Animatable

extension CGRect: Animatable {
    public var animatableData: AnimatablePair<CGPoint.AnimatableData, CGSize.AnimatableData> {
        @inlinable
        get { .init(origin.animatableData, size.animatableData) }
        @inlinable
        set { (origin.animatableData, size.animatableData) = (newValue.first, newValue.second) }
    }
}

// MARK: CGRect + ProtobufMessage

extension CGRect: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) {
        withUnsafePointer(to: self) { pointer in
            let pointer = UnsafeRawPointer(pointer).assumingMemoryBound(to: CGFloat.self)
            let bufferPointer = UnsafeBufferPointer(start: pointer, count: 4)
            for index: UInt in 1 ... 4 {
                encoder.cgFloatField(
                    index,
                    bufferPointer[Int(index &- 1)]
                )
            }
        }
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        var rect = CGRect.zero
        try withUnsafeMutablePointer(to: &rect) { pointer in
            let pointer = UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: CGFloat.self)
            let bufferPointer = UnsafeMutableBufferPointer(start: pointer, count: 4)
            while let field = try decoder.nextField() {
                let tag = field.tag
                switch tag {
                    case 1...4: bufferPointer[Int(tag &- 1)] = try decoder.cgFloatField(field)
                    default: try decoder.skipField(field)
                }
            }
        }
        self = rect
    }
}
