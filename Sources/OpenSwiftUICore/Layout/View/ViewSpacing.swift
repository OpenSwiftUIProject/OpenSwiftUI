//
//  ViewSpacing.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import Foundation

/// A collection of the geometric spacing preferences of a view.
///
/// This type represents how much space a view prefers to have between it and
/// the next view in a layout. The type stores independent values
/// for each of the top, bottom, leading, and trailing edges,
/// and can also record different values for different kinds of adjacent
/// views. For example, it might contain one value for the spacing to the next
/// text view along the top and bottom edges, other values for the spacing to
/// text views on other edges, and yet other values for other kinds of views.
/// Spacing preferences can also vary by platform.
///
/// Your ``Layout`` type doesn't have to take preferred spacing into
/// account, but if it does, you can use the ``LayoutSubview/spacing``
/// preferences of the subviews in your layout container to:
///
/// * Add space between subviews when you implement the
///   ``Layout/placeSubviews(in:proposal:subviews:cache:)`` method.
/// * Create a spacing preferences instance for the container view by
///   implementing the ``Layout/spacing(subviews:cache:)`` method.
public struct ViewSpacing: Sendable {
    /// The underlying spacing implementation that stores the actual spacing values
    /// for each edge and direction.
    package var spacing: Spacing

    /// The layout direction used to resolve relative edges (leading/trailing)
    /// to absolute edges (left/right).
    var layoutDirection: LayoutDirection?

    /// Creates a new ViewSpacing instance with the specified spacing values.
    ///
    /// - Parameter spacing: The spacing implementation to use.
    package init(_ spacing: Spacing) {
        self.spacing = spacing
        self.layoutDirection = nil
    }

    /// Creates a new ViewSpacing instance with the specified spacing values and layout direction.
    ///
    /// - Parameters:
    ///   - spacing: The spacing implementation to use.
    ///   - layoutDirection: The layout direction to use when resolving relative edges.
    package init(_ spacing: Spacing, layoutDirection: LayoutDirection) {
        self.spacing = spacing
        self.layoutDirection = layoutDirection
    }

    /// A view spacing instance that contains zero on all edges.
    ///
    /// You typically only use this value for an empty view.
    public static let zero: ViewSpacing = ViewSpacing(.zero)

    /// Initializes an instance with default spacing values.
    ///
    /// Use this initializer to create a spacing preferences instance with
    /// default values. Then use ``formUnion(_:edges:)`` to combine
    /// preferences from other views with the new instance. You typically
    /// do this in a custom layout's implementation of the
    /// ``Layout/spacing(subviews:cache:)`` method.
    public init() {
        self.spacing = Spacing(minima: [:])
        self.layoutDirection = nil
    }

    /// Merges the spacing preferences of another spacing instance with this
    /// instance for a specified set of edges.
    ///
    /// When you merge another spacing preference instance with this one,
    /// this instance ends up with the greater of its original value or the
    /// other instance's value for each of the specified edges.
    /// You can call the method repeatedly with each value in a collection to
    /// merge a collection of preferences. The result has the smallest
    /// preferences on each edge that meets the largest requirements of all
    /// the inputs for that edge.
    ///
    /// If you want to merge preferences without modifying the original
    /// instance, use ``union(_:edges:)`` instead.
    ///
    /// - Parameters:
    ///   - other: Another spacing preferences instances to merge with this one.
    ///   - edges: The edges to merge. Edges that you don't specify are
    ///     unchanged after the method completes.
    public mutating func formUnion(_ other: ViewSpacing, edges: Edge.Set = .all) {
        let layoutDirection = layoutDirection ?? other.layoutDirection
        self.layoutDirection = layoutDirection
        spacing.incorporate(AbsoluteEdge.Set(edges, layoutDirection: layoutDirection ?? .leftToRight), of: other.spacing)
    }

    /// Gets a new value that merges the spacing preferences of another spacing
    /// instance with this instance for a specified set of edges.
    ///
    /// This method behaves like ``formUnion(_:edges:)``, except that it creates
    /// a copy of the original spacing preferences instance before merging,
    /// leaving the original instance unmodified.
    ///
    /// - Parameters:
    ///   - other: Another spacing preferences instance to merge with this one.
    ///   - edges: The edges to merge. Edges that you don't specify are
    ///     unchanged after the method completes.
    ///
    /// - Returns: A new view spacing preferences instance with the merged
    ///   values.
    public func union(_ other: ViewSpacing, edges: Edge.Set = .all) -> ViewSpacing {
        var copy = self
        copy.formUnion(other, edges: edges)
        return copy
    }

    /// Gets the preferred spacing distance along the specified axis to the view
    /// that returns a specified spacing preference.
    ///
    /// Call this method from your implementation of ``Layout`` protocol
    /// methods if you need to measure the default spacing between two
    /// views in a custom layout. Call the method on the first view's
    /// preferences instance, and provide the second view's preferences
    /// instance as input.
    ///
    /// For example, consider two views that appear in a custom horizontal
    /// stack. The following distance call gets the preferred spacing between
    /// these views, where `spacing1` contains the preferences of a first
    /// view, and `spacing2` contains the preferences of a second view:
    ///
    ///     let distance = spacing1.distance(to: spacing2, axis: .horizontal)
    ///
    /// The method first determines, based on the axis and the ordering, that
    /// the views abut on the trailing edge of the first view and the leading
    /// edge of the second. It then gets the spacing preferences for the
    /// corresponding edges of each view, and returns the greater of the two
    /// values. This results in the smallest value that provides enough space
    /// to satisfy the preferences of both views.
    ///
    /// > Note: This method returns the default spacing between views, but a
    /// layout can choose to ignore the value and use custom spacing instead.
    ///
    /// - Parameters:
    ///   - next: The spacing preferences instance of the adjacent view.
    ///   - axis: The axis that the two views align on.
    ///
    /// - Returns: A floating point value that represents the smallest distance
    ///   in points between two views that satisfies the spacing preferences
    ///   of both this view and the adjacent views on their shared edge.
    public func distance(to next: ViewSpacing, along axis: Axis) -> CGFloat {
        guard let distance = spacing.distanceToSuccessorView(along: axis, layoutDirection: layoutDirection ?? .leftToRight, preferring: next.spacing) else {
            let defaultSpacingValue = defaultSpacingValue
            return axis == .horizontal ? defaultSpacingValue.width : defaultSpacingValue.height
        }
        return distance
    }
}

@_spi(ForOpenSwiftUIOnly)
extension ViewSpacing: CustomStringConvertible {
    public var description: String {
        spacing.description
    }
}
