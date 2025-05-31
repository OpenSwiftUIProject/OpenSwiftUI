//
//  UnaryLayout.swift
//  OpenSwiftUICore
//
//  Status: Blocked by makeStaticView and makeDynamicView

package import Foundation
package import OpenGraphShims

// MARK: - UnaryLayout [6.4.41]

package protocol UnaryLayout: Animatable, MultiViewModifier, PrimitiveViewModifier {
    associatedtype PlacementContextType = PlacementContext

    func spacing(in context: SizeAndSpacingContext, child: LayoutProxy) -> Spacing

    func placement(of child: LayoutProxy, in context: PlacementContextType) -> _Placement

    func sizeThatFits(in proposedSize: _ProposedSize, context: SizeAndSpacingContext, child: LayoutProxy) -> CGSize

    func layoutPriority(child: LayoutProxy) -> Double

    func ignoresAutomaticPadding(child: LayoutProxy) -> Bool

    static func makeViewImpl(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs
}

extension UnaryLayout {
    package func layoutPriority(child: LayoutProxy) -> Double {
        child.layoutPriority
    }

    package func ignoresAutomaticPadding(child: LayoutProxy) -> Bool {
        false
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeViewImpl(modifier: modifier, inputs: inputs, body: body)
    }

    package func spacing(in context: SizeAndSpacingContext, child: LayoutProxy) -> Spacing {
        child.spacing()
    }
}

// MARK: - DerivedLayout [6.4.41]

package protocol DerivedLayout: Layout {
    associatedtype Base: Layout where Cache == Base.Cache

    var base: Base { get }
}

extension DerivedLayout {
    public static var layoutProperties: LayoutProperties {
        Base.layoutProperties
    }

    public func makeCache(subviews: Subviews) -> Base.Cache {
        base.makeCache(subviews: subviews)
    }

    public func updateCache(_ cache: inout Base.Cache, subviews: Subviews) {
        base.updateCache(&cache, subviews: subviews)
    }

    public func spacing(subviews: Subviews, cache: inout Base.Cache) -> ViewSpacing {
        base.spacing(subviews: subviews, cache: &cache)
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Base.Cache) -> CGSize {
        base.sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Base.Cache) {
        base.placeSubviews(in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
    }

    public func explicitAlignment(of guide: HorizontalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Base.Cache) -> CGFloat? {
        base.explicitAlignment(of: guide, in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
    }

    public func explicitAlignment(of guide: VerticalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Base.Cache) -> CGFloat? {
        base.explicitAlignment(of: guide, in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
    }
}

// MARK: - Layout + Static/Dynamic View Creation [6.4.41] [WIP]

extension Layout {
    package static func makeStaticView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        properties: LayoutProperties,
        list: any _ViewList_Elements
    ) -> _ViewOutputs {
        preconditionFailure("TODO")
    }

    static func makeDynamicView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        properties: LayoutProperties,
        list: Attribute<any ViewList>
    ) -> _ViewOutputs {
        preconditionFailure("TODO")
    }
}

package struct LayoutChildGeometries: Rule, AsyncAttribute {
    @Attribute
    private var parentSize: ViewSize

    @Attribute
    private var parentPosition: PlatformPoint

    @Attribute
    private var layoutComputer: LayoutComputer

    package init(parentSize: Attribute<ViewSize>, parentPosition: Attribute<PlatformPoint>, layoutComputer: Attribute<LayoutComputer>) {
        _parentSize = parentSize
        _parentPosition = parentPosition
        _layoutComputer = layoutComputer
    }

    package var value: [ViewGeometry] {
        layoutComputer.childGeometries(at: parentSize, origin: parentPosition)
    }
}

extension StatefulRule where Value == LayoutComputer {
    package mutating func updateLayoutComputer<L>(
        layout: L,
        environment: Attribute<EnvironmentValues>,
        attributes: [LayoutProxyAttributes]
    ) where L: Layout {
        let context = AnyRuleContext(attribute: AnyAttribute.current!)
        layout.updateLayoutComputer(
            rule: &self,
            layoutContext: SizeAndSpacingContext(
                context: context,
                environment: environment
            ),
            children: LayoutProxyCollection(
                context: context,
                attributes: attributes
            )
        )
    }
}
