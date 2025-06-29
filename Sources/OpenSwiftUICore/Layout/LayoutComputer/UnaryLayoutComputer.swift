//
//  UnaryLayoutComputer.swift
//  OpenSwiftUICore
//
//  Status: Blocked by _PositionAwarePlacementContext
//  ID: 1C3B77B617AD058A6802F719E38F5D79 (SwiftUICore?)

import Foundation
package import OpenGraphShims

// MARK: - UnaryLayout + _PositionAwarePlacementContext [6.4.41] [TODO]

extension UnaryLayout where Self.PlacementContextType == _PositionAwarePlacementContext {
    package static func makeViewImpl(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        openSwiftUIUnimplementedFailure()
    }
}

// MARK: - UnaryLayout + PlacementContext [6.4.41]

extension UnaryLayout where PlacementContextType == PlacementContext {
    package static func makeViewImpl(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        guard inputs.requestsLayoutComputer || inputs.needsGeometry else {
            return body(_Graph(), inputs)
        }
        let animatedModifier = makeAnimatable(value: modifier, inputs: inputs.base)
        let computer = Attribute(UnaryLayoutComputer(
            layout: animatedModifier,
            environment: inputs.environment,
            childLayoutComputer: OptionalAttribute()
        ))
        var inputs = inputs
        let geometry: Attribute<ViewGeometry>!
        if inputs.needsGeometry {
            geometry = Attribute(UnaryChildGeometry<Self>(
                parentSize: inputs.size,
                layoutDirection: inputs.layoutDirection,
                parentLayoutComputer: computer
            ))
            inputs.size = geometry.size()
            inputs.position = Attribute(LayoutPositionQuery(
                parentPosition: inputs.position,
                localPosition: geometry.origin()
            ))
            inputs.requestsLayoutComputer = true
        } else {
            geometry = nil
        }
        let requestsLayoutComputer = inputs.requestsLayoutComputer
        var outputs = body(_Graph(), inputs)
        if inputs.needsGeometry {
            computer.mutateBody(as: UnaryLayoutComputer<Self>.self, invalidating: true) { computer in
                computer.$childLayoutComputer = outputs.layoutComputer
            }
            geometry.mutateBody(as: UnaryChildGeometry<Self>.self, invalidating: true) { geometry in
                geometry.$childLayoutComputer = outputs.layoutComputer
            }
        }
        if requestsLayoutComputer {
            outputs.layoutComputer = computer
        }
        return outputs
    }
}

private struct UnaryChildGeometry<L>: Rule, AsyncAttribute, CustomStringConvertible
    where L: UnaryLayout, L.PlacementContextType == PlacementContext {
    @Attribute var parentSize: ViewSize
    @Attribute var layoutDirection: LayoutDirection
    @Attribute var parentLayoutComputer: LayoutComputer
    @OptionalAttribute var childLayoutComputer: LayoutComputer?

    var value: ViewGeometry {
        let parentSize = parentSize
        let computer = parentLayoutComputer
        let placement = computer.withMutableEngine(type: UnaryLayoutEngine<L>.self) { engine in
            engine.childPlacement(at: parentSize)
        }
        let childProxy = LayoutProxy(
            context: AnyRuleContext(context),
            layoutComputer: $childLayoutComputer
        )
        return childProxy.finallyPlaced(
            at: placement,
            in: parentSize.value,
            layoutDirection: layoutDirection
        )
    }

    var description: String {
        "\(L.self) → ChildGeometry"
    }
}

private struct UnaryLayoutComputer<L>: StatefulRule, AsyncAttribute, CustomStringConvertible
    where L: UnaryLayout, L.PlacementContextType == PlacementContext {
    @Attribute var layout: L
    @Attribute var environment: EnvironmentValues
    @OptionalAttribute var childLayoutComputer: LayoutComputer?

    typealias Value = LayoutComputer

    mutating func updateValue() {
        let context = AnyRuleContext(context)
        let engine = UnaryLayoutEngine(
            layout: layout,
            layoutContext: SizeAndSpacingContext(context: context, environment: $environment),
            child: LayoutProxy(context: context, layoutComputer: $childLayoutComputer)
        )
        update(to: engine)
    }

    var description: String {
        "\(L.self) → LayoutComputer"
    }
}

private struct UnaryLayoutEngine<L>: LayoutEngine
    where L: UnaryLayout, L.PlacementContextType == PlacementContext {
    let layout: L

    let layoutContext: SizeAndSpacingContext

    let child: LayoutProxy

    var dimensionsCache: ViewSizeCache = .init()

    var placementCache: Cache3<ViewSize, _Placement> = .init()

    init(layout: L, layoutContext: SizeAndSpacingContext, child: LayoutProxy) {
        self.layout = layout
        self.layoutContext = layoutContext
        self.child = child
    }

    mutating func childPlacement(at size: ViewSize) -> _Placement {
        let layout = layout
        let child = child
        let context = PlacementContext(base: layoutContext, parentSize: size)
        return placementCache.get(size) {
            layout.placement(of: child, in: context)
        }
    }

    func layoutPriority() -> Double {
        layout.layoutPriority(child: child)
    }

    func ignoresAutomaticPadding() -> Bool {
        layout.ignoresAutomaticPadding(child: child)
    }

    func spacing() -> Spacing {
        layout.spacing(in: layoutContext, child: child)
    }

    mutating func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        let layout = layout
        let context = layoutContext
        let child = child
        return dimensionsCache.get(proposedSize) {
            layout.sizeThatFits(
                in: proposedSize,
                context: context,
                child: child
            )
        }
    }

    mutating func explicitAlignment(_ k: AlignmentKey, at viewSize: ViewSize) -> CGFloat? {
        let placement = childPlacement(at: viewSize)
        let dimensions = child.dimensions(in: placement.proposedSize_)
        let alignment = child.explicitAlignment(k, at: dimensions.size)
        if let alignment {
            return placement.frameOrigin(childSize: dimensions.size.value)[k.axis] + alignment
        } else {
            return alignment
        }
    }
}

// MARK: - LayoutPositionQuery [6.4.41]

package struct LayoutPositionQuery: Rule, AsyncAttribute {
    @Attribute private var parentPosition: ViewOrigin
    @Attribute private var localPosition: ViewOrigin

    package init(
        parentPosition: Attribute<ViewOrigin>,
        localPosition: Attribute<ViewOrigin>,
    ) {
        _parentPosition = parentPosition
        _localPosition = localPosition
    }

    package var value: ViewOrigin {
        let localPosition = localPosition
        let parentPosition = parentPosition
        return ViewOrigin(
            x: localPosition.x + parentPosition.x,
            y: localPosition.y + parentPosition.y
        )
    }
}
