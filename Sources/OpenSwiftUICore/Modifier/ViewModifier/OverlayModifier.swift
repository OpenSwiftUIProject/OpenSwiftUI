//
//  OverlayModifier.swift
//  OpenSwiftUICore
//
//  Status: WIP

package import OpenGraphShims

// MARK: - makeSecondaryLayerView [6.4.41] [WIP]

package func makeSecondaryLayerView<SecondaryLayer>(
    secondaryLayer: Attribute<SecondaryLayer>,
    alignment: Attribute<Alignment>?,
    inputs: _ViewInputs,
    body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs,
    flipOrder: Bool
) -> _ViewOutputs where SecondaryLayer: View {
    preconditionFailure("TODO")
}

// MARK: - OverlayModifier [6.4.41]

/// A modifier that layers a secondary view in front of the primary content it
/// modifies, while maintaining the layout characteristics of the primary view.
@frozen
public struct _OverlayModifier<Overlay>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Overlay: View {
    public var overlay: Overlay

    public var alignment: Alignment

    /// Creates an instance that adds `overlay` as a secondary layer in front of
    /// its primary content.
    @inlinable
    public init(overlay: Overlay, alignment: Alignment = .center) {
        self.overlay = overlay
        self.alignment = alignment
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<_OverlayModifier<Overlay>>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeSecondaryLayerView(
            secondaryLayer: modifier[offset: { .of(&$0.overlay) }].value,
            alignment: modifier[offset: { .of(&$0.alignment) }].value,
            inputs: inputs,
            body: body,
            flipOrder: false
        )
    }
}

@available(*, unavailable)
extension _OverlayModifier: Sendable {}

// TODO

// MARK: - View + Overlay [6.4.41] [WIP]

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Layers the views that you specify in front of this view.
    ///
    /// Use this modifier to place one or more views in front of another view.
    /// For example, you can place a group of stars on a ``RoundedRectangle``:
    ///
    ///     RoundedRectangle(cornerRadius: 8)
    ///         .frame(width: 200, height: 100)
    ///         .overlay(alignment: .topLeading) { Star(color: .red) }
    ///         .overlay(alignment: .topTrailing) { Star(color: .yellow) }
    ///         .overlay(alignment: .bottomLeading) { Star(color: .green) }
    ///         .overlay(alignment: .bottomTrailing) { Star(color: .blue) }
    ///
    /// The example above assumes that you've defined a `Star` view with a
    /// parameterized color:
    ///
    ///     struct Star: View {
    ///         var color = Color.yellow
    ///
    ///         var body: some View {
    ///             Image(systemName: "star.fill")
    ///                 .foregroundStyle(color)
    ///         }
    ///     }
    ///
    /// By setting different `alignment` values for each modifier, you make the
    /// stars appear in different places on the rectangle:
    ///
    /// ![A screenshot of a rounded rectangle with a star in each corner. The
    /// star in the upper-left is red; the start in the upper-right is yellow;
    /// the star in the lower-left is green; the star in the lower-right is
    /// blue.](View-overlay-2)
    ///
    /// If you specify more than one view in the `content` closure, the modifier
    /// collects all of the views in the closure into an implicit ``ZStack``,
    /// taking them in order from back to front. For example, you can place a
    /// star and a ``Circle`` on a field of ``ShapeStyle/blue``:
    ///
    ///     Color.blue
    ///         .frame(width: 200, height: 200)
    ///         .overlay {
    ///             Circle()
    ///                 .frame(width: 100, height: 100)
    ///             Star()
    ///         }
    ///
    /// Both the overlay modifier and the implicit ``ZStack`` composed from the
    /// overlay content --- the circle and the star --- use a default
    /// ``Alignment/center`` alignment. The star appears centered on the circle,
    /// and both appear as a composite view centered in front of the square:
    ///
    /// ![A screenshot of a star centered on a circle, which is
    /// centered on a square.](View-overlay-3)
    ///
    /// If you specify an alignment for the overlay, it applies to the implicit
    /// stack rather than to the individual views in the closure. You can see
    /// this if you add the ``Alignment/bottom`` alignment:
    ///
    ///     Color.blue
    ///         .frame(width: 200, height: 200)
    ///         .overlay(alignment: .bottom) {
    ///             Circle()
    ///                 .frame(width: 100, height: 100)
    ///             Star()
    ///         }
    ///
    /// The circle and the star move down as a unit to align the stack's bottom
    /// edge with the bottom edge of the square, while the star remains
    /// centered on the circle:
    ///
    /// ![A screenshot of a star centered on a circle, which is on a square.
    /// The circle's bottom edge is aligned with the square's bottom
    /// edge.](View-overlay-3a)
    ///
    /// To control the placement of individual items inside the `content`
    /// closure, either use a different overlay modifier for each item, as the
    /// earlier example of stars in the corners of a rectangle demonstrates, or
    /// add an explicit ``ZStack`` inside the content closure with its own
    /// alignment:
    ///
    ///     Color.blue
    ///         .frame(width: 200, height: 200)
    ///         .overlay(alignment: .bottom) {
    ///             ZStack(alignment: .bottom) {
    ///                 Circle()
    ///                     .frame(width: 100, height: 100)
    ///                 Star()
    ///             }
    ///         }
    ///
    /// The stack alignment ensures that the star's bottom edge aligns with the
    /// circle's, while the overlay aligns the composite view with the square:
    ///
    /// ![A screenshot of a star, a circle, and a square with all their
    /// bottom edges aligned.](View-overlay-4)
    ///
    /// You can achieve layering without an overlay modifier by putting both the
    /// modified view and the overlay content into a ``ZStack``. This can
    /// produce a simpler view hierarchy, but changes the layout priority that
    /// OpenSwiftUI applies to the views. Use the overlay modifier when you want the
    /// modified view to dominate the layout.
    ///
    /// If you want to specify a ``ShapeStyle`` like a ``Color`` or a
    /// ``Material`` as the overlay, use
    /// ``View/overlay(_:ignoresSafeAreaEdges:)`` instead. To specify a
    /// ``Shape``, use ``View/overlay(_:in:fillStyle:)``.
    ///
    /// - Parameters:
    ///   - alignment: The alignment that the modifier uses to position the
    ///     implicit ``ZStack`` that groups the foreground views. The default
    ///     is ``Alignment/center``.
    ///   - content: A ``ViewBuilder`` that you use to declare the views to
    ///     draw in front of this view, stacked in the order that you list them.
    ///     The last view that you list appears at the front of the stack.
    ///
    /// - Returns: A view that uses the specified content as a foreground.
    @inlinable
    nonisolated public func overlay<V>(alignment: Alignment = .center, @ViewBuilder content: () -> V) -> some View where V: View {
        modifier(_BackgroundModifier(background: content(), alignment: alignment))
    }
}

// MARK: - SecondaryLayerGeometryQuery [6.4.41]

package struct SecondaryLayerGeometryQuery: Rule, AsyncAttribute {
    @OptionalAttribute
    package var alignment: Alignment?

    @Attribute
    package var layoutDirection: LayoutDirection

    @Attribute
    package var primaryPosition: ViewOrigin

    @Attribute
    package var primarySize: ViewSize

    @OptionalAttribute
    package var primaryLayoutComputer: LayoutComputer?

    @OptionalAttribute
    package var secondaryLayoutComputer: LayoutComputer?

    package init(
        alignment: OptionalAttribute<Alignment>,
        layoutDirection: Attribute<LayoutDirection>,
        primaryPosition: Attribute<ViewOrigin>,
        primarySize: Attribute<ViewSize>,
        primaryLayoutComputer: OptionalAttribute<LayoutComputer> = .init(),
        secondaryLayoutComputer: OptionalAttribute<LayoutComputer> = .init()
    ) {
        _alignment = alignment
        _layoutDirection = layoutDirection
        _primaryPosition = primaryPosition
        _primarySize = primarySize
        _primaryLayoutComputer = primaryLayoutComputer
        _secondaryLayoutComputer = secondaryLayoutComputer
    }

    package var value: ViewGeometry {
        let primaryLayoutComputer = primaryLayoutComputer ?? .defaultValue
        let primaryDimensions = ViewDimensions(guideComputer: primaryLayoutComputer, size: primarySize)

        let alignment = alignment ?? .center
        let primaryPosition = primaryPosition

        let (primaryHorizontalAlignment, primaryVerticalAlignment) = primaryDimensions[alignment]

        let secondaryLayoutComputer = secondaryLayoutComputer ?? .defaultValue
        let proposal = primarySize.value
        let fittingSize = secondaryLayoutComputer.sizeThatFits(.init(proposal))
        let secondaryDimensions = ViewDimensions(guideComputer: secondaryLayoutComputer, size: ViewSize(value: fittingSize, proposal: proposal))
        let (secondaryHorizontalAlignment, secondaryVerticalAlignment) = secondaryDimensions[alignment]
        
        var geometry = ViewGeometry(
            origin: primaryPosition
                + CGSize(width: primaryHorizontalAlignment, height: primaryVerticalAlignment)
                - CGSize(width: secondaryHorizontalAlignment, height: secondaryVerticalAlignment),
            dimensions: secondaryDimensions
        )
        if layoutDirection == .rightToLeft {
            let primaryHorizontalAlignmentCenter = primaryDimensions[HorizontalAlignment.center]
            let secondaryHorizontalAlignmentCenter = secondaryDimensions[HorizontalAlignment.center]
            let mirroredCenterX = primaryPosition.x + primaryHorizontalAlignmentCenter - secondaryHorizontalAlignmentCenter
            let horizontalOffset = mirroredCenterX - geometry.origin.x
            geometry.origin.x = mirroredCenterX + horizontalOffset
        }
        return geometry
    }
}
