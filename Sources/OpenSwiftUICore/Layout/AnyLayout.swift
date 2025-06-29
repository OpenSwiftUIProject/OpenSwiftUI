//
//  AnyLayout.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: D2D36AB6EC54BD879A165F3510222DD0 (SwiftUICore)

public import Foundation

// MARK: - AnyLayout

/// A type-erased instance of the layout protocol.
///
/// Use an `AnyLayout` instance to enable dynamically changing the
/// type of a layout container without destroying the state of the subviews.
/// For example, you can create a layout that changes between horizontal and
/// vertical layouts based on the current Dynamic Type setting:
///
///     struct DynamicLayoutExample: View {
///         @Environment(\.dynamicTypeSize) var dynamicTypeSize
///
///         var body: some View {
///             let layout = dynamicTypeSize <= .medium ?
///                 AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())
///
///             layout {
///                 Text("First label")
///                 Text("Second label")
///             }
///         }
///     }
///
/// The types that you use with `AnyLayout` must conform to the ``Layout``
/// protocol. The above example chooses between the ``HStackLayout`` and
/// ``VStackLayout`` types, which are versions of the built-in ``HStack``
/// and ``VStack`` containers that conform to the protocol. You can also
/// use custom layout types that you define.
@frozen
public struct AnyLayout: Layout {
    var storage: AnyLayoutBox

    /// Creates a type-erased value that wraps the specified layout.
    ///
    /// You can switch between type-erased layouts without losing the state
    /// of the subviews.
    public init<L>(_ layout: L) where L: Layout {
        storage = _AnyLayoutBox(layout: layout)
    }

    /// Cached values associated with the layout instance.
    ///
    /// If you create a cache for your custom layout, you can use
    /// a type alias to define this type as your data storage type.
    /// Alternatively, you can refer to the data storage type directly in all
    /// the places where you work with the cache.
    ///
    /// See ``makeCache(subviews:)`` for more information.
    public struct Cache {
        var type: any Any.Type
        var value: Any
    }

    public typealias AnimatableData = _AnyAnimatableData

    /// Creates and initializes a cache for a layout instance.
    ///
    /// You can optionally use a cache to preserve calculated values across
    /// calls to a layout container's methods. Many layout types don't need
    /// a cache, because OpenSwiftUI automatically reuses both the results of
    /// calls into the layout and the values that the layout reads from its
    /// subviews. Rely on the protocol's default implementation of this method
    /// if you don't need a cache.
    ///
    /// However you might find a cache useful when:
    ///
    /// - The layout container repeats complex, intermediate calculations
    /// across calls like ``sizeThatFits(proposal:subviews:cache:)``,
    /// ``placeSubviews(in:proposal:subviews:cache:)``, and
    /// ``explicitAlignment(of:in:proposal:subviews:cache:)``.
    /// You might be able to improve performance by calculating values
    /// once and storing them in a cache.
    /// - The layout container reads many ``LayoutValueKey`` values from
    /// subviews. It might be more efficient to do that once and store the
    /// results in the cache, rather than rereading the subviews' values before
    /// each layout call.
    /// - You want to maintain working storage, like temporary Swift arrays,
    /// across calls into the layout, to minimize the number of allocation
    /// events.
    ///
    /// Only implement a cache if profiling shows that it improves performance.
    ///
    /// ### Initialize a cache
    ///
    /// Implement the `makeCache(subviews:)` method to create a cache.
    /// You can add computed values to the cache right away, using information
    /// from the `subviews` input parameter, or you can do that later. The
    /// methods of the ``Layout`` protocol that can access the cache
    /// take the cache as an in-out parameter, which enables you to modify
    /// the cache anywhere that you can read it.
    ///
    /// You can use any storage type that makes sense for your layout
    /// algorithm, but be sure that you only store data that you derive
    /// from the layout and its subviews (lazily, if possible). For this to
    /// work correctly, OpenSwiftUI needs to be able to call this method to
    /// recreate the cache without changing the layout result.
    ///
    /// When you return a cache from this method, you implicitly define a type
    /// for your cache. Be sure to either make the type of the `cache`
    /// parameters on your other ``Layout`` protocol methods match, or use
    /// a type alias to define the ``Cache`` associated type.
    ///
    /// ### Update the cache
    ///
    /// If the layout container or any of its subviews change, OpenSwiftUI
    /// calls the ``updateCache(_:subviews:)`` method so you can
    /// modify or invalidate the contents of the
    /// cache. The default implementation of that method calls the
    /// `makeCache(subviews:)` method to recreate the cache, but you can
    /// provide your own implementation of the update method to take an
    /// incremental approach, if appropriate.
    ///
    /// - Parameters:
    ///   - subviews: A collection of proxy instances that represent the
    ///     views that the container arranges. You can use the proxies in the
    ///     collection to get information about the subviews as you
    ///     calculate values to store in the cache.
    ///
    /// - Returns: Storage for calculated data that you share among
    ///   the methods of your custom layout container.
    public func makeCache(subviews: AnyLayout.Subviews) -> AnyLayout.Cache {
        storage.makeCache(subviews: subviews)
    }

    /// Updates the layout's cache when something changes.
    ///
    /// If your custom layout container creates a cache by implementing the
    /// ``makeCache(subviews:)`` method, OpenSwiftUI calls the update method
    /// when your layout or its subviews change, giving you an opportunity
    /// to modify or invalidate the contents of the cache.
    /// The method's default implementation recreates the
    /// cache by calling the ``makeCache(subviews:)`` method,
    /// but you can provide your own implementation to take an
    /// incremental approach, if appropriate.
    ///
    /// - Parameters:
    ///   - cache: Storage for calculated data that you share among
    ///     the methods of your custom layout container.
    ///   - subviews: A collection of proxy instances that represent the
    ///     views arranged by the container. You can use the proxies in the
    ///     collection to get information about the subviews as you
    ///     calculate values to store in the cache.
    public func updateCache(_ cache: inout AnyLayout.Cache, subviews: AnyLayout.Subviews) {
        storage.updateCache(&cache, subviews: subviews)
    }

    /// Returns the preferred spacing values of the composite view.
    ///
    /// Implement this method to provide custom spacing preferences
    /// for a layout container. The value you return affects
    /// the spacing around the container, but it doesn't affect how the
    /// container arranges subviews relative to one another inside the
    /// container.
    ///
    /// Create a custom ``ViewSpacing`` instance for your container by
    /// initializing one with default values, and then merging that with
    /// spacing instances of certain subviews. For example, if you define
    /// a basic vertical stack that places subviews in a column, you could
    /// use the spacing preferences of the subview edges that make
    /// contact with the container's edges:
    ///
    ///     extension BasicVStack {
    ///         func spacing(subviews: Subviews, cache: inout ()) -> ViewSpacing {
    ///             var spacing = ViewSpacing()
    ///
    ///             for index in subviews.indices {
    ///                 var edges: Edge.Set = [.leading, .trailing]
    ///                 if index == 0 { edges.formUnion(.top) }
    ///                 if index == subviews.count - 1 { edges.formUnion(.bottom) }
    ///                 spacing.formUnion(subviews[index].spacing, edges: edges)
    ///             }
    ///
    ///             return spacing
    ///         }
    ///     }
    ///
    /// In the above example, the first and last subviews contribute to the
    /// spacing above and below the container, respectively, while all subviews
    /// affect the spacing on the leading and trailing edges.
    ///
    /// If you don't implement this method, the protocol provides a default
    /// implementation that merges the spacing preferences across all subviews on all edges.
    ///
    /// - Parameters:
    ///   - subviews: A collection of proxy instances that represent the
    ///     views that the container arranges. You can use the proxies in the
    ///     collection to get information about the subviews as you determine
    ///     how much spacing the container prefers around it.
    ///   - cache: Optional storage for calculated data that you can share among
    ///     the methods of your custom layout container. See
    ///     ``makeCache(subviews:)`` for details.
    ///
    /// - Returns: A ``ViewSpacing`` instance that describes the preferred
    ///   spacing around the container view.
    public func spacing(subviews: AnyLayout.Subviews, cache: inout AnyLayout.Cache) -> ViewSpacing {
        storage.spacing(subviews: subviews, cache: &cache)
    }

    /// Returns the size of the composite view, given a proposed size
    /// and the view's subviews.
    ///
    /// Implement this method to tell your custom layout container's parent
    /// view how much space the container needs for a set of subviews, given
    /// a size proposal. The parent might call this method more than once
    /// during a layout pass with different proposed sizes to test the
    /// flexibility of the container, using proposals like:
    ///
    /// * The ``ProposedViewSize/zero`` proposal; respond with the
    ///   layout's minimum size.
    /// * The ``ProposedViewSize/infinity`` proposal; respond with the
    ///   layout's maximum size.
    /// * The ``ProposedViewSize/unspecified`` proposal; respond with the
    ///   layout's ideal size.
    ///
    /// The parent might also choose to test flexibility in one dimension at a
    /// time. For example, a horizontal stack might propose a fixed height and
    /// an infinite width, and then the same height with a zero width.
    ///
    /// The following example calculates the size for a basic vertical stack
    /// that places views in a column, with no spacing between the views:
    ///
    ///     private struct BasicVStack: Layout {
    ///         func sizeThatFits(
    ///             proposal: ProposedViewSize,
    ///             subviews: Subviews,
    ///             cache: inout ()
    ///         ) -> CGSize {
    ///             subviews.reduce(CGSize.zero) { result, subview in
    ///                 let size = subview.sizeThatFits(.unspecified)
    ///                 return CGSize(
    ///                     width: max(result.width, size.width),
    ///                     height: result.height + size.height)
    ///             }
    ///         }
    ///
    ///         // This layout also needs a placeSubviews() implementation.
    ///     }
    ///
    /// The implementation asks each subview for its ideal size by calling the
    /// ``LayoutSubview/sizeThatFits(_:)`` method with an
    /// ``ProposedViewSize/unspecified`` proposed size.
    /// It then reduces these values into a single size that represents
    /// the maximum subview width and the sum of subview heights.
    /// Because this example isn't flexible, it ignores its size proposal
    /// input and always returns the same value for a given set of subviews.
    ///
    /// OpenSwiftUI views choose their own size, so the layout engine always
    /// uses a value that you return from this method as the actual size of the
    /// composite view. That size factors into the construction of the `bounds`
    /// input to the ``placeSubviews(in:proposal:subviews:cache:)`` method.
    ///
    /// - Parameters:
    ///   - proposal: A size proposal for the container. The container's parent
    ///     view that calls this method might call the method more than once
    ///     with different proposals to learn more about the container's
    ///     flexibility before deciding which proposal to use for placement.
    ///   - subviews: A collection of proxies that represent the
    ///     views that the container arranges. You can use the proxies in the
    ///     collection to get information about the subviews as you determine
    ///     how much space the container needs to display them.
    ///   - cache: Optional storage for calculated data that you can share among
    ///     the methods of your custom layout container. See
    ///     ``makeCache(subviews:)`` for details.
    ///
    /// - Returns: A size that indicates how much space the container
    ///   needs to arrange its subviews.
    public func sizeThatFits(proposal: ProposedViewSize, subviews: AnyLayout.Subviews, cache: inout AnyLayout.Cache) -> CGSize {
        storage.sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache)
    }

    /// Assigns positions to each of the layout's subviews.
    ///
    /// OpenSwiftUI calls your implementation of this method to tell your
    /// custom layout container to place its subviews. From this method, call
    /// the ``LayoutSubview/place(at:anchor:proposal:)`` method on each
    /// element in `subviews` to tell the subviews where to appear in the
    /// user interface.
    ///
    /// For example, you can create a basic vertical stack that places views
    /// in a column, with views horizontally aligned on their leading edge:
    ///
    ///     struct BasicVStack: Layout {
    ///         func placeSubviews(
    ///             in bounds: CGRect,
    ///             proposal: ProposedViewSize,
    ///             subviews: Subviews,
    ///             cache: inout ()
    ///         ) {
    ///             var point = bounds.origin
    ///             for subview in subviews {
    ///                 subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
    ///                 point.y += subview.dimensions(in: .unspecified).height
    ///             }
    ///         }
    ///
    ///         // This layout also needs a sizeThatFits() implementation.
    ///     }
    ///
    /// The example creates a placement point that starts at the origin of the
    /// specified `bounds` input and uses that to place the first subview. It
    /// then moves the point in the y dimension by the subview's height,
    /// which it reads using the ``LayoutSubview/dimensions(in:)`` method.
    /// This prepares the point for the next iteration of the loop. All
    /// subview operations use an ``ProposedViewSize/unspecified`` size
    /// proposal to indicate that subviews should use and report their ideal
    /// size.
    ///
    /// A more complex layout container might add space between subviews
    /// according to their ``LayoutSubview/spacing`` preferences, or a
    /// fixed space based on input configuration. For example, you can extend
    /// the basic vertical stack's placement method to calculate the
    /// preferred distances between adjacent subviews and store the results in
    /// an array:
    ///
    ///     let spacing: [CGFloat] = subviews.indices.dropLast().map { index in
    ///         subviews[index].spacing.distance(
    ///             to: subviews[index + 1].spacing,
    ///             along: .vertical)
    ///     }
    ///
    /// The spacing's ``ViewSpacing/distance(to:along:)`` method considers the
    /// preferences of adjacent views on the edge where they meet. It returns
    /// the smallest distance that satisfies both views' preferences for the
    /// given edge. For example, if one view prefers at least `2` points on its
    /// bottom edge, and the next view prefers at least `8` points on its top
    /// edge, the distance method returns `8`, because that's the smallest
    /// value that satisfies both preferences.
    ///
    /// Update the placement calculations to use the spacing values:
    ///
    ///     var point = bounds.origin
    ///     for (index, subview) in subviews.enumerated() {
    ///         if index > 0 { point.y += spacing[index - 1] } // Add spacing.
    ///         subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
    ///         point.y += subview.dimensions(in: .unspecified).height
    ///     }
    ///
    /// Be sure that you use computations during placement that are consistent
    /// with those in your implementation of other protocol methods for a given
    /// set of inputs. For example, if you add spacing during placement,
    /// make sure your implementation of
    /// ``sizeThatFits(proposal:subviews:cache:)`` accounts for the extra space.
    /// Similarly, if the sizing method returns different values for different
    /// size proposals, make sure the placement method responds to its
    /// `proposal` input in the same way.
    ///
    /// - Parameters:
    ///   - bounds: The region that the container view's parent allocates to the
    ///     container view, specified in the parent's coordinate space.
    ///     Place all the container's subviews within the region.
    ///     The size of this region matches a size that your container
    ///     previously returned from a call to the
    ///     ``sizeThatFits(proposal:subviews:cache:)`` method.
    ///   - proposal: The size proposal from which the container generated the
    ///     size that the parent used to create the `bounds` parameter.
    ///     The parent might propose more than one size before calling the
    ///     placement method, but it always uses one of the proposals and the
    ///     corresponding returned size when placing the container.
    ///   - subviews: A collection of proxies that represent the
    ///     views that the container arranges. Use the proxies in the collection
    ///     to get information about the subviews and to tell the subviews
    ///     where to appear.
    ///   - cache: Optional storage for calculated data that you can share among
    ///     the methods of your custom layout container. See
    ///     ``makeCache(subviews:)`` for details.
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: AnyLayout.Subviews, cache: inout AnyLayout.Cache) {
        storage.placeSubviews(in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
    }

    /// Returns the position of the specified horizontal alignment guide along
    /// the x axis.
    ///
    /// Implement this method to return a value for the specified alignment
    /// guide of a custom layout container. The value you return affects
    /// the placement of the container as a whole, but it doesn't affect how the
    /// container arranges subviews relative to one another.
    ///
    /// You can use this method to put an alignment guide in a nonstandard
    /// position. For example, you can indent the container's leading edge
    /// alignment guide by 10 points:
    ///
    ///     extension BasicVStack {
    ///         func explicitAlignment(
    ///             of guide: HorizontalAlignment,
    ///             in bounds: CGRect,
    ///             proposal: ProposedViewSize,
    ///             subviews: Subviews,
    ///             cache: inout ()
    ///         ) -> CGFloat? {
    ///             if guide == .leading {
    ///                 return bounds.minX + 10
    ///             }
    ///             return nil
    ///         }
    ///     }
    ///
    /// The above example returns `nil` for other guides to indicate that they
    /// don't have an explicit value. A guide without an explicit value behaves
    /// as it would for any other view. If you don't implement the
    /// method, the protocol's default implementation merges the
    /// subviews' guides.
    ///
    /// - Parameters:
    ///   - guide: The ``HorizontalAlignment`` guide that the method calculates
    ///     the position of.
    ///   - bounds: The region that the container view's parent allocates to the
    ///     container view, specified in the parent's coordinate space.
    ///   - proposal: A proposed size for the container.
    ///   - subviews: A collection of proxy instances that represent the
    ///     views arranged by the container. You can use the proxies in the
    ///     collection to get information about the subviews as you determine
    ///     where to place the guide.
    ///   - cache: Optional storage for calculated data that you can share among
    ///     the methods of your custom layout container. See
    ///     ``makeCache(subviews:)`` for details.
    ///
    /// - Returns: The guide's position relative to the `bounds`.
    ///   Return `nil` to indicate that the guide doesn't have an explicit
    ///   value.
    public func explicitAlignment(of guide: HorizontalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: AnyLayout.Subviews, cache: inout AnyLayout.Cache) -> CGFloat? {
        storage.explicitAlignment(of: guide, in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
    }

    /// Returns the position of the specified vertical alignment guide along
    /// the y axis.
    ///
    /// Implement this method to return a value for the specified alignment
    /// guide of a custom layout container. The value you return affects
    /// the placement of the container as a whole, but it doesn't affect how the
    /// container arranges subviews relative to one another.
    ///
    /// You can use this method to put an alignment guide in a nonstandard
    /// position. For example, you can raise the container's bottom edge
    /// alignment guide by 10 points:
    ///
    ///     extension BasicVStack {
    ///         func explicitAlignment(
    ///             of guide: VerticalAlignment,
    ///             in bounds: CGRect,
    ///             proposal: ProposedViewSize,
    ///             subviews: Subviews,
    ///             cache: inout ()
    ///         ) -> CGFloat? {
    ///             if guide == .bottom {
    ///                 return bounds.minY - 10
    ///             }
    ///             return nil
    ///         }
    ///     }
    ///
    /// The above example returns `nil` for other guides to indicate that they
    /// don't have an explicit value. A guide without an explicit value behaves
    /// as it would for any other view. If you don't implement the
    /// method, the protocol's default implementation merges the
    /// subviews' guides.
    ///
    /// - Parameters:
    ///   - guide: The ``VerticalAlignment`` guide that the method calculates
    ///     the position of.
    ///   - bounds: The region that the container view's parent allocates to the
    ///     container view, specified in the parent's coordinate space.
    ///   - proposal: A proposed size for the container.
    ///   - subviews: A collection of proxy instances that represent the
    ///     views arranged by the container. You can use the proxies in the
    ///     collection to get information about the subviews as you determine
    ///     where to place the guide.
    ///   - cache: Optional storage for calculated data that you can share among
    ///     the methods of your custom layout container. See
    ///     ``makeCache(subviews:)`` for details.
    ///
    /// - Returns: The guide's position relative to the `bounds`.
    ///   Return `nil` to indicate that the guide doesn't have an explicit
    ///   value.
    public func explicitAlignment(of guide: VerticalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: AnyLayout.Subviews, cache: inout AnyLayout.Cache) -> CGFloat? {
        storage.explicitAlignment(of: guide, in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
    }

    public var animatableData: AnimatableData {
        get { storage.animatableData }
        set { storage.animatableData = newValue }
    }
}

@available(*, unavailable)
extension AnyLayout.Cache: Sendable {}

@available(*, unavailable)
extension AnyLayout: Sendable {}

// MARK: - AnyLayoutBox

@usableFromInline
class AnyLayoutBox {
    var layoutProperties: LayoutProperties {
        openSwiftUIBaseClassAbstractMethod()
    }

    func makeCache(subviews: LayoutSubviews) -> AnyLayout.Cache {
        openSwiftUIBaseClassAbstractMethod()
    }

    func updateCache(_ cache: inout AnyLayout.Cache, subviews: LayoutSubviews) {
        openSwiftUIBaseClassAbstractMethod()
    }

    func spacing(subviews: LayoutSubviews, cache: inout AnyLayout.Cache) -> ViewSpacing {
        openSwiftUIBaseClassAbstractMethod()
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout AnyLayout.Cache) -> CGSize {
        openSwiftUIBaseClassAbstractMethod()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout AnyLayout.Cache) {
        openSwiftUIBaseClassAbstractMethod()
    }

    func explicitAlignment(of guide: HorizontalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout AnyLayout.Cache) -> CGFloat? {
        openSwiftUIBaseClassAbstractMethod()
    }

    func explicitAlignment(of guide: VerticalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout AnyLayout.Cache) -> CGFloat? {
        openSwiftUIBaseClassAbstractMethod()
    }

    var animatableData: AnyLayout.AnimatableData {
        get { openSwiftUIBaseClassAbstractMethod() }
        set { openSwiftUIBaseClassAbstractMethod() }
    }

    func withAnimatableData(_ data: AnyLayout.AnimatableData) -> AnyLayoutBox {
        openSwiftUIBaseClassAbstractMethod()
    }
}

@available(*, unavailable)
extension AnyLayoutBox: Sendable {}

// MARK: - _AnyLayoutBox

final class _AnyLayoutBox<L>: AnyLayoutBox where L: Layout {
    var layout: L

    init(layout: L) {
        self.layout = layout
    }

    override var layoutProperties: LayoutProperties {
        L.layoutProperties
    }

    override func makeCache(subviews: LayoutSubviews) -> AnyLayout.Cache {
        let cache = layout.makeCache(subviews: subviews)
        return AnyLayout.Cache(type: L.self, value: cache)
    }

    override func updateCache(_ cache: inout AnyLayout.Cache, subviews: LayoutSubviews) {
        if cache.type == L.self {
            var layoutCache = cache.value as! L.Cache
            defer { cache.value = layoutCache }
            layout.updateCache(&layoutCache, subviews: subviews)
        } else {
            cache = makeCache(subviews: subviews)
        }
    }

    override func spacing(subviews: LayoutSubviews, cache: inout AnyLayout.Cache) -> ViewSpacing {
        var layoutCache = cache.value as! L.Cache
        defer { cache.value = layoutCache }
        return layout.spacing(subviews: subviews, cache: &layoutCache)
    }

    override func sizeThatFits(proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout AnyLayout.Cache) -> CGSize {
        var layoutCache = cache.value as! L.Cache
        defer { cache.value = layoutCache }
        return layout.sizeThatFits(proposal: proposal, subviews: subviews, cache: &layoutCache)
    }

    override func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout AnyLayout.Cache) {
        var layoutCache = cache.value as! L.Cache
        defer { cache.value = layoutCache }
        layout.placeSubviews(in: bounds, proposal: proposal, subviews: subviews, cache: &layoutCache)
    }

    override func explicitAlignment(of guide: HorizontalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout AnyLayout.Cache) -> CGFloat? {
        var layoutCache = cache.value as! L.Cache
        defer { cache.value = layoutCache }
        return layout.explicitAlignment(of: guide, in: bounds, proposal: proposal, subviews: subviews, cache: &layoutCache)
    }

    override func explicitAlignment(of guide: VerticalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout AnyLayout.Cache) -> CGFloat? {
        var layoutCache = cache.value as! L.Cache
        defer { cache.value = layoutCache }
        return layout.explicitAlignment(of: guide, in: bounds, proposal: proposal, subviews: subviews, cache: &layoutCache)
    }

    override var animatableData: AnyLayout.AnimatableData {
        get { .init(layout) }
        set { newValue.update(&layout) }
    }
}

// MARK: - Deprecated types for @spi(_)

@_spi(_)
@available(*, deprecated, renamed: "AnyLayout")
public typealias AnyViewLayout = AnyLayout
