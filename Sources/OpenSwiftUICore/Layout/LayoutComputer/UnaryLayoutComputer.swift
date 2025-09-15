//
//  UnaryLayoutComputer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1C3B77B617AD058A6802F719E38F5D79 (SwiftUICore?)

import Foundation
package import OpenAttributeGraphShims

// MARK: - UnaryLayout + _PositionAwarePlacementContext

/// Extension for UnaryLayout when using position-aware placement context.
/// This provides layout computation that includes position, transform, and safe area information.
extension UnaryLayout where Self.PlacementContextType == _PositionAwarePlacementContext {
    package static func makeViewImpl(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        guard inputs.requestsLayoutComputer || inputs.needsGeometry else {
            return body(_Graph(), inputs)
        }
        let animatedModifier = makeAnimatable(value: modifier, inputs: inputs.base)
        var newInputs = inputs
        let geometry: Attribute<ViewGeometry>!
        if inputs.needsGeometry {
            geometry = Attribute(
                UnaryPositionAwareChildGeometry(
                    layout: animatedModifier,
                    layoutDirection: inputs.layoutDirection,
                    parentSize: inputs.size,
                    position: inputs.position,
                    transform: inputs.transform,
                    environment: inputs.environment,
                    childLayoutComputer: .init(),
                    safeAreaInsets: inputs.safeAreaInsets
                )
            )
            newInputs.size = geometry.size()
            newInputs.position = geometry.origin()
            newInputs.requestsLayoutComputer = true
        } else {
            geometry = nil
        }
        var outputs = body(_Graph(), newInputs)
        if inputs.needsGeometry {
            geometry.mutateBody(
                as: UnaryPositionAwareChildGeometry<Self>.self,
                invalidating: true
            ) { geometry in
                geometry.$childLayoutComputer = outputs.layoutComputer
            }
        }
        if inputs.requestsLayoutComputer {
            outputs.layoutComputer = Attribute(
                UnaryPositionAwareLayoutComputer(
                    layout: animatedModifier,
                    environment: inputs.environment,
                    childLayoutComputer: .init(outputs.layoutComputer)
                )
            )
        }
        return outputs
    }
}

// MARK: - UnaryLayout + PlacementContext

/// Extension for UnaryLayout when using standard placement context.
/// This provides layout computation without position awareness (no safe area or transform information).
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
        var newInputs = inputs
        let geometry: Attribute<ViewGeometry>!
        if inputs.needsGeometry {
            geometry = Attribute(UnaryChildGeometry<Self>(
                parentSize: inputs.size,
                layoutDirection: inputs.layoutDirection,
                parentLayoutComputer: computer
            ))
            newInputs.size = geometry.size()
            newInputs.position = Attribute(LayoutPositionQuery(
                parentPosition: inputs.position,
                localPosition: geometry.origin()
            ))
            newInputs.requestsLayoutComputer = true
        } else {
            geometry = nil
        }
        let requestsLayoutComputer = inputs.requestsLayoutComputer
        var outputs = body(_Graph(), newInputs)
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

// MARK: - LayoutPositionQuery

/// Computes the absolute position of a view by combining parent and local positions.
/// This is used to track the hierarchical positioning in the layout system.
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

// MARK: - UnaryPositionAwareLayoutComputer

/// A layout computer for unary layouts that are aware of their position in the view hierarchy.
/// This computer handles layouts that need access to safe area insets and transformations.
private struct UnaryPositionAwareLayoutComputer<L>: StatefulRule, AsyncAttribute, CustomStringConvertible
    where L: UnaryLayout, L.PlacementContextType == _PositionAwarePlacementContext {
    @Attribute var layout: L
    @Attribute var environment: EnvironmentValues
    @OptionalAttribute var childLayoutComputer: LayoutComputer?

    typealias Value = LayoutComputer

    mutating func updateValue() {
        let context = AnyRuleContext(context)
        let engine = UnaryPositionAwareLayoutEngine(
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

// MARK: - UnaryPositionAwareChildGeometry

/// Geometry calculator for child views in position-aware unary layouts.
/// This handles the geometric transformations and safe area calculations for child views.
private struct UnaryPositionAwareChildGeometry<L>: Rule, AsyncAttribute, CustomStringConvertible
    where L: UnaryLayout, L.PlacementContextType == _PositionAwarePlacementContext {
    @Attribute var layout: L
    @Attribute var layoutDirection: LayoutDirection
    @Attribute var parentSize: ViewSize
    @Attribute var position: ViewOrigin
    @Attribute var transform: ViewTransform
    @Attribute var environment: EnvironmentValues
    @OptionalAttribute var childLayoutComputer: LayoutComputer?
    @OptionalAttribute var safeAreaInsets: SafeAreaInsets?

    var value: ViewGeometry {
        let context = AnyRuleContext(context)
        let child = LayoutProxy(
            context: context,
            layoutComputer: $childLayoutComputer
        )
        let placement = layout.placement(
            of: child,
            in: _PositionAwarePlacementContext(
                context: context,
                size: _parentSize,
                environment: _environment,
                transform: _transform,
                position: _position,
                safeAreaInsets: _safeAreaInsets
            )
        )
        return child.finallyPlaced(
            at: placement,
            in: parentSize.value,
            layoutDirection: layoutDirection
        )
    }

    var description: String {
        "\(L.self) → ViewGeometry"
    }
}

// MARK: - UnaryChildGeometry

/// Computes the geometry for a child view in a unary layout without position awareness.
/// This handles the placement and sizing of child views in standard layouts.
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
        let child = LayoutProxy(
            context: AnyRuleContext(context),
            layoutComputer: $childLayoutComputer
        )
        return child.finallyPlaced(
            at: placement,
            in: parentSize.value,
            layoutDirection: layoutDirection
        )
    }

    var description: String {
        "\(L.self) → ChildGeometry"
    }
}

// MARK: - UnaryLayoutComputer

/// A layout computer for standard unary layouts without position awareness.
/// This manages the layout computation for layouts that don't need safe area or transform information.
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

// MARK: - UnaryPositionAwareLayoutEngine

/// Layout engine for position-aware unary layouts.
/// This engine manages the layout computation for layouts that need position and safe area information.
private struct UnaryPositionAwareLayoutEngine<L>: LayoutEngine
    where L: UnaryLayout, L.PlacementContextType == _PositionAwarePlacementContext {
    let layout: L
    let layoutContext: SizeAndSpacingContext
    let child: LayoutProxy
    var cache: ViewSizeCache = .init()

    init(
        layout: L,
        layoutContext: SizeAndSpacingContext,
        child: LayoutProxy
    ) {
        self.layout = layout
        self.layoutContext = layoutContext
        self.child = child
    }

    func layoutPriority() -> Double {
        layout.layoutPriority(child: child)
    }

    mutating func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        let layout = layout
        let context = layoutContext
        let child = child
        return cache.get(proposedSize) {
            layout.sizeThatFits(
                in: proposedSize,
                context: context,
                child: child
            )
        }
    }
}

// MARK: - UnaryLayoutEngine

/// Layout engine for standard unary layouts without position awareness.
/// This engine manages the basic layout computation including sizing, placement, and alignment.
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
