//
//  Layout.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 57DDCF0A00C1B77B475771403C904EF9 (SwiftUICore)

public import Foundation
#if canImport(Darwin)
public import CoreGraphics
#endif

// MARK: - LayoutProperties

/// Layout-specific properties of a layout container.
///
/// This structure contains configuration information that's
/// applicable to a layout container. For example, the ``stackOrientation``
/// value indicates the layout's primary axis, if any.
///
/// You can use an instance of this type to characterize a custom layout
/// container, which is a type that conforms to the ``Layout`` protocol.
/// Implement the protocol's ``Layout/layoutProperties-5rb5b`` property
/// to return an instance. For example, you can indicate that your layout
/// has a vertical stack orientation:
///
///     extension BasicVStack {
///         static var layoutProperties: LayoutProperties {
///             var properties = LayoutProperties()
///             properties.stackOrientation = .vertical
///             return properties
///         }
///     }
///
/// If you don't implement the property in your custom layout, the protocol
/// provides a default implementation that returns a `LayoutProperties`
/// instance with default values.
public struct LayoutProperties: Sendable {
    /// Creates a default set of properties.
    ///
    /// Use a layout properties instance to provide information about
    /// a type that conforms to the ``Layout`` protocol. For example, you
    /// can create a layout properties instance in your layout's implementation
    /// of the ``Layout/layoutProperties-5rb5b`` method, and use it to
    /// indicate that the layout has a ``Axis/vertical`` orientation:
    ///
    ///     extension BasicVStack {
    ///         static var layoutProperties: LayoutProperties {
    ///             var properties = LayoutProperties()
    ///             properties.stackOrientation = .vertical
    ///             return properties
    ///         }
    ///     }
    ///
    public init() {}

    /// The orientation of the containing stack-like container.
    ///
    /// Certain views alter their behavior based on the stack orientation
    /// of the container that they appear in. For example, ``Spacer`` and
    /// ``Divider`` align their major axis to match that of their container.
    ///
    /// Set the orientation for your custom layout container by returning a
    /// configured ``LayoutProperties`` instance from your ``Layout``
    /// type's implementation of the ``Layout/layoutProperties-5rb5b``
    /// method. For example, you can indicate that your layout has a
    /// ``Axis/vertical`` major axis:
    ///
    ///     extension BasicVStack {
    ///         static var layoutProperties: LayoutProperties {
    ///             var properties = LayoutProperties()
    ///             properties.stackOrientation = .vertical
    ///             return properties
    ///         }
    ///     }
    ///
    /// A value of `nil`, which is the default when you don't specify a
    /// value, indicates an unknown orientation, or that a layout isn't
    /// one-dimensional.
    public var stackOrientation: Axis?

    package var isDefaultEmptyLayout: Bool = false

    package var isIdentityUnaryLayout: Bool = false
}

// MARK: - ProposedViewSize

/// A proposal for the size of a view.
///
/// During layout in OpenSwiftUI, views choose their own size, but they do that
/// in response to a size proposal from their parent view. When you create
/// a custom layout using the ``Layout`` protocol, your layout container
/// participates in this process using `ProposedViewSize` instances.
/// The layout protocol's methods take a proposed size input that you
/// can take into account when arranging views and calculating the size of
/// the composite container. Similarly, your layout proposes a size to each
/// of its own subviews when it measures and places them.
///
/// Layout containers typically measure their subviews by proposing several
/// sizes and looking at the responses. The container can use this information
/// to decide how to allocate space among its subviews. A
/// layout might try the following special proposals:
///
/// * The ``zero`` proposal; the view responds with its minimum size.
/// * The ``infinity`` proposal; the view responds with its maximum size.
/// * The ``unspecified`` proposal; the view responds with its ideal size.
///
/// A layout might also try special cases for one dimension at a time. For
/// example, an ``HStack`` might measure the flexibility of its subviews'
/// widths, while using a fixed value for the height.
@frozen
public struct ProposedViewSize: Equatable {
    /// The proposed horizontal size measured in points.
    ///
    /// A value of `nil` represents an unspecified width proposal, which a view
    /// interprets to mean that it should use its ideal width.
    public var width: CGFloat?

    /// The proposed vertical size measured in points.
    ///
    /// A value of `nil` represents an unspecified height proposal, which a view
    /// interprets to mean that it should use its ideal height.
    public var height: CGFloat?

    /// A size proposal that contains zero in both dimensions.
    ///
    /// Subviews of a custom layout return their minimum size when you propose
    /// this value using the ``LayoutSubview/dimensions(in:)`` method.
    /// A custom layout should also return its minimum size from the
    /// ``Layout/sizeThatFits(proposal:subviews:cache:)`` method for this
    /// value.
    public static let zero: ProposedViewSize = .init(width: .zero, height: .zero)

    /// The proposed size with both dimensions left unspecified.
    ///
    /// Both dimensions contain `nil` in this size proposal.
    /// Subviews of a custom layout return their ideal size when you propose
    /// this value using the ``LayoutSubview/dimensions(in:)`` method.
    /// A custom layout should also return its ideal size from the
    /// ``Layout/sizeThatFits(proposal:subviews:cache:)`` method for this
    /// value.
    public static let unspecified: ProposedViewSize = .init(width: nil, height: nil)

    /// A size proposal that contains infinity in both dimensions.
    ///
    /// Both dimensions contain
    /// [infinity](https://developer.apple.com/documentation/CoreFoundation/CGFloat/1454161-infinity)
    /// in this size proposal.
    /// Subviews of a custom layout return their maximum size when you propose
    /// this value using the ``LayoutSubview/dimensions(in:)`` method.
    /// A custom layout should also return its maximum size from the
    /// ``Layout/sizeThatFits(proposal:subviews:cache:)`` method for this
    /// value.
    public static let infinity: ProposedViewSize = .init(width: .infinity, height: .infinity)

    /// Creates a new proposed size using the specified width and height.
    ///
    /// - Parameters:
    ///   - width: A proposed width in points. Use a value of `nil` to indicate
    ///     that the width is unspecified for this proposal.
    ///   - height: A proposed height in points. Use a value of `nil` to
    ///     indicate that the height is unspecified for this proposal.
    @inlinable
    public init(width: CGFloat?, height: CGFloat?) {
        (self.width, self.height) = (width, height)
    }

    package init(_ proposal: _ProposedSize) {
        width = proposal.width
        height = proposal.height
    }

    /// Creates a new proposed size from a specified size.
    ///
    /// - Parameter size: A proposed size with dimensions measured in points.
    @inlinable
    public init(_ size: CGSize) {
        self.init(width: size.width, height: size.height)
    }

    /// Creates a new proposal that replaces unspecified dimensions in this
    /// proposal with the corresponding dimension of the specified size.
    ///
    /// Use the default value to prevent a flexible view from disappearing
    /// into a zero-sized frame, and ensure the unspecified value remains
    /// visible during debugging.
    ///
    /// - Parameter size: A set of concrete values to use for the size proposal
    ///   in place of any unspecified dimensions. The default value is `10`
    ///   for both dimensions.
    ///
    /// - Returns: A new, fully specified size proposal.
    @inlinable
    public func replacingUnspecifiedDimensions(by size: CGSize = CGSize(width: 10, height: 10)) -> CGSize {
        CGSize(width: width ?? size.width, height: height ?? size.height)
    }

    package init(_ major: CGFloat?, in axis: Axis, by minor: CGFloat?) {
        self = axis == .horizontal ? ProposedViewSize(width: major, height: minor) : ProposedViewSize(width: minor, height: major)
    }

    package subscript(axis: Axis) -> CGFloat? {
        get { axis == .horizontal ? width : height }
        set { if axis == .horizontal { width = newValue } else { height = newValue } }
    }
}

extension _ProposedSize {
    package init(_ p: ProposedViewSize) {
        self.init(width: p.width, height: p.height)
    }
}

// MARK: - ViewSpacing

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
        spacing.incorporate(
            AbsoluteEdge.Set(edges, layoutDirection: layoutDirection ?? .leftToRight),
            of: other.spacing
        )
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
        guard let distance = spacing.distanceToSuccessorView(
            along: axis,
            layoutDirection: layoutDirection ?? .leftToRight,
            preferring: next.spacing
        ) else {
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
