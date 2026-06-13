//
//  OverlayModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complte

public import Foundation
package import OpenAttributeGraphShims

// MARK: - makeSecondaryLayerView

package func makeSecondaryLayerView<SecondaryLayer>(
    secondaryLayer: Attribute<SecondaryLayer>,
    alignment: Attribute<Alignment>?,
    inputs: _ViewInputs,
    body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs,
    flipOrder: Bool
) -> _ViewOutputs where SecondaryLayer: View {
    var inputs = inputs
    inputs.base.pushStableIndex(0)
    let primaryOutputs = body(_Graph(), inputs)
    let layoutDirection = inputs.layoutDirection
    let geometry = Attribute(SecondaryLayerGeometryQuery(
        alignment: .init(alignment),
        layoutDirection: layoutDirection,
        primaryPosition: inputs.position,
        primarySize: inputs.size,
        primaryLayoutComputer: .init(primaryOutputs.layoutComputer),
        secondaryLayoutComputer: .init()
    ))
    inputs.position = geometry.origin()
    inputs.size = geometry.size()
    inputs.base.pushStableIndex(1)
    if Semantics.DepthWiseSecondaryLayers.isEnabled {
        inputs.implicitRootType = _ZStackLayout.self
    }
    let secondaryOutputs = SecondaryLayer.makeDebuggableView(view: .init(secondaryLayer), inputs: inputs)
    geometry.mutateBody(as: SecondaryLayerGeometryQuery.self, invalidating: true) { query in
        query.$secondaryLayoutComputer = secondaryOutputs.layoutComputer
    }
    var visitor = PairwisePreferenceCombinerVisitor(
        outputs: flipOrder ? (secondaryOutputs, primaryOutputs) : (primaryOutputs, secondaryOutputs)
    )
    for key in inputs.preferences.keys {
        key.visitKey(&visitor)
    }
    var result = visitor.result
    result.layoutComputer = primaryOutputs.layoutComputer
    return result
}

// MARK: - OverlayModifier

/// A modifier that layers a secondary view in front of the primary content it
/// modifies, while maintaining the layout characteristics of the primary view.
@available(OpenSwiftUI_v1_0, *)
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

@available(OpenSwiftUI_v1_0, *)
extension _OverlayModifier: Equatable where Overlay: Equatable {
    nonisolated public static func == (a: _OverlayModifier<Overlay>, b: _OverlayModifier<Overlay>) -> Bool {
        a.overlay == b.overlay && a.alignment == b.alignment
    }
}

// MARK: - OverlayStyleModifier

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _OverlayStyleModifier<Style>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Style: ShapeStyle {
    public var style: Style

    public var ignoresSafeAreaEdges: Edge.Set

    @inlinable
    public init(style: Style, ignoresSafeAreaEdges: Edge.Set) {
        self.style = style
        self.ignoresSafeAreaEdges = ignoresSafeAreaEdges
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        _BackgroundStyleModifier.makeShapeView(
            modifier: modifier.unsafeBitCast(to: _BackgroundStyleModifier<Style>.self),
            inputs: inputs,
            shapeIsBackground: false,
            body: body
        )
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension _OverlayStyleModifier: Sendable {}

// MARK: - OverlayShapeModifier

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _OverlayShapeModifier<Style, Bounds>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Style: ShapeStyle, Bounds: Shape {
    public var style: Style

    public var shape: Bounds

    public var fillStyle: FillStyle

    @inlinable
    public init(style: Style, shape: Bounds, fillStyle: FillStyle) {
        self.style = style
        self.shape = shape
        self.fillStyle = fillStyle
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        _BackgroundShapeModifier.makeShapeView(
            modifier: modifier.unsafeBitCast(to: _BackgroundShapeModifier<Style, Bounds>.self),
            inputs: inputs,
            shapeIsBackground: false,
            body: body
        )
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension _OverlayShapeModifier: Sendable {}

// MARK: - View + Overlay

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Layers a secondary view in front of this view.
    ///
    /// When you apply an overlay to a view, the original view continues to
    /// provide the layout characteristics for the resulting view. In the
    /// following example, the heart image is shown overlaid in front of, and
    /// aligned to the bottom of the folder image.
    ///
    ///     Image(systemName: "folder")
    ///         .font(.system(size: 55, weight: .thin))
    ///         .overlay(Text("❤️"), alignment: .bottom)
    ///
    /// ![View showing placement of a heart overlaid onto a folder
    /// icon.](View-overlay-1)
    ///
    /// - Parameters:
    ///   - overlay: The view to layer in front of this view.
    ///   - alignment: The alignment for `overlay` in relation to this view.
    ///
    /// - Returns: A view that layers `overlay` in front of the view.
    @available(*, deprecated, message: "Use `overlay(alignment:content:)` instead.")
    @inlinable
    @_disfavoredOverload
    nonisolated public func overlay<Overlay>(_ overlay: Overlay, alignment: Alignment = .center) -> some View where Overlay: View {
        modifier(_OverlayModifier(overlay: overlay, alignment: alignment))
    }

    /// Adds a border to this view with the specified style and width.
    ///
    /// Use this modifier to draw a border of a specified width around the
    /// view's frame. By default, the border appears inside the bounds of this
    /// view. For example, you can add a four-point wide border covers the text:
    ///
    ///     Text("Purple border inside the view bounds.")
    ///         .border(Color.purple, width: 4)
    ///
    /// ![A screenshot showing the text Purple border inside the view bounds.
    /// The text is surrounded by a purple border that outlines the text,
    /// but isn't quite big enough and encroaches on the text.](View-border-1)
    ///
    /// To place a border around the outside of this view, apply padding of the
    /// same width before adding the border:
    ///
    ///     Text("Purple border outside the view bounds.")
    ///         .padding(4)
    ///         .border(Color.purple, width: 4)
    ///
    /// ![A screenshot showing the text Purple border outside the view bounds.
    /// The text is surrounded by a purple border that outlines the text
    /// without touching the text.](View-border-2)
    ///
    /// - Parameters:
    ///   - content: A value that conforms to the ``ShapeStyle`` protocol,
    ///     like a ``Color`` or ``HierarchicalShapeStyle``, that OpenSwiftUI
    ///     uses to fill the border.
    ///   - width: The thickness of the border. The default is 1 pixel.
    ///
    /// - Returns: A view that adds a border with the specified style and width
    ///   to this view.
    @inlinable
    nonisolated public func border<S>(_ content: S, width: CGFloat = 1) -> some View where S: ShapeStyle {
        overlay(Rectangle().strokeBorder(content, lineWidth: width))
    }
}

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
        modifier(_OverlayModifier(overlay: content(), alignment: alignment))
    }

    /// Layers the specified style in front of this view.
    ///
    /// Use this modifier to layer a type that conforms to the ``ShapeStyle``
    /// protocol, like a ``Color``, ``Material``, or ``HierarchicalShapeStyle``,
    /// in front of a view. For example, you can overlay the
    /// ``ShapeStyle/ultraThinMaterial`` over a ``Circle``:
    ///
    ///     struct CoveredCircle: View {
    ///         var body: some View {
    ///             Circle()
    ///                 .frame(width: 300, height: 200)
    ///                 .overlay(.ultraThinMaterial)
    ///         }
    ///     }
    ///
    /// OpenSwiftUI anchors the style to the view's bounds. For the example above,
    /// the overlay fills the entirety of the circle's frame (which happens
    /// to be wider than the circle is tall):
    ///
    /// ![A screenshot of a circle showing through a rectangle that imposes
    /// a blurring effect.](View-overlay-5)
    ///
    /// OpenSwiftUI also limits the style's extent to the view's
    /// container-relative shape. You can see this effect if you constrain the
    /// `CoveredCircle` view with a ``View/containerShape(_:)`` modifier:
    ///
    ///     CoveredCircle()
    ///         .containerShape(RoundedRectangle(cornerRadius: 30))
    ///
    /// The overlay takes on the specified container shape:
    ///
    /// ![A screenshot of a circle showing through a rounded rectangle that
    /// imposes a blurring effect.](View-overlay-6)
    ///
    /// By default, the overlay ignores safe area insets on all edges, but you
    /// can provide a specific set of edges to ignore, or an empty set to
    /// respect safe area insets on all edges:
    ///
    ///     Rectangle()
    ///         .overlay(
    ///             .secondary,
    ///             ignoresSafeAreaEdges: []) // Ignore no safe area insets.
    ///
    /// If you want to specify a ``View`` or a stack of views as the overlay
    /// rather than a style, use ``View/overlay(alignment:content:)`` instead.
    /// If you want to specify a ``Shape``, use
    /// ``View/overlay(_:in:fillStyle:)``.
    ///
    /// - Parameters:
    ///   - style: An instance of a type that conforms to ``ShapeStyle`` that
    ///     OpenSwiftUI layers in front of the modified view.
    ///   - edges: The set of edges for which to ignore safe area insets
    ///     when adding the overlay. The default value is ``Edge/Set/all``.
    ///     Specify an empty set to respect safe area insets on all edges.
    ///
    /// - Returns: A view with the specified style drawn in front of it.
    @inlinable
    nonisolated public func overlay<S>(_ style: S, ignoresSafeAreaEdges edges: Edge.Set = .all) -> some View where S: ShapeStyle {
        modifier(_OverlayStyleModifier(style: style, ignoresSafeAreaEdges: edges))
    }

    /// Layers a shape that you specify in front of this view.
    ///
    /// Use this modifier to layer a type that conforms to the ``Shape``
    /// protocol --- like a ``Rectangle``, ``Circle``, or ``Capsule`` --- in
    /// front of a view. Specify a ``ShapeStyle`` that's used to fill the shape.
    /// For example, you can overlay the outline of one rectangle in front of
    /// another:
    ///
    ///     Rectangle()
    ///         .frame(width: 200, height: 100)
    ///         .overlay(.teal, in: Rectangle().inset(by: 10).stroke(lineWidth: 5))
    ///
    /// The example above uses the ``InsettableShape/inset(by:)`` method to
    /// slightly reduce the size of the overlaid rectangle, and the
    /// ``Shape/stroke(lineWidth:)`` method to fill only the shape's outline.
    /// This creates an inset border:
    ///
    /// ![A screenshot of a rectangle with a teal border that's
    /// inset from the edge.](View-overlay-7)
    ///
    /// This modifier is a convenience method for layering a shape over a view.
    /// To handle the more general case of overlaying a ``View`` --- or a stack
    /// of views --- with control over the position, use
    /// ``View/overlay(alignment:content:)`` instead. To cover a view with a
    /// ``ShapeStyle``, use ``View/overlay(_:ignoresSafeAreaEdges:)``.
    ///
    /// - Parameters:
    ///   - style: A ``ShapeStyle`` that OpenSwiftUI uses to fill the shape
    ///     that you specify.
    ///   - shape: An instance of a type that conforms to ``Shape`` that
    ///     OpenSwiftUI draws in front of the view.
    ///   - fillStyle: The ``FillStyle`` to use when drawing the shape.
    ///     The default style uses the nonzero winding number rule and
    ///     antialiasing.
    ///
    /// - Returns: A view with the specified shape drawn in front of it.
    @inlinable
    nonisolated public func overlay<S, T>(_ style: S, in shape: T, fillStyle: FillStyle = FillStyle()) -> some View where S: ShapeStyle, T: Shape {
        modifier(_OverlayShapeModifier(style: style, shape: shape, fillStyle: fillStyle))
    }
}

// MARK: - SecondaryLayerGeometryQuery

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
