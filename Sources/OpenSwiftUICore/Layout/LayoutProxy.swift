//
//  LayoutProxy.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import OpenGraphShims

package struct LayoutProxyAttributes: Equatable {
    @OptionalAttribute
    var layoutComputer: LayoutComputer?

    @OptionalAttribute
    var traitList: (any ViewList)?

    package init(layoutComputer: OptionalAttribute<LayoutComputer>, traitsList: OptionalAttribute<any ViewList>) {
        _layoutComputer = layoutComputer
        _traitList = traitsList
    }

    package init(traitsList: OptionalAttribute<any ViewList>) {
        _layoutComputer = OptionalAttribute()
        _traitList = traitsList
    }

    package init(layoutComputer: OptionalAttribute<LayoutComputer>) {
        _layoutComputer = layoutComputer
        _traitList = OptionalAttribute()
    }

    package init() {
        _layoutComputer = OptionalAttribute()
        _traitList = OptionalAttribute()
    }

    package var isEmpty: Bool {
        $layoutComputer == nil && $traitList == nil
    }
}

package struct LayoutProxy: Equatable {
    var context: AnyRuleContext

    var attributes: LayoutProxyAttributes

    package init(context: AnyRuleContext, attributes: LayoutProxyAttributes) {
        self.context = context
        self.attributes = attributes
    }

    package init(context: AnyRuleContext, layoutComputer: Attribute<LayoutComputer>?) {
        self.context = context
        self.attributes = LayoutProxyAttributes(layoutComputer: .init(layoutComputer))
    }

    package var layoutComputer: LayoutComputer {
        guard let layoutComputer = attributes.$layoutComputer else {
            return .defaultValue
        }
        return context[layoutComputer]
    }

    package var traits: ViewTraitCollection? {
        guard let traitList = attributes.$traitList else {
            return nil
        }
        return context[traitList].traits
    }

    package subscript<K>(key: K.Type) -> K.Value where K: _ViewTraitKey {
        traits.map { $0[key] } ?? K.defaultValue
    }

    package func spacing() -> Spacing {
        layoutComputer.spacing()
    }

    package func idealSize() -> CGSize {
        size(in: .unspecified)
    }

    package func size(in proposedSize: _ProposedSize) -> CGSize {
        layoutComputer.sizeThatFits(proposedSize)
    }

    package func lengthThatFits(_ proposal: _ProposedSize, in direction: Axis) -> CGFloat {
        layoutComputer.lengthThatFits(proposal, in: direction)
    }

    package func dimensions(in proposedSize: _ProposedSize) -> ViewDimensions {
        let computer = layoutComputer
        return ViewDimensions(
            guideComputer: computer,
            size: computer.sizeThatFits(proposedSize),
            proposal: _ProposedSize(
                width: proposedSize.width ?? .nan,
                height: proposedSize.height ?? .nan
            )
        )
    }

    package func finallyPlaced(at p: _Placement, in parentSize: CGSize, layoutDirection: LayoutDirection) -> ViewGeometry {
        let dimensions = dimensions(in: p.proposedSize_)
        var geometry = ViewGeometry(
            placement: p,
            dimensions: dimensions
        )
        geometry.finalizeLayoutDirection(layoutDirection, parentSize: parentSize)
        return geometry
    }

    package func explicitAlignment(_ k: AlignmentKey, at mySize: ViewSize) -> CGFloat? {
        layoutComputer.explicitAlignment(k, at: mySize)
    }

    package var layoutPriority: Double {
        layoutComputer.layoutPriority()
    }

    package var ignoresAutomaticPadding: Bool {
        layoutComputer.ignoresAutomaticPadding()
    }

    package var requiresSpacingProjection: Bool {
        layoutComputer.requiresSpacingProjection()
    }
}

package struct LayoutProxyCollection: RandomAccessCollection {
    var context: AnyRuleContext

    var attributes: [LayoutProxyAttributes]

    package init(context: AnyRuleContext, attributes: [LayoutProxyAttributes]) {
        self.context = context
        self.attributes = attributes
    }

    package var startIndex: Int { .zero }

    package var endIndex: Int { attributes.endIndex }

    package subscript(index: Int) -> LayoutProxy {
        LayoutProxy(context: context, attributes: attributes[index])
    }
}
