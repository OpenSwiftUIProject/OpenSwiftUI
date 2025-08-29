//
//  ViewGeometry.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation
package import OpenAttributeGraphShims

/// A type that represents the position and dimensions of a view in its parent's coordinate space.
///
/// `ViewGeometry` encapsulates both the origin (position) and dimensions (size and alignment guides)
/// of a view. It provides methods to access alignment guides and convert to other geometric types.
package struct ViewGeometry: Equatable {
    /// The position of the view in its parent's coordinate space.
    package var origin: ViewOrigin

    /// The size and alignment information of the view.
    package var dimensions: ViewDimensions

    /// Creates a view geometry with the specified origin and dimensions.
    ///
    /// - Parameters:
    ///   - origin: The position of the view.
    ///   - dimensions: The size and alignment information of the view.
    package init(origin: ViewOrigin, dimensions: ViewDimensions) {
        self.origin = origin
        self.dimensions = dimensions
    }

    /// Creates a view geometry at the default origin with the specified dimensions.
    ///
    /// - Parameter dimensions: The size and alignment information of the view.
    package init(dimensions: ViewDimensions) {
        self.init(origin: ViewOrigin(), dimensions: dimensions)
    }

    /// Creates a view geometry using placement and dimensions information.
    ///
    /// - Parameters:
    ///   - p: The placement that determines the origin of the view.
    ///   - d: The size and alignment information of the view.
    package init(placement p: _Placement, dimensions d: ViewDimensions) {
        self.origin = ViewOrigin(p.frameOrigin(childSize: d.size.value))
        self.dimensions = d
    }

    /// Returns the position of the specified horizontal alignment guide.
    ///
    /// - Parameter guide: The horizontal alignment guide to measure.
    /// - Returns: The x-coordinate of the alignment guide in the parent's coordinate space.
    package subscript(guide: HorizontalAlignment) -> CGFloat { dimensions[guide] }

    /// Returns the position of the specified vertical alignment guide.
    ///
    /// - Parameter guide: The vertical alignment guide to measure.
    /// - Returns: The y-coordinate of the alignment guide in the parent's coordinate space.
    package subscript(guide: VerticalAlignment) -> CGFloat { dimensions[guide] }

    /// Returns the explicit position of the specified horizontal alignment guide if available.
    ///
    /// - Parameter guide: The horizontal alignment guide to measure.
    /// - Returns: The x-coordinate of the alignment guide, or nil if not explicitly defined.
    package subscript(explicit guide: HorizontalAlignment) -> CGFloat? { dimensions[explicit: guide] }

    /// Returns the explicit position of the specified vertical alignment guide if available.
    ///
    /// - Parameter guide: The vertical alignment guide to measure.
    /// - Returns: The y-coordinate of the alignment guide, or nil if not explicitly defined.
    package subscript(explicit guide: VerticalAlignment) -> CGFloat? { dimensions[explicit: guide] }
}

/// Extension to provide convenient accessors for `Attribute<ViewGeometry>`.
extension Attribute where Value == ViewGeometry {
    /// Returns an attribute representing the origin of the view geometry.
    ///
    /// - Returns: An attribute containing the view's origin.
    package func origin() -> Attribute<ViewOrigin> { self[keyPath: \.origin] }
    
    /// Returns an attribute representing the size of the view geometry.
    ///
    /// - Returns: An attribute containing the view's size.
    package func size() -> Attribute<ViewSize> { self[keyPath: \.dimensions.size] }
}

extension ViewGeometry {
    /// The frame of the view as a CGRect.
    ///
    /// This property combines the origin and size information into a CGRect.
    package var frame: CGRect {
        CGRect(origin: origin, size: dimensions.size.value)
    }

    /// A view geometry value representing an invalid state.
    ///
    /// This value is used to indicate errors or uninitialized states.
    package static let invalidValue = ViewGeometry(origin: .invalidValue, dimensions: .invalidValue)

    /// Indicates whether this view geometry is in an invalid state.
    package var isInvalid: Bool { origin.x.isNaN }

    /// A view geometry with zero origin and zero dimensions.
    ///
    /// This property provides a convenient way to create a view geometry at the origin
    /// with zero size.
    package static let zero = ViewGeometry(origin: CGPoint.zero, dimensions: .zero)

    /// Returns the position of the specified alignment key.
    ///
    /// - Parameter key: The alignment key to measure.
    /// - Returns: The coordinate of the alignment guide in the parent's coordinate space.
    package subscript(key: AlignmentKey) -> CGFloat { dimensions[key] }

    /// Returns the explicit position of the specified alignment key if available.
    ///
    /// - Parameter key: The alignment key to measure.
    /// - Returns: The coordinate of the alignment guide, or nil if not explicitly defined.
    package subscript(explicit key: AlignmentKey) -> CGFloat? { dimensions[explicit: key] }

    /// Adjusts the origin to account for right-to-left layout direction.
    ///
    /// This method flips the x-coordinate when in right-to-left layout mode to maintain
    /// proper visual alignment from the right edge of the parent.
    ///
    /// - Parameters:
    ///   - layoutDirection: The layout direction to apply.
    ///   - parentSize: The size of the parent container.
    package mutating func finalizeLayoutDirection(_ layoutDirection: LayoutDirection, parentSize: CGSize) {
        guard layoutDirection == .rightToLeft else { return }
        origin.x = parentSize.width - frame.maxX
    }
}
