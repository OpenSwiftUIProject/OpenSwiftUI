//
//  EdgeInsets.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

public import Foundation

// MARK: - EdgeInsets

/// The inset distances for the sides of a rectangle.
@frozen
public struct EdgeInsets: Equatable {
    public var top: CGFloat
    public var leading: CGFloat
    public var bottom: CGFloat
    public var trailing: CGFloat

    @inlinable
    public init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }

    @inlinable
    public init() {
        self.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    }

    package static var zero: EdgeInsets { EdgeInsets() }
}

// MARK: - OptionalEdgeInsets

package struct OptionalEdgeInsets: Hashable {
    package static var none: OptionalEdgeInsets {
        OptionalEdgeInsets()
    }
    
    package static var zero: OptionalEdgeInsets {
        OptionalEdgeInsets(0, edges: .all)
    }

    package var top: CGFloat?
    package var leading: CGFloat?
    package var bottom: CGFloat?
    package var trailing: CGFloat?
        
    package init() {}
    
    package init(
        top: CGFloat? = nil,
        leading: CGFloat? = nil,
        bottom: CGFloat? = nil,
        trailing: CGFloat? = nil
    ) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
    
    package init(_ value: CGFloat?, edges: Edge.Set) {
        if edges.contains(.top) { top = value }
        if edges.contains(.leading) { leading = value }
        if edges.contains(.bottom) { bottom = value }
        if edges.contains(.trailing) { trailing = value }
    }
    
    package init(_ value: EdgeInsets, edges: Edge.Set) {
        if edges.contains(.top) { top = value.top }
        if edges.contains(.leading) { leading = value.leading }
        if edges.contains(.bottom) { bottom = value.bottom }
        if edges.contains(.trailing) { trailing = value.trailing }
    }
    
    package subscript(edge: Edge) -> CGFloat? {
        get {
            switch edge {
            case .top: return top
            case .leading: return leading
            case .bottom: return bottom
            case .trailing: return trailing
            }
        }
        set {
            switch edge {
            case .top: top = newValue
            case .leading: leading = newValue
            case .bottom: bottom = newValue
            case .trailing: trailing = newValue
            }
        }
    }
    
    package func adding(_ other: OptionalEdgeInsets) -> OptionalEdgeInsets {
        var result = self
        if let otherTop = other.top { result.top = (result.top ?? 0) + otherTop }
        if let otherLeading = other.leading { result.leading = (result.leading ?? 0) + otherLeading }
        if let otherBottom = other.bottom { result.bottom = (result.bottom ?? 0) + otherBottom }
        if let otherTrailing = other.trailing { result.trailing = (result.trailing ?? 0) + otherTrailing }
        return result
    }
    
    package func `in`(axes: Axis.Set) -> OptionalEdgeInsets {
        var result = OptionalEdgeInsets()
        if axes.contains(.horizontal) {
            result.leading = leading
            result.trailing = trailing
        }
        if axes.contains(.vertical) {
            result.top = top
            result.bottom = bottom
        }
        return result
    }
    
    package func `in`(edges: Edge.Set) -> OptionalEdgeInsets {
        var result = OptionalEdgeInsets()
        if edges.contains(.top) { result.top = top }
        if edges.contains(.leading) { result.leading = leading }
        if edges.contains(.bottom) { result.bottom = bottom }
        if edges.contains(.trailing) { result.trailing = trailing }
        return result
    }
    
    package func `in`(axes: Axis.Set) -> EdgeInsets {
        EdgeInsets(
            top: axes.contains(.vertical) ? (top ?? 0) : 0,
            leading: axes.contains(.horizontal) ? (leading ?? 0) : 0,
            bottom: axes.contains(.vertical) ? (bottom ?? 0) : 0,
            trailing: axes.contains(.horizontal) ? (trailing ?? 0) : 0
        )
    }
    
    package func `in`(edges: Edge.Set) -> EdgeInsets {
        EdgeInsets(
            top: edges.contains(.top) ? (top ?? 0) : 0,
            leading: edges.contains(.leading) ? (leading ?? 0) : 0,
            bottom: edges.contains(.bottom) ? (bottom ?? 0) : 0,
            trailing: edges.contains(.trailing) ? (trailing ?? 0) : 0
        )
    }
}

// MARK: - EdgeInsets + Extension

extension EdgeInsets {
    package init(_ value: CGFloat, edges: Edge.Set) {
        self.init(
            top: edges.contains(.top) ? value : 0,
            leading: edges.contains(.leading) ? value : 0,
            bottom: edges.contains(.bottom) ? value : 0,
            trailing: edges.contains(.trailing) ? value : 0
        )
    }

    package init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        )
    }

    package func subtracting(_ other: EdgeInsets) -> EdgeInsets {
        EdgeInsets(
            top: top - other.top,
            leading: leading - other.leading,
            bottom: bottom - other.bottom,
            trailing: trailing - other.trailing
        )
    }

    package var isEmpty: Bool {
        top == 0 && leading == 0 && bottom == 0 && trailing == 0
    }

    package var vertical: CGFloat {
        top + bottom
    }

    package var horizontal: CGFloat {
        leading + trailing
    }

    package subscript(edge: Edge) -> CGFloat {
        get {
            switch edge {
            case .top: return top
            case .leading: return leading
            case .bottom: return bottom
            case .trailing: return trailing
            }
        }
        set {
            switch edge {
            case .top: top = newValue
            case .leading: leading = newValue
            case .bottom: bottom = newValue
            case .trailing: trailing = newValue
            }
        }
    }

    package func `in`(_ edges: Edge.Set) -> EdgeInsets {
        EdgeInsets(
            top: edges.contains(.top) ? top : 0,
            leading: edges.contains(.leading) ? leading : 0,
            bottom: edges.contains(.bottom) ? bottom : 0,
            trailing: edges.contains(.trailing) ? trailing : 0
        )
    }
    
    package func scaled(by scalar: CGFloat) -> EdgeInsets {
        EdgeInsets(
            top: top * scalar,
            leading: leading * scalar,
            bottom: bottom * scalar,
            trailing: trailing * scalar
        )
    }

    package func adding(_ other: EdgeInsets) -> EdgeInsets {
        EdgeInsets(
            top: top + other.top,
            leading: leading + other.leading,
            bottom: bottom + other.bottom,
            trailing: trailing + other.trailing
        )
    }
    
    package func adding(_ other: OptionalEdgeInsets) -> EdgeInsets {
        var result = self
        if let otherTop = other.top { result.top += otherTop }
        if let otherLeading = other.leading { result.leading += otherLeading }
        if let otherBottom = other.bottom { result.bottom += otherBottom }
        if let otherTrailing = other.trailing { result.trailing += otherTrailing }
        return result
    }

    package func merge(_ other: OptionalEdgeInsets) -> EdgeInsets {
        EdgeInsets(
            top: other.top ?? top,
            leading: other.leading ?? leading,
            bottom: other.bottom ?? bottom,
            trailing: other.trailing ?? trailing
        )
    }

    package var negatedInsets: EdgeInsets {
        EdgeInsets(
            top: -top,
            leading: -leading,
            bottom: -bottom,
            trailing: -trailing
        )
    }

    package var originOffset: CGSize {
        CGSize(width: leading, height: top)
    }

    package mutating func formPointwiseMin(_ other: EdgeInsets) {
        top = min(top, other.top)
        leading = min(leading, other.leading)
        bottom = min(bottom, other.bottom)
        trailing = min(trailing, other.trailing)
    }

    package mutating func formPointwiseMax(_ other: EdgeInsets) {
        top = max(top, other.top)
        leading = max(leading, other.leading)
        bottom = max(bottom, other.bottom)
        trailing = max(trailing, other.trailing)
    }

    @inline(__always)
    package mutating func xFlipIfRightToLeft(layoutDirection: () -> LayoutDirection) {
        let leading = self.leading
        let trailing = self.trailing
        guard leading != trailing else { return }
        guard layoutDirection() == .rightToLeft else { return }
        self.leading = trailing
        self.trailing = leading
    }
}

extension EdgeInsets {
    package func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(leading)
        hasher.combine(bottom)
        hasher.combine(trailing)
    }
}

extension CGRect {
    package func inset(by insets: EdgeInsets, layoutDirection: @autoclosure () -> LayoutDirection) -> CGRect {
        guard !isNull else { return self }
        var s = standardized
        s.x += layoutDirection() == .rightToLeft ? insets.trailing : insets.leading
        s.y += insets.top
        s.size.width -= insets.horizontal
        s.size.height -= insets.vertical
        
        guard s.size.width >= 0,
              s.size.height >= 0
        else { return .null }
        return s
    }
    
    package func inset(by insets: EdgeInsets) -> CGRect {
        inset(by: insets, layoutDirection: .leftToRight)
    }
    
    package func outset(by insets: EdgeInsets, layoutDirection: @autoclosure () -> LayoutDirection = .leftToRight) -> CGRect {
        guard !isNull else { return self }
        var s = standardized
        s.x -= layoutDirection() == .rightToLeft ? insets.trailing : insets.leading
        s.y -= insets.top
        s.size.width += insets.horizontal
        s.size.height += insets.vertical
        
        guard s.size.width >= 0,
              s.size.height >= 0
        else { return .null }
        return s
    }
    
    package func outset(by insets: EdgeInsets) -> CGRect {
        outset(by: insets, layoutDirection: .leftToRight)
    }
}

extension CGSize {
    package func inset(by insets: EdgeInsets) -> CGSize {
        CGSize(
            width: max(width - insets.horizontal, 0),
            height: max(height - insets.vertical, 0)
        )
    }
    
    package func outset(by insets: EdgeInsets) -> CGSize {
        CGSize(
            width: max(width + insets.horizontal, 0),
            height: max(height + insets.vertical, 0)
        )
    }
}

extension CGPoint {
    package func offset(by insets: EdgeInsets) -> CGPoint {
        CGPoint(
            x: insets.leading + x,
            y: insets.top + y
        )
    }
}

// MARK: - EdgeInsets + Animatable

extension EdgeInsets: Animatable, _VectorMath {
    public typealias AnimatableData = AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>>
    
    public var animatableData: AnimatableData {
        @inlinable
        get {
            .init(top, .init(leading, .init(bottom, trailing)))
        }
        @inlinable
        set {
            let top = newValue.first
            let leading = newValue.second.first
            let bottom = newValue.second.second.first
            let trailing = newValue.second.second.second
            self = .init(
                top: top, leading: leading, bottom: bottom, trailing: trailing
            )
        }
    }
}

extension EdgeInsets {
    @usableFromInline
    package init(_all all: CGFloat) {
        self.init(top: all, leading: all, bottom: all, trailing: all)
    }
}

// MARK: - EdgeInsets + ProtobufMessage

extension EdgeInsets: ProtobufMessage {
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
        var insets = EdgeInsets.zero
        try withUnsafeMutablePointer(to: &insets) { pointer in
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
        self = insets
    }
}
