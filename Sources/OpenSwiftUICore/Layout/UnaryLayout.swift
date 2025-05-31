//
//  UnaryLayout.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

package import Foundation
package import OpenGraphShims

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

extension StatefulRule where Value == LayoutComputer {
    package mutating func updateLayoutComputer<L>(
        layout: L,
        environment: Attribute<EnvironmentValues>,
        attributes: [LayoutProxyAttributes]
    ) where L: Layout {
        preconditionFailure("TODO")
    }
}
