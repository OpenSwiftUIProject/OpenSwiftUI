//
//  ScrollGeometry.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import Foundation

/// A type that defines the geometry of a scroll view.
///
/// OpenSwiftUI provides you values of this type when using modifiers like
/// ``View/onScrollGeometryChange(_:action:)`` or
/// ``View/onScrollPhaseChange(_:)``.
public struct ScrollGeometry: Equatable, Sendable {
    /// The content offset of the scroll view.
    ///
    /// This is the position of the scroll view within its overall
    /// content size. This value may extend before zero or beyond
    /// the content size when the content insets of the scroll view
    /// are non-zero or when rubber banding.
    public var contentOffset: CGPoint {
        didSet {
            visibleRect.origin += (contentOffset - oldValue)
        }
    }
    
    /// The size of the content of the scroll view.
    ///
    /// Unlike the container size of the scroll view, this refers to the
    /// total size of the content of the scroll view which can be smaller
    /// or larger than its containing size.
    public var contentSize: CGSize

    /// The content insets of the scroll view.
    ///
    /// Adding these insets to the content size of the scroll view
    /// will give you the total scrollable space of the scroll view.
    public var contentInsets: EdgeInsets

    /// The size of the container of the scroll view.
    ///
    /// This is the overall size of the scroll view. Combining this
    /// and the content offset will give you the current visible rect
    /// of the scroll view.
    public var containerSize: CGSize {
        didSet {
            visibleRect.size += (containerSize - oldValue)
        }
    }

    /// The visible rect of the scroll view.
    ///
    /// This value is computed from the scroll view's content offset, content
    /// insets, and its container size.
    public private(set) var visibleRect: CGRect

    /// The bounds rect of the scroll view.
    ///
    /// Unlike the visible rect, this value is within the content insets
    /// of the scroll view.
    public var bounds: CGRect { 
        CGRect(origin: contentOffset, size: containerSize)
    }
    
    package init(contentOffset: CGPoint, contentSize: CGSize, contentInsets: EdgeInsets, containerSize: CGSize, visibleRect: CGRect) {
        self.contentOffset = contentOffset
        self.contentSize = contentSize
        self.contentInsets = contentInsets
        self.containerSize = containerSize
        self.visibleRect = visibleRect
    }
}
extension ScrollGeometry {
    public init(contentOffset: CGPoint, contentSize: CGSize, contentInsets: EdgeInsets, containerSize: CGSize) {
        self.init(
            contentOffset: contentOffset,
            contentSize: contentSize,
            contentInsets: contentInsets,
            containerSize: containerSize,
            visibleRect: CGRect(origin: contentOffset, size: containerSize)
        )
    }
    
    package static var zero: ScrollGeometry {
        ScrollGeometry(contentOffset: .zero, contentSize: .zero, contentInsets: .zero, containerSize: .zero)
    }
    
    package static func viewTransform(contentInsets: EdgeInsets, contentSize: CGSize, containerSize: CGSize) -> ScrollGeometry {
        let rect = CGRect(origin: .zero, size: containerSize).outset(by: contentInsets)
        return ScrollGeometry(
            contentOffset: .zero,
            contentSize: contentSize,
            contentInsets: contentInsets,
            containerSize: containerSize,
            visibleRect: CGRect(origin: rect.origin, size: rect.size.flushingNegatives)
        )
    }
    
    package static func rootViewTransform(contentOffset: CGPoint, containerSize: CGSize) -> ScrollGeometry {
        ScrollGeometry(
            contentOffset: contentOffset,
            contentSize: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
            contentInsets: .zero,
            containerSize: containerSize
        )
    }
    
    package static func size(_ size: CGSize) -> ScrollGeometry {
        ScrollGeometry(contentOffset: .zero, contentSize: size, contentInsets: .zero, containerSize: size)
    }
}

extension ScrollGeometry {
    package mutating func applyLayoutDirection(_ direction: LayoutDirection, contentSize: CGSize?) {
        guard direction == .rightToLeft else { return }
        contentOffset.x = (contentSize?.width ?? self.contentSize.width) - bounds.maxX
    }
    
    package mutating func translate(by translation: CGSize, limit: CGSize) {
        let newOffsetX = min(
            max(contentInsets.trailing + limit.width - containerSize.width, 0),
            max(contentOffset.x + translation.width, -contentInsets.leading)
        )
        let newOffsetY = min(
            max(contentInsets.bottom + limit.height - containerSize.height, 0),
            max(contentOffset.y + translation.height, -contentInsets.top)
        )
        contentOffset = CGPoint(x: newOffsetX, y: newOffsetY)
    }
    
    package mutating func outsetForAX(limit: CGSize) {
        if containerSize.width < limit.width {
            let offsetX = max(contentOffset.x - containerSize.width, 0)
            let newOffsetX = min(offsetX, contentOffset.x)
            let originalOffsetX = contentOffset.x
            contentOffset.x = newOffsetX

            let adjustedWidth = containerSize.width + originalOffsetX - newOffsetX
            let remainingWidth = limit.width - originalOffsetX
            let extendedWidth = containerSize.width + adjustedWidth

            containerSize.width = max(min(remainingWidth, extendedWidth), adjustedWidth)
        }
        if containerSize.height < limit.height {
            let offsetY = max(contentOffset.y - containerSize.height, 0)
            let newOffsetY = min(offsetY, contentOffset.y)
            let originalOffsetY = contentOffset.y
            contentOffset.y = newOffsetY

            let adjustedHeight = containerSize.height + originalOffsetY - newOffsetY
            let remainingHeight = limit.height - originalOffsetY
            let extendedHeight = containerSize.height + adjustedHeight

            containerSize.height = max(min(remainingHeight, extendedHeight), adjustedHeight)
        }
    }
}

extension ScrollGeometry: CustomDebugStringConvertible {
    public var debugDescription: String {
        "<ScrollGeometry: contentOffset \(contentOffset), contentSize \(contentSize), contentInsets \(contentInsets), containerSize \(containerSize), visibleRect \(visibleRect)>"
    }
}
