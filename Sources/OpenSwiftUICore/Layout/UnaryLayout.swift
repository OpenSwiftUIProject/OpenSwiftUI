//
//  UnaryLayout.swift
//  OpenSwiftUICore
//
//  Status: Blocked by makeDynamicView
//  ID: A7DFBD5AC47BCDAAE5525781FBD33CF6 (SwiftUICore?)

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

// MARK: - Layout + Static/Dynamic View Creation [6.4.41]

extension Layout {
    package static func makeStaticView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        properties: LayoutProperties,
        list: any ViewList.Elements
    ) -> _ViewOutputs {
        let count = list.count
        if count == 1, properties.isIdentityUnaryLayout {
            return list.makeAllElements(inputs: inputs) { inputs, makeElement in
                makeElement(inputs)
            } ?? .init()
        } else if count == 0, properties.isDefaultEmptyLayout {
            return .init()
        } else {
            let needLayout = inputs.requestsLayoutComputer || inputs.needsGeometry
            var layoutComputer: Attribute<LayoutComputer>!
            var geometry: Attribute<[ViewGeometry]>!
            if needLayout {
                layoutComputer = Attribute(
                    StaticLayoutComputer(
                        layout: root.value,
                        environment: inputs.environment,
                        childAttributes: []
                    )
                )
                geometry = Attribute(
                    LayoutChildGeometries(
                        parentSize: inputs.size,
                        parentPosition: inputs.position,
                        layoutComputer: layoutComputer
                    )
                )
            }
            var index: Int = 0
            var childAttributes: [LayoutProxyAttributes] = []
            var outputs = list.makeAllElements(inputs: inputs) {
                inputs,
                makeElement in
                var inputs = inputs
                if inputs.needsGeometry {
                    let childGeometry = Attribute(
                        LayoutChildGeometry(
                            childGeometries: geometry,
                            index: index
                        )
                    )
                    inputs.position = childGeometry.origin()
                    inputs.size = childGeometry.size()
                }
                let ouputs = makeElement(inputs)
                if inputs.needsGeometry {
                    childAttributes.append(LayoutProxyAttributes(
                        layoutComputer: .init(ouputs.layoutComputer),
                        traitsList: .init()
                    ))
                }
                index &+= 1
                return ouputs
            } ?? .init()
            if needLayout {
                layoutComputer.mutateBody(as: StaticLayoutComputer<Self>.self, invalidating: true) { computer in
                    computer.childAttributes = childAttributes
                }
            }
            if inputs.requestsLayoutComputer {
                outputs.layoutComputer = layoutComputer // FIXME
            }
            return outputs
        }
    }

    static func makeDynamicView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        properties: LayoutProperties,
        list: Attribute<any ViewList>
    ) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}

package struct LayoutChildGeometries: Rule, AsyncAttribute {
    @Attribute
    private var parentSize: ViewSize

    @Attribute
    private var parentPosition: ViewOrigin

    @Attribute
    private var layoutComputer: LayoutComputer

    package init(parentSize: Attribute<ViewSize>, parentPosition: Attribute<ViewOrigin>, layoutComputer: Attribute<LayoutComputer>) {
        _parentSize = parentSize
        _parentPosition = parentPosition
        _layoutComputer = layoutComputer
    }

    package var value: [ViewGeometry] {
        layoutComputer.childGeometries(at: parentSize, origin: parentPosition)
    }
}

private struct StaticLayoutComputer<L>: StatefulRule, AsyncAttribute, CustomStringConvertible where L: Layout {
    @Attribute
    private var layout: L

    @Attribute
    private var environment: EnvironmentValues

    var childAttributes: [LayoutProxyAttributes]

    init(layout: Attribute<L>, environment: Attribute<EnvironmentValues>, childAttributes: [LayoutProxyAttributes]) {
        self._layout = layout
        self._environment = environment
        self.childAttributes = childAttributes
    }

    typealias Value = LayoutComputer

    mutating func updateValue() {
        updateLayoutComputer(
            layout: layout,
            environment: $environment,
            attributes: childAttributes
        )
    }

    var description: String {
        "\(L.self) → LayoutComputer"
    }
}

private struct LayoutChildGeometry: Rule, AsyncAttribute {
    @Attribute
    private var childGeometries: [ViewGeometry]

    private let index: Int

    init(childGeometries: Attribute<[ViewGeometry]>, index: Int) {
        self._childGeometries = childGeometries
        self.index = index
    }

    var value: ViewGeometry {
        childGeometries[index]
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
