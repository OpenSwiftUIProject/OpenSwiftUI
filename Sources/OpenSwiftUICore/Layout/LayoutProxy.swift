//
//  LayoutProxy.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

package import Foundation
package import OpenAttributeGraphShims

/// A collection of attributes that can be applied to layout calculations.
///
/// `LayoutProxyAttributes` stores optional references to a layout computer and a view trait list,
/// which are used to compute layouts and access view traits during layout operations.
package struct LayoutProxyAttributes: Equatable {
    /// The layout computer used to calculate sizes and positions.
    @OptionalAttribute
    var layoutComputer: LayoutComputer?

    /// The list of view traits that affect layout behavior.
    @OptionalAttribute
    var traitList: (any ViewList)?

    /// Creates layout proxy attributes with the specified layout computer and traits list.
    ///
    /// - Parameters:
    ///   - layoutComputer: The optional attribute containing a layout computer.
    ///   - traitsList: The optional attribute containing view traits.
    package init(layoutComputer: OptionalAttribute<LayoutComputer>, traitsList: OptionalAttribute<any ViewList>) {
        _layoutComputer = layoutComputer
        _traitList = traitsList
    }

    /// Creates layout proxy attributes with only traits.
    ///
    /// - Parameter traitsList: The optional attribute containing view traits.
    package init(traitsList: OptionalAttribute<any ViewList>) {
        _layoutComputer = OptionalAttribute()
        _traitList = traitsList
    }

    /// Creates layout proxy attributes with only a layout computer.
    ///
    /// - Parameter layoutComputer: The optional attribute containing a layout computer.
    package init(layoutComputer: OptionalAttribute<LayoutComputer>) {
        _layoutComputer = layoutComputer
        _traitList = OptionalAttribute()
    }

    /// Creates empty layout proxy attributes with no layout computer or traits.
    package init() {
        _layoutComputer = OptionalAttribute()
        _traitList = OptionalAttribute()
    }

    /// Determines if this collection of attributes is empty.
    ///
    /// Returns `true` if neither the layout computer nor the trait list is set.
    package var isEmpty: Bool {
        $layoutComputer == nil && $traitList == nil
    }
}

/// A proxy object used to perform layout calculations for views.
///
/// `LayoutProxy` provides an interface to compute sizes, dimensions, and positions
/// of views during the layout process. It combines layout computers and view traits
/// to determine the final layout characteristics of a view.
package struct LayoutProxy: Equatable {
    /// The rule context used to resolve attribute values.
    var context: AnyRuleContext

    /// The attributes that define the layout behavior.
    var attributes: LayoutProxyAttributes

    /// Creates a layout proxy with the specified context and attributes.
    ///
    /// - Parameters:
    ///   - context: The rule context used to resolve attribute values.
    ///   - attributes: The attributes that define the layout behavior.
    package init(context: AnyRuleContext, attributes: LayoutProxyAttributes) {
        self.context = context
        self.attributes = attributes
    }

    /// Creates a layout proxy with the specified context and layout computer.
    ///
    /// - Parameters:
    ///   - context: The rule context used to resolve attribute values.
    ///   - layoutComputer: The optional layout computer to use for calculations.
    package init(context: AnyRuleContext, layoutComputer: Attribute<LayoutComputer>?) {
        self.context = context
        self.attributes = LayoutProxyAttributes(layoutComputer: .init(layoutComputer))
    }

    /// The layout computer to use for layout calculations.
    ///
    /// If no layout computer is explicitly provided, returns the default layout computer.
    package var layoutComputer: LayoutComputer {
        guard let layoutComputer = attributes.$layoutComputer else {
            return .defaultValue
        }
        return context[layoutComputer]
    }

    /// The collection of view traits associated with this layout proxy.
    ///
    /// Returns `nil` if no trait list is available.
    package var traits: ViewTraitCollection? {
        guard let traitList = attributes.$traitList else {
            return nil
        }
        return context[traitList].traits
    }

    /// Accesses a specific trait value by its key type.
    ///
    /// - Parameter key: The trait key type to look up.
    /// - Returns: The value for the specified trait key, or the default value if the trait is not present.
    package subscript<K>(key: K.Type) -> K.Value where K: _ViewTraitKey {
        traits.map { $0[key] } ?? K.defaultValue
    }

    /// Returns the spacing configuration for this layout.
    ///
    /// - Returns: The spacing configuration derived from the layout computer.
    package func spacing() -> Spacing {
        layoutComputer.spacing()
    }

    /// Calculates the ideal size for the view without any specific constraints.
    ///
    /// - Returns: The ideal size as determined by the layout computer.
    package func idealSize() -> CGSize {
        size(in: .unspecified)
    }

    /// Calculates the size that fits within the given proposed size.
    ///
    /// - Parameter proposedSize: The size constraints to consider.
    /// - Returns: The calculated size that fits within the constraints.
    package func size(in proposedSize: _ProposedSize) -> CGSize {
        layoutComputer.sizeThatFits(proposedSize)
    }

    /// Calculates the length that fits within the given proposal along a specific axis.
    ///
    /// - Parameters:
    ///   - proposal: The size constraints to consider.
    ///   - direction: The axis along which to calculate the length.
    /// - Returns: The calculated length that fits within the constraints.
    package func lengthThatFits(_ proposal: _ProposedSize, in direction: Axis) -> CGFloat {
        layoutComputer.lengthThatFits(proposal, in: direction)
    }

    /// Calculates the view dimensions within the given proposed size.
    ///
    /// - Parameter proposedSize: The size constraints to consider.
    /// - Returns: The calculated dimensions including size and alignment guides.
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

    /// Calculates the final geometry of a view at a specific placement within a parent.
    ///
    /// - Parameters:
    ///   - p: The placement defining position and proposed size.
    ///   - parentSize: The size of the parent container.
    ///   - layoutDirection: The layout direction (left-to-right or right-to-left).
    /// - Returns: The final view geometry including position and dimensions.
    package func finallyPlaced(at p: _Placement, in parentSize: CGSize, layoutDirection: LayoutDirection) -> ViewGeometry {
        let dimensions = dimensions(in: p.proposedSize_)
        var geometry = ViewGeometry(
            placement: p,
            dimensions: dimensions
        )
        geometry.finalizeLayoutDirection(layoutDirection, parentSize: parentSize)
        return geometry
    }

    /// Returns the explicit alignment for a specific alignment key at the given size.
    ///
    /// - Parameters:
    ///   - k: The alignment key to measure.
    ///   - mySize: The size at which to measure the alignment.
    /// - Returns: The explicit alignment position, or `nil` if not explicitly defined.
    package func explicitAlignment(_ k: AlignmentKey, at mySize: ViewSize) -> CGFloat? {
        layoutComputer.explicitAlignment(k, at: mySize)
    }

    /// The layout priority of the view, which influences layout decisions.
    ///
    /// Higher values indicate higher priority during layout calculations.
    package var layoutPriority: Double {
        layoutComputer.layoutPriority()
    }

    /// Indicates whether the view ignores automatic padding applied by container views.
    package var ignoresAutomaticPadding: Bool {
        layoutComputer.ignoresAutomaticPadding()
    }

    /// Indicates whether the view requires spacing projection during layout.
    package var requiresSpacingProjection: Bool {
        layoutComputer.requiresSpacingProjection()
    }
}

/// A collection of layout proxies that can be accessed by index.
///
/// `LayoutProxyCollection` provides random access to a collection of layout proxies,
/// each representing a different view or component in a layout hierarchy.
package struct LayoutProxyCollection: RandomAccessCollection {
    /// The rule context used to resolve attribute values.
    var context: AnyRuleContext

    /// The attributes for each layout proxy in the collection.
    var attributes: [LayoutProxyAttributes]

    /// Creates a layout proxy collection with the specified context and attributes.
    ///
    /// - Parameters:
    ///   - context: The rule context used to resolve attribute values.
    ///   - attributes: The array of attributes for each layout proxy.
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
