//
//  Layout.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 57DDCF0A00C1B77B475771403C904EF9 (SwiftUICore)

#if canImport(Darwin)
public import CoreGraphics
#endif
public import Foundation
package import OpenGraphShims

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

// MARK: - LayoutSubviews

/// A collection of proxy values that represent the subviews of a layout view.
///
/// You receive a `LayoutSubviews` input to your implementations of
/// ``Layout`` protocol methods, like
/// ``Layout/placeSubviews(in:proposal:subviews:cache:)`` and
/// ``Layout/sizeThatFits(proposal:subviews:cache:)``. The `subviews`
/// parameter (which the protocol aliases to the ``Layout/Subviews`` type)
/// is a collection that contains proxies for the layout's subviews (of type
/// ``LayoutSubview``). The proxies appear in the collection in the same
/// order that they appear in the ``ViewBuilder`` input to the layout
/// container. Use the proxies to perform layout operations.
///
/// Access the proxies in the collection as you would the contents of any
/// Swift random-access collection. For example, you can enumerate all of the
/// subviews and their indices to inspect or operate on them:
///
///     for (index, subview) in subviews.enumerated() {
///         // ...
///     }
///
public struct LayoutSubviews: Equatable, RandomAccessCollection, Sendable {
    /// A type that contains a subsequence of proxy values.
    public typealias SubSequence = LayoutSubviews

    /// A type that contains a proxy value.
    public typealias Element = LayoutSubview

    /// A type that you can use to index proxy values.
    public typealias Index = Int

    var context: AnyRuleContext

    private enum Storage: Equatable {
        case direct([LayoutProxyAttributes])
        case indirect([IndexedAttributes])

        struct IndexedAttributes: Equatable {
            var attributes: LayoutProxyAttributes
            var index: Int32
        }

        @inline(__always)
        var count: Int {
            switch self {
            case let .direct(attributes): attributes.count
            case let .indirect(indexedAttributes): indexedAttributes.count
            }
        }
    }

    private var storage: Storage

    /// The layout direction inherited by the container view.
    ///
    /// OpenSwiftUI supports both left-to-right and right-to-left directions.
    /// Read this property within a custom layout container
    /// to find out which environment the container is in.
    ///
    /// In most cases, you don't need to take any action based on this
    /// value. OpenSwiftUI horizontally flips the x position of each view within its
    /// parent when the mode switches, so layout calculations automatically
    /// produce the desired effect for both directions.
    public var layoutDirection: LayoutDirection

    /// The index of the first subview.
    public var startIndex: Int { .zero }

    /// An index that's one higher than the last subview.
    public var endIndex: Int { storage.count  }

    /// Gets the subview proxy at a specified index.
    public subscript(index: Int) -> LayoutSubview {
        switch storage {
        case let .direct(attributes):
            let attributes = attributes[index]
            return LayoutSubview(
                proxy: LayoutProxy(context: context, attributes: attributes),
                index: Int32(truncatingIfNeeded: index),
                containerLayoutDirection: layoutDirection
            )
        case let .indirect(indexedAttributes):
            let indexedAttribute = indexedAttributes[index]
            return LayoutSubview(
                proxy: LayoutProxy(context: context, attributes: indexedAttribute.attributes),
                index: indexedAttribute.index,
                containerLayoutDirection: layoutDirection
            )
        }
    }

    /// Gets the subview proxies in the specified range.
    public subscript(bounds: Range<Int>) -> LayoutSubviews {
        selecting(indices: indices)
    }

    /// Gets the subview proxies with the specified indicies.
    public subscript<S>(indices: S) -> LayoutSubviews where S: Sequence, S.Element == Int {
        selecting(indices: indices)
    }

    func selecting<S>(indices: S) -> LayoutSubviews where S: Sequence, S.Element == Int {
        let indexedAttribute = indices.map { index in
            switch storage {
            case let .direct(attributes):
                return Storage.IndexedAttributes(
                    attributes: attributes[index],
                    index: Int32(truncatingIfNeeded: index)
                )
            case let .indirect(indexedAttributes):
                return indexedAttributes[index]
            }
        }
        return LayoutSubviews(
            context: context,
            storage: .indirect(indexedAttribute),
            layoutDirection: layoutDirection
        )
    }
}

// MARK: - LayoutSubview [WIP]

/// A proxy that represents one subview of a layout.
///
/// This type acts as a proxy for a view that your custom layout container
/// places in the user interface. ``Layout`` protocol methods
/// receive a ``LayoutSubviews`` collection that contains exactly one
/// proxy for each of the subviews arranged by your container.
///
/// Use a proxy to get information about the associated subview, like its
/// dimensions, layout priority, or custom layout values. You also use the
/// proxy to tell its corresponding subview where to appear by calling the
/// proxy's ``LayoutSubview/place(at:anchor:proposal:)`` method.
/// Do this once for each subview from your implementation of the layout's
/// ``Layout/placeSubviews(in:proposal:subviews:cache:)`` method.
///
/// You can read custom layout values associated with a subview
/// by using the property's key as an index on the subview. For more
/// information about defining, setting, and reading custom values,
/// see ``LayoutValueKey``.
public struct LayoutSubview: Equatable {
    package let proxy: LayoutProxy

    let index: Int32

    let containerLayoutDirection: LayoutDirection

    public func _trait<K>(key: K.Type) -> K.Value where K: _ViewTraitKey {
        proxy[key]
    }

    /// Gets the value for the subview that's associated with the specified key.
    ///
    /// If you define a custom layout value using ``LayoutValueKey``,
    /// you can read the key's associated value for a given subview in
    /// a layout container by indexing the container's subviews with
    /// the key type. For example, if you define a `Flexibility` key
    /// type, you can put the associated values of all the layout's
    /// subviews into an array:
    ///
    ///     let flexibilities = subviews.map { subview in
    ///         subview[Flexibility.self]
    ///     }
    ///
    /// For more information about creating a custom layout, see ``Layout``.
    public subscript<K>(key: K.Type) -> K.Value where K: LayoutValueKey {
        proxy[_LayoutTrait<K>.self]
    }

    /// The layout priority of the subview.
    ///
    /// If you define a custom layout type using the ``Layout``
    /// protocol, you can read this value from subviews and use the value
    /// when deciding how to assign space to subviews. For example, you
    /// can read all of the subview priorities into an array before
    /// placing the subviews in a custom layout type called `BasicVStack`:
    ///
    ///     extension BasicVStack {
    ///         func placeSubviews(
    ///             in bounds: CGRect,
    ///             proposal: ProposedViewSize,
    ///             subviews: Subviews,
    ///             cache: inout ()
    ///         ) {
    ///             let priorities = subviews.map { subview in
    ///                 subview.priority
    ///             }
    ///
    ///             // Place views, based on priorities.
    ///         }
    ///     }
    ///
    /// Set the layout priority for a view that appears in your layout by
    /// applying the ``View/layoutPriority(_:)`` view modifier. For example,
    /// you can assign two different priorities to views that you arrange
    /// with `BasicVStack`:
    ///
    ///     BasicVStack {
    ///         Text("High priority")
    ///             .layoutPriority(10)
    ///         Text("Low priority")
    ///             .layoutPriority(1)
    ///     }
    ///
    public var priority: Double {
        proxy.layoutPriority
    }

    /// Asks the subview for its size.
    ///
    /// Use this method as a convenience to get the ``ViewDimensions/width``
    /// and ``ViewDimensions/height`` properties of the ``ViewDimensions``
    /// instance returned by the ``dimensions(in:)`` method, reported as a
    /// [CGSize](https://developer.apple.com/documentation/CoreFoundation/CGSize)
    /// instance.
    ///
    /// - Parameter proposal: A proposed size for the subview. In SwiftUI,
    ///   views choose their own size, but can take a size proposal from
    ///   their parent view into account when doing so.
    ///
    /// - Returns: The size that the subview chooses for itself, given the
    ///   proposal from its container view.
    public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        proxy.size(in: .init(proposal))
    }

    package func lengthThatFits(_ proposal: ProposedViewSize, in axis: Axis) -> CGFloat {
        proxy.lengthThatFits(.init(proposal), in: axis)
    }

    /// Asks the subview for its dimensions and alignment guides.
    ///
    /// Call this method to ask a subview of a custom ``Layout`` type
    /// about its size and alignment properties. You can call it from
    /// your implementation of any of that protocol's methods, like
    /// ``Layout/placeSubviews(in:proposal:subviews:cache:)`` or
    /// ``Layout/sizeThatFits(proposal:subviews:cache:)``, to get
    /// information for your layout calculations.
    ///
    /// When you call this method, you propose a size using the `proposal`
    /// parameter. The subview can choose its own size, but might take the
    /// proposal into account. You can call this method more than
    /// once with different proposals to find out if the view is flexible.
    /// For example, you can propose:
    ///
    /// * ``ProposedViewSize/zero`` to get the subview's minimum size.
    /// * ``ProposedViewSize/infinity`` to get the subview's maximum size.
    /// * ``ProposedViewSize/unspecified`` to get the subview's ideal size.
    ///
    /// If you need only the view's height and width, you can use the
    /// ``sizeThatFits(_:)`` method instead.
    ///
    /// - Parameter proposal: A proposed size for the subview. In OpenSwiftUI,
    ///   views choose their own size, but can take a size proposal from
    ///   their parent view into account when doing so.
    ///
    /// - Returns: A ``ViewDimensions`` instance that includes a height
    ///   and width, as well as a set of alignment guides.
    public func dimensions(in proposal: ProposedViewSize) -> ViewDimensions {
        proxy.dimensions(in: .init(proposal))
    }

    /// The subviews's preferred spacing values.
    ///
    /// This ``ViewSpacing`` instance indicates how much space a subview
    /// in a custom layout prefers to have between it and the next view.
    /// It contains preferences for all edges, and might take into account
    /// the type of both this and the adjacent view. If your ``Layout`` type
    /// places subviews based on spacing preferences, use this instance
    /// to compute a distance between this subview and the next. See
    /// ``Layout/placeSubviews(in:proposal:subviews:cache:)`` for an
    /// example.
    ///
    /// You can also merge this instance with instances from other subviews
    /// to construct a new instance that's suitable for the subviews' container.
    /// See ``Layout/spacing(subviews:cache:)``.
    public var spacing: ViewSpacing {
        ViewSpacing(proxy.spacing())
    }

    /// Assigns a position and proposed size to the subview.
    ///
    /// Call this method from your implementation of the ``Layout``
    /// protocol's ``Layout/placeSubviews(in:proposal:subviews:cache:)``
    /// method for each subview arranged by the layout.
    /// Provide a position within the container's bounds where the subview
    /// should appear, and an anchor that indicates which part of the subview
    /// appears at that point.
    ///
    /// Include a proposed size that the subview can take into account when
    /// sizing itself. To learn the subview's size for a given proposal before
    /// calling this method, you can call the ``dimensions(in:)`` or
    /// ``sizeThatFits(_:)`` method on the subview with the same proposal.
    /// That enables you to know subview sizes before committing to subview
    /// positions.
    ///
    /// > Important: Call this method only from within your
    ///   ``Layout`` type's implementation of the
    /// ``Layout/placeSubviews(in:proposal:subviews:cache:)`` method.
    ///
    /// If you call this method more than once for a subview, the last call
    /// takes precedence. If you don't call this method for a subview, the
    /// subview appears at the center of its layout container and uses the
    /// layout container's size proposal.
    ///
    /// - Parameters:
    ///   - position: The place where the anchor of the subview should
    ///     appear in its container view, relative to container's bounds.
    ///   - anchor: The unit point on the subview that appears at `position`.
    ///     You can use a built-in point, like ``UnitPoint/center``, or
    ///     you can create a custom ``UnitPoint``.
    ///   - proposal: A proposed size for the subview. In OpenSwiftUI,
    ///     views choose their own size, but can take a size proposal from
    ///     their parent view into account when doing so.
    public func place(at position: CGPoint, anchor: UnitPoint = .topLeading, proposal: ProposedViewSize) {
        place(at: position, anchor: anchor, dimensions: dimensions(in: proposal))
    }

    package func place(at position: CGPoint, anchor: UnitPoint = .topLeading, dimensions: ViewDimensions) {
        preconditionFailure("TODO")
    }

    package func place(in geometry: ViewGeometry, layoutDirection: LayoutDirection = .leftToRight) {
        preconditionFailure("TODO")
    }
}

@available(*, unavailable)
extension LayoutSubview: Sendable {}

// MARK: - LayoutValueKey

/// A key for accessing a layout value of a layout container's subviews.
///
/// If you create a custom layout by defining a type that conforms to the
/// ``Layout`` protocol, you can also create custom layout values
/// that you set on individual views, and that your container view can access
/// to guide its layout behavior. Your custom values resemble
/// the built-in layout values that you set with view modifiers
/// like ``View/layoutPriority(_:)`` and ``View/zIndex(_:)``, but have a
/// purpose that you define.
///
/// To create a custom layout value, define a type that conforms to the
/// `LayoutValueKey` protocol and implement the one required property that
/// returns the default value of the property. For example, you can create
/// a property that defines an amount of flexibility for a view, defined as
/// an optional floating point number with a default value of `nil`:
///
///     private struct Flexibility: LayoutValueKey {
///         static let defaultValue: CGFloat? = nil
///     }
///
/// The Swift compiler infers this particular key's associated type as an
/// optional [CGFloat](https://developer.apple.com/documentation/corefoundation/cgfloat-swift.struct)
/// from this definition.
///
/// ### Set a value on a view
///
/// Set the value on a view by adding the ``View/layoutValue(key:value:)``
/// view modifier to the view. To make your custom value easier to work
/// with, you can do this in a convenience modifier in an extension of the
/// ``View`` protocol:
///
///     extension View {
///         func layoutFlexibility(_ value: CGFloat?) -> some View {
///             layoutValue(key: Flexibility.self, value: value)
///         }
///     }
///
/// Use your modifier to set the value on any views that need a nondefault
/// value:
///
///     BasicVStack {
///         Text("One View")
///         Text("Another View")
///             .layoutFlexibility(3)
///     }
///
/// Any view that you don't explicitly set a value for uses the default
/// value, as with the first ``Text`` view, above.
///
/// ### Retrieve a value during layout
///
/// Access a custom layout value using the key as an index
/// on subview's proxy (an instance of ``LayoutSubview``)
/// and use the value to make decisions about sizing, placement, or other
/// layout operations. For example, you might read the flexibility value
/// in your layout view's ``LayoutSubview/sizeThatFits(_:)`` method, and
/// adjust your size calculations accordingly:
///
///     extension BasicVStack {
///         func sizeThatFits(
///             proposal: ProposedViewSize,
///             subviews: Subviews,
///             cache: inout Void
///         ) -> CGSize {
///
///             // Map the flexibility property of each subview into an array.
///             let flexibilities = subviews.map { subview in
///                 subview[Flexibility.self]
///             }
///
///             // Calculate and return the size of the layout container.
///             // ...
///         }
///     }
///
public protocol LayoutValueKey {
    /// The type of the key's value.
    ///
    /// Swift typically infers this type from your implementation of the
    /// ``defaultValue`` property, so you don't have to define it explicitly.
    associatedtype Value

    /// The default value of the key.
    ///
    /// Implement the `defaultValue` property for a type that conforms to the
    /// ``LayoutValueKey`` protocol. For example, you can create a `Flexibility`
    /// layout value that defaults to `nil`:
    ///
    ///     private struct Flexibility: LayoutValueKey {
    ///         static let defaultValue: CGFloat? = nil
    ///     }
    ///
    /// The type that you declare for the `defaultValue` sets the layout
    /// key's ``Value`` associated type. The Swift compiler infers the key's
    /// associated type in the above example as an optional
    /// [CGFloat](https://developer.apple.com/documentation/corefoundation/cgfloat-swift.struct)
    ///
    /// Any view that you don't explicitly set a value for uses the default
    /// value. Override the default value for a view using the
    /// ``View/layoutValue(key:value:)`` modifier.
    static var defaultValue: Value { get }
}

extension View {
    /// Associates a value with a custom layout property.
    ///
    /// Use this method to set a value for a custom property that
    /// you define with ``LayoutValueKey``. For example, if you define
    /// a `Flexibility` key, you can set the key on a ``Text`` view
    /// using the key's type and a value:
    ///
    ///     Text("Another View")
    ///         .layoutValue(key: Flexibility.self, value: 3)
    ///
    /// For convenience, you might define a method that does this in an
    /// extension to ``View``:
    ///
    ///     extension View {
    ///         func layoutFlexibility(_ value: CGFloat?) -> some View {
    ///             layoutValue(key: Flexibility.self, value: value)
    ///         }
    ///     }
    ///
    /// This method makes the call site easier to read:
    ///
    ///     Text("Another View")
    ///         .layoutFlexibility(3)
    ///
    /// If you perform layout operations in a type that conforms to the
    /// ``Layout`` protocol, you can read the key's associated value for
    /// each subview of your custom layout type. Do this by indexing the
    /// subview's proxy with the key. For more information, see
    /// ``LayoutValueKey``.
    ///
    /// - Parameters:
    ///   - key: The type of the key that you want to set a value for.
    ///     Create the key as a type that conforms to the ``LayoutValueKey``
    ///     protocol.
    ///   - value: The value to assign to the key for this view.
    ///     The value must be of the type that you establish for the key's
    ///     associated value when you implement the key's
    ///     ``LayoutValueKey/defaultValue`` property.
    ///
    /// - Returns: A view that has the specified value for the specified key.
    @inlinable
    nonisolated public func layoutValue<K>(key: K.Type, value: K.Value) -> some View where K: LayoutValueKey {
        return _trait(_LayoutTrait<K>.self, value)
    }
}

// MARK: - LayoutTrait

public struct _LayoutTrait<K>: _ViewTraitKey where K: LayoutValueKey {
    public static var defaultValue: K.Value { K.defaultValue }
}

@available(*, unavailable)
extension _LayoutTrait: Sendable {}
