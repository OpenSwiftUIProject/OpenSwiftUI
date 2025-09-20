//
//  SafeAreaIgnoringLayout.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraph
package import OpenCoreGraphicsShims

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _SafeAreaIgnoringLayout: UnaryLayout {
    public var edges: Edge.Set

    @inlinable
    public init(edges: Edge.Set = .all) {
        self.edges = edges
    }

    package func placement(
        of child: LayoutProxy,
        in context: _PositionAwarePlacementContext
    ) -> _Placement {
        let insets = context.safeAreaInsets().in(edges)
        let size = context.proposedSize.inset(by: insets)
        return _Placement(
            proposedSize: size,
            anchoring: .topLeading,
            at: .zero - insets.originOffset
        )
    }

    package func sizeThatFits(
        in proposedSize: _ProposedSize,
        context: SizeAndSpacingContext,
        child: LayoutProxy
    ) -> CGSize {
        child.size(in: proposedSize)
    }

    package func ignoresAutomaticPadding(child: LayoutProxy) -> Bool {
        true
    }

    package typealias PlacementContextType = _PositionAwarePlacementContext
}


// MARK: - _SafeAreaRegionsIgnoringLayout

@available(OpenSwiftUI_v2_0, *)
@frozen
public struct _SafeAreaRegionsIgnoringLayout: UnaryLayout {
    public var regions: SafeAreaRegions

    public var edges: Edge.Set

    @inlinable
    package init(regions: SafeAreaRegions, edges: Edge.Set) {
        self.regions = regions
        self.edges = edges
    }

    package func placement(
        of child: LayoutProxy,
        in context: _PositionAwarePlacementContext
    ) -> _Placement {
        let insets = context.safeAreaInsets(matching: regions).in(edges)
        let size = context.proposedSize.inset(by: -insets)
        return _Placement(
            proposedSize: size,
            anchoring: .topLeading,
            at: .zero - insets.originOffset
        )
    }

    package func sizeThatFits(
        in proposedSize: _ProposedSize,
        context: SizeAndSpacingContext,
        child: LayoutProxy
    ) -> CGSize {
        child.size(in: proposedSize)
    }

    package func ignoresAutomaticPadding(child: LayoutProxy) -> Bool {
        true
    }

    package typealias PlacementContextType = _PositionAwarePlacementContext
}

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Changes the view's proposed area to extend outside the screen's safe
    /// areas.
    ///
    /// Use `edgesIgnoringSafeArea(_:)` to change the area proposed for this
    /// view so that — were the proposal accepted — this view could extend
    /// outside the safe area to the bounds of the screen for the specified
    /// edges.
    ///
    /// For example, you can propose that a text view ignore the safe area's top
    /// inset:
    ///
    ///     VStack {
    ///         Text("This text is outside of the top safe area.")
    ///             .edgesIgnoringSafeArea([.top])
    ///             .border(Color.purple)
    ///         Text("This text is inside VStack.")
    ///             .border(Color.yellow)
    ///     }
    ///     .border(Color.gray)
    ///
    /// ![A screenshot showing a view whose bounds exceed the safe area of the
    /// screen.](OpenSwiftUI-View-edgesIgnoringSafeArea.png)
    ///
    /// Depending on the surrounding view hierarchy, OpenSwiftUI may not honor an
    /// `edgesIgnoringSafeArea(_:)` request. This can happen, for example, if
    /// the view is inside a container that respects the screen's safe area. In
    /// that case you may need to apply `edgesIgnoringSafeArea(_:)` to the
    /// container instead.
    ///
    /// - Parameter edges: The set of the edges in which to expand the size
    ///   requested for this view.
    ///
    /// - Returns: A view that may extend outside of the screen's safe area
    ///   on the edges specified by `edges`.
    @available(*, deprecated, message: "Use ignoresSafeArea(_:edges:) instead.")
    @inlinable
    nonisolated public func edgesIgnoringSafeArea(_ edges: Edge.Set) -> some View {
        return modifier(_SafeAreaIgnoringLayout(edges: edges))
    }
}

@available(OpenSwiftUI_v2_0, *)
extension View {

    /// Expands the safe area of a view.
    ///
    /// By default, the OpenSwiftUI layout system sizes and positions views to
    /// avoid certain safe areas. This ensures that system content like the
    /// software keyboard or edges of the device don’t obstruct your
    /// views. To extend your content into these regions, you can ignore
    /// safe areas on specific edges by applying this modifier.
    ///
    /// For examples of how to use this modifier,
    /// see <doc:Adding-a-Background-to-Your-View>.
    ///
    /// - Parameters:
    ///   - regions: The regions to expand the view's safe area into. The
    ///     modifier expands into all safe area region types by default.
    ///   - edges: The set of edges to expand. Any edges that you
    ///     don't include in this set remain unchanged. The set includes all
    ///     edges by default.
    ///
    /// - Returns: A view with an expanded safe area.
    @inlinable
    nonisolated public func ignoresSafeArea(
        _ regions: SafeAreaRegions = .all,
        edges: Edge.Set = .all
    ) -> some View {
        modifier(
            _SafeAreaRegionsIgnoringLayout(
                regions: regions,
                edges: edges
            )
        )
    }
}
