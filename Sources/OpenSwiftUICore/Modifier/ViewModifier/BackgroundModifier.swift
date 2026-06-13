//
//  BackgroundModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4F6988968057BB8D11F78AD2EE32ACB1 (SwiftUICore)

package import Foundation
import OpenAttributeGraphShims

// MARK: - BackgroundModifier

/// A modifier that layers a secondary view behind the primary content it
/// modifies, while maintaining the layout characteristics of the primary view.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _BackgroundModifier<Background>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Background: View {
    public var background: Background

    public var alignment: Alignment

    /// Creates an instance that adds `background` as a secondary layer behind
    /// its primary content.
    @inlinable
    public init(background: Background, alignment: Alignment = .center) {
        self.background = background
        self.alignment = alignment
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeSecondaryLayerView(
            secondaryLayer: modifier[offset: { .of(&$0.background) }].value,
            alignment: modifier[offset: { .of(&$0.alignment) }].value,
            inputs: inputs,
            body: body,
            flipOrder: true
        )
    }
}

@available(*, unavailable)
extension _BackgroundModifier: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension _BackgroundModifier: Equatable where Background: Equatable {
    nonisolated public static func == (a: _BackgroundModifier<Background>, b: _BackgroundModifier<Background>) -> Bool {
        a.background == b.background && a.alignment == b.alignment
    }
}

// MARK: - BackgroundStyleModifier

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _BackgroundStyleModifier<Style>: ViewModifier, MultiViewModifier, PrimitiveViewModifier, ShapeStyledLeafView where Style: ShapeStyle {
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
        makeShapeView(
            modifier: modifier,
            inputs: inputs,
            shapeIsBackground: true,
            body: body
        )
    }

    nonisolated package static func makeShapeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        shapeIsBackground: Bool,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let backgroundInfo = Attribute(BackgroundInfo(
            modifier: modifier.value,
            environment: inputs.environment,
            size: inputs.size,
            position: inputs.position,
            transform: inputs.transform,
            safeAreaInsets: inputs.safeAreaInsets
        ))
        var secondaryInputs = inputs
        secondaryInputs.implicitRootType = _ZStackLayout.self
        secondaryInputs.position = backgroundInfo[offset: { .of(&$0.frame.origin) }]
        secondaryInputs.size = backgroundInfo[offset: { .of(&$0.frame.size) }]
        let styles = Attribute(ShapeStyleResolver(
            style: .init(backgroundInfo[offset: { .of(&$0.style) }]),
            mode: .init(),
            environment: inputs.environment,
            role: .fill,
            animationsDisabled: inputs.base.animationsDisabled,
            helper: .init(
                phase: inputs.viewPhase,
                time: inputs.time,
                transaction: inputs.transaction
            )
        ))
        styles.flags = .transactional
        var primaryInputs = inputs
        if shapeIsBackground {
            primaryInputs.applyBackgroundStyle(
                value: modifier.value,
                offset: .offset { .of(&$0.style) }
            )
        }
        let primaryOutputs = body(_Graph(), primaryInputs)
        let secondaryOutputs = makeLeafView(
            view: modifier,
            inputs: secondaryInputs,
            styles: styles
        )
        var visitor = PairwisePreferenceCombinerVisitor(
            outputs: shapeIsBackground ? (secondaryOutputs, primaryOutputs) : (primaryOutputs, secondaryOutputs)
        )
        for key in primaryInputs.preferences.keys {
            key.visitKey(&visitor)
        }
        var result = visitor.result
        result.layoutComputer = primaryOutputs.layoutComputer
        return result
    }

    package func shape(in size: CGSize) -> FramedShape {
        let rect = CGRect(origin: .zero, size: size)
        return (
            shape: .path(ImplicitContainerShape().path(in: rect), FillStyle()),
            frame: rect
        )
    }

    private struct BackgroundInfo: Rule, AsyncAttribute {
        @Attribute var modifier: _BackgroundStyleModifier<Style>
        @Attribute var environment: EnvironmentValues
        @Attribute var size: ViewSize
        @Attribute var position: ViewOrigin
        @Attribute var transform: ViewTransform
        @OptionalAttribute var safeAreaInsets: SafeAreaInsets?

        var value: Value {
            var result = Value(
                frame: ViewFrame(origin: position, size: size),
                style: _AnchoredShapeStyle(
                    style: modifier.style,
                    bounds: CGRect(origin: .zero, size: size.value)
                )
            )
            let edges = modifier.ignoresSafeAreaEdges
            if !edges.isEmpty {
                let context = AnyRuleContext(context)
                var insets = EdgeInsets.zero
                if let safeAreaInsetsAttribute = $safeAreaInsets {
                    insets = context[safeAreaInsetsAttribute].resolve(
                        regions: .background,
                        in: _PositionAwarePlacementContext(
                            context: context,
                            size: _size,
                            environment: _environment,
                            transform: _transform,
                            position: _position,
                            safeAreaInsets: _safeAreaInsets
                        )
                    ).in(edges)
                }
                let offset = insets.originOffset
                result.style.bounds.origin += offset
                result.frame.origin -= offset
                result.frame.size.value = result.frame.size.value.outset(by: insets)
            }
            return result
        }

        struct Value {
            var frame: ViewFrame
            var style: _AnchoredShapeStyle<Style>

            init(frame: ViewFrame, style: _AnchoredShapeStyle<Style>) {
                self.frame = frame
                self.style = style
            }
        }
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension _BackgroundStyleModifier: Sendable {}

// MARK: - BackgroundShapeModifier

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _BackgroundShapeModifier<Style, Bounds>: ViewModifier, MultiViewModifier, PrimitiveViewModifier, ShapeStyledLeafView where Style: ShapeStyle, Bounds: Shape {
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
        makeShapeView(
            modifier: modifier,
            inputs: inputs,
            shapeIsBackground: true,
            body: body
        )
    }

    nonisolated static func makeShapeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        shapeIsBackground: Bool,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs,
        modifyPrimaryInputs: (inout _ViewInputs, Attribute<Bounds>) -> Void = { _, _ in }
    ) -> _ViewOutputs {
        var secondaryInputs = inputs
        secondaryInputs.implicitRootType = _ZStackLayout.self
        let styles = Attribute(ShapeStyleResolver(
            style: .init(modifier[offset: { .of(&$0.style) }].value),
            mode: .init(),
            environment: inputs.environment,
            role: Bounds.role,
            animationsDisabled: inputs.base.animationsDisabled,
            helper: .init(
                phase: inputs.viewPhase,
                time: inputs.time,
                transaction: inputs.transaction
            )
        ))
        styles.flags = .transactional
        let secondaryOutputs: _ViewOutputs
        let shape: Attribute<Bounds>
        if MemoryLayout<Bounds.AnimatableData>.size == 0 {
            secondaryOutputs = makeLeafView(
                view: modifier,
                inputs: secondaryInputs,
                styles: styles
            )
            shape = modifier[offset: { .of(&$0.shape) }].value
        } else {
            shape = Bounds.makeAnimatable(
                value: modifier[offset: { .of(&$0.shape) }],
                inputs: inputs.base
            )
            let fillStyle = modifier[offset: { .of(&$0.fillStyle) }].value
            let animatedShape = _GraphValue(AnimatedShape<Bounds>.Init(
                shape: shape,
                fillStyle: fillStyle
            ))
            secondaryOutputs = AnimatedShape<Bounds>.makeLeafView(
                view: animatedShape,
                inputs: secondaryInputs,
                styles: styles
            )
        }
        var primaryInputs = inputs
        if shapeIsBackground {
            primaryInputs.applyBackgroundStyle(
                value: modifier.value,
                offset: .offset { .of(&$0.style) }
            )
        }
        modifyPrimaryInputs(&primaryInputs, shape)
        let primaryOutputs = body(_Graph(), primaryInputs)
        var visitor = PairwisePreferenceCombinerVisitor(
            outputs: shapeIsBackground ? (secondaryOutputs, primaryOutputs) : (primaryOutputs, secondaryOutputs)
        )
        for key in primaryInputs.preferences.keys {
            key.visitKey(&visitor)
        }
        var result = visitor.result
        result.layoutComputer = primaryOutputs.layoutComputer
        return result
    }

    package func shape(in size: CGSize) -> FramedShape {
        let rect = CGRect(origin: .zero, size: size)
        return (
            shape: .path(shape.effectivePath(in: rect), fillStyle),
            frame: rect
        )
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension _BackgroundShapeModifier: Sendable {}

// MARK: - InsettableBackgroundShapeModifier

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _InsettableBackgroundShapeModifier<Style, Bounds>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Style: ShapeStyle, Bounds: InsettableShape {
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
            shapeIsBackground: true,
            body: body
        ) { inputs, shape in
            inputs.setContainerShape(shape, isSystemShape: false)
        }
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension _InsettableBackgroundShapeModifier: Sendable {}

// MARK: - View + Background

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Layers the given view behind this view.
    ///
    /// Use `background(_:alignment:)` when you need to place one view behind
    /// another, with the background view optionally aligned with a specified
    /// edge of the frontmost view.
    ///
    /// The example below creates two views: the `Frontmost` view, and the
    /// `DiamondBackground` view. The `Frontmost` view uses the
    /// `DiamondBackground` view for the background of the image element inside
    /// the `Frontmost` view's ``VStack``.
    ///
    ///     struct DiamondBackground: View {
    ///         var body: some View {
    ///             VStack {
    ///                 Rectangle()
    ///                     .fill(.gray)
    ///                     .frame(width: 250, height: 250, alignment: .center)
    ///                     .rotationEffect(.degrees(45.0))
    ///             }
    ///         }
    ///     }
    ///
    ///     struct Frontmost: View {
    ///         var body: some View {
    ///             VStack {
    ///                 Image(systemName: "folder")
    ///                     .font(.system(size: 128, weight: .ultraLight))
    ///                     .background(DiamondBackground())
    ///             }
    ///         }
    ///     }
    ///
    /// ![A view showing a large folder image with a gray diamond placed behind
    /// it as its background view.](View-background-1)
    ///
    /// - Parameters:
    ///   - background: The view to draw behind this view.
    ///   - alignment: The alignment with a default value of
    ///     ``Alignment/center`` that you use to position the background view.
    @available(*, deprecated, message: "Use `background(alignment:content:)` instead.")
    @inlinable
    @_disfavoredOverload
    nonisolated public func background<Background>(_ background: Background, alignment: Alignment = .center) -> some View where Background: View {
        modifier(_BackgroundModifier(background: background, alignment: alignment))
    }

}

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Layers the views that you specify behind this view.
    ///
    /// Use this modifier to place one or more views behind another view.
    /// For example, you can place a collection of stars behind a ``Text`` view:
    ///
    ///     Text("ABCDEF")
    ///         .background(alignment: .leading) { Star(color: .red) }
    ///         .background(alignment: .center) { Star(color: .green) }
    ///         .background(alignment: .trailing) { Star(color: .blue) }
    ///
    /// The example above assumes that you've defined a `Star` view with a
    /// parameterized color:
    ///
    ///     struct Star: View {
    ///         var color: Color
    ///
    ///         var body: some View {
    ///             Image(systemName: "star.fill")
    ///                 .foregroundStyle(color)
    ///         }
    ///     }
    ///
    /// By setting different `alignment` values for each modifier, you make the
    /// stars appear in different places behind the text:
    ///
    /// ![A screenshot of the letters A, B, C, D, E, and F written in front of
    /// three stars. The stars, from left to right, are red, green, and
    /// blue.](View-background-2)
    ///
    /// If you specify more than one view in the `content` closure, the modifier
    /// collects all of the views in the closure into an implicit ``ZStack``,
    /// taking them in order from back to front. For example, you can layer a
    /// vertical bar behind a circle, with both of those behind a horizontal
    /// bar:
    ///
    ///     Color.blue
    ///         .frame(width: 200, height: 10) // Creates a horizontal bar.
    ///         .background {
    ///             Color.green
    ///                 .frame(width: 10, height: 100) // Creates a vertical bar.
    ///             Circle()
    ///                 .frame(width: 50, height: 50)
    ///         }
    ///
    /// Both the background modifier and the implicit ``ZStack`` composed from
    /// the background content --- the circle and the vertical bar --- use a
    /// default ``Alignment/center`` alignment. The vertical bar appears
    /// centered behind the circle, and both appear as a composite view centered
    /// behind the horizontal bar:
    ///
    /// ![A screenshot of a circle with a horizontal blue bar layered on top
    /// and a vertical green bar layered underneath. All of the items are center
    /// aligned.](View-background-3)
    ///
    /// If you specify an alignment for the background, it applies to the
    /// implicit stack rather than to the individual views in the closure. You
    /// can see this if you add the ``Alignment/leading`` alignment:
    ///
    ///     Color.blue
    ///         .frame(width: 200, height: 10)
    ///         .background(alignment: .leading) {
    ///             Color.green
    ///                 .frame(width: 10, height: 100)
    ///             Circle()
    ///                 .frame(width: 50, height: 50)
    ///         }
    ///
    /// The vertical bar and the circle move as a unit to align the stack
    /// with the leading edge of the horizontal bar, while the
    /// vertical bar remains centered on the circle:
    ///
    /// ![A screenshot of a horizontal blue bar in front of a circle, which
    /// is in front of a vertical green bar. The horizontal bar and the circle
    /// are center aligned with each other; the left edges of the circle
    /// and the horizontal are aligned.](View-background-3a)
    ///
    /// To control the placement of individual items inside the `content`
    /// closure, either use a different background modifier for each item, as
    /// the earlier example of stars under text demonstrates, or add an explicit
    /// ``ZStack`` inside the content closure with its own alignment:
    ///
    ///     Color.blue
    ///         .frame(width: 200, height: 10)
    ///         .background(alignment: .leading) {
    ///             ZStack(alignment: .leading) {
    ///                 Color.green
    ///                     .frame(width: 10, height: 100)
    ///                 Circle()
    ///                     .frame(width: 50, height: 50)
    ///             }
    ///         }
    ///
    /// The stack alignment ensures that the circle's leading edge aligns with
    /// the vertical bar's, while the background modifier aligns the composite
    /// view with the horizontal bar:
    ///
    /// ![A screenshot of a horizontal blue bar in front of a circle, which
    /// is in front of a vertical green bar. All items are aligned on their
    /// left edges.](View-background-4)
    ///
    /// You can achieve layering without a background modifier by putting both
    /// the modified view and the background content into a ``ZStack``. This
    /// produces a simpler view hierarchy, but it changes the layout priority
    /// that OpenSwiftUI applies to the views. Use the background modifier when you
    /// want the modified view to dominate the layout.
    ///
    /// If you want to specify a ``ShapeStyle`` like a
    /// ``HierarchicalShapeStyle`` or a ``Material`` as the background, use
    /// ``View/background(_:ignoresSafeAreaEdges:)`` instead.
    /// To specify a ``Shape`` or ``InsettableShape``, use
    /// ``View/background(_:in:fillStyle:)``.
    /// To configure the background of a presentation, like a sheet, use
    /// ``View/presentationBackground(alignment:content:)``.
    ///
    /// - Parameters:
    ///   - alignment: The alignment that the modifier uses to position the
    ///     implicit ``ZStack`` that groups the background views. The default
    ///     is ``Alignment/center``.
    ///   - content: A ``ViewBuilder`` that you use to declare the views to draw
    ///     behind this view, stacked in a cascading order from bottom to top.
    ///     The last view that you list appears at the front of the stack.
    ///
    /// - Returns: A view that uses the specified content as a background.
    @inlinable
    nonisolated public func background<V>(alignment: Alignment = .center, @ViewBuilder content: () -> V) -> some View where V: View {
        modifier(_BackgroundModifier(background: content(), alignment: alignment))
    }

    /// Sets the view's background to the default background style.
    ///
    /// This modifier behaves like ``View/background(_:ignoresSafeAreaEdges:)``,
    /// except that it always uses the ``ShapeStyle/background`` shape style.
    /// For example, you can add a background to a ``Label``:
    ///
    ///     ZStack {
    ///         Color.teal
    ///         Label("Flag", systemImage: "flag.fill")
    ///             .padding()
    ///             .background()
    ///     }
    ///
    /// Without the background modifier, the teal color behind the label shows
    /// through the label. With the modifier, the label's text and icon appear
    /// backed by a region filled with a color that's appropriate for light
    /// or dark appearance:
    ///
    /// ![A screenshot of a flag icon and the word flag inside a rectangle; the
    /// rectangle is filled with the background color and layered on top of a
    /// larger rectangle that's filled with the color teal.](View-background-7)
    ///
    /// If you want to specify a ``View`` or a stack of views as the background,
    /// use ``View/background(alignment:content:)`` instead.
    /// To specify a ``Shape`` or ``InsettableShape``, use
    /// ``View/background(_:in:fillStyle:)``.
    /// To configure the background of a presentation, like a sheet, use
    /// ``View/presentationBackground(_:)``.
    ///
    /// - Parameters:
    ///   - edges: The set of edges for which to ignore safe area insets
    ///     when adding the background. The default value is ``Edge/Set/all``.
    ///     Specify an empty set to respect safe area insets on all edges.
    ///
    /// - Returns: A view with the ``ShapeStyle/background`` shape style
    ///   drawn behind it.
    @inlinable
    nonisolated public func background(ignoresSafeAreaEdges edges: Edge.Set = .all) -> some View {
        modifier(_BackgroundStyleModifier(style: .background, ignoresSafeAreaEdges: edges))
    }

    /// Sets the view's background to a style.
    ///
    /// Use this modifier to place a type that conforms to the ``ShapeStyle``
    /// protocol --- like a ``Color``, ``Material``, or
    /// ``HierarchicalShapeStyle`` --- behind a view. For example, you can add
    /// the ``ShapeStyle/regularMaterial`` behind a ``Label``:
    ///
    ///     struct FlagLabel: View {
    ///         var body: some View {
    ///             Label("Flag", systemImage: "flag.fill")
    ///                 .padding()
    ///                 .background(.regularMaterial)
    ///         }
    ///     }
    ///
    /// OpenSwiftUI anchors the style to the view's bounds. For the example above,
    /// the background fills the entirety of the label's frame, which includes
    /// the padding:
    ///
    /// ![A screenshot of a flag symbol and the word flag layered over a
    /// gray rectangle.](View-background-5)
    ///
    /// OpenSwiftUI limits the background style's extent to the modified view's
    /// container-relative shape. You can see this effect if you constrain the
    /// `FlagLabel` view with a ``View/containerShape(_:)`` modifier:
    ///
    ///     FlagLabel()
    ///         .containerShape(RoundedRectangle(cornerRadius: 16))
    ///
    /// The background takes on the specified container shape:
    ///
    /// ![A screenshot of a flag symbol and the word flag layered over a
    /// gray rectangle with rounded corners.](View-background-6)
    ///
    /// By default, the background ignores safe area insets on all edges, but
    /// you can provide a specific set of edges to ignore, or an empty set to
    /// respect safe area insets on all edges:
    ///
    ///     Rectangle()
    ///         .background(
    ///             .regularMaterial,
    ///             ignoresSafeAreaEdges: []) // Ignore no safe area insets.
    ///
    /// If you want to specify a ``View`` or a stack of views as the background,
    /// use ``View/background(alignment:content:)`` instead.
    /// To specify a ``Shape`` or ``InsettableShape``, use
    /// ``View/background(_:in:fillStyle:)`` .
    /// To configure the background of a presentation, like a sheet, use
    /// ``View/presentationBackground(_:)``.
    ///
    /// - Parameters:
    ///   - style: An instance of a type that conforms to ``ShapeStyle`` that
    ///     OpenSwiftUI draws behind the modified view.
    ///   - edges: The set of edges for which to ignore safe area insets
    ///     when adding the background. The default value is ``Edge/Set/all``.
    ///     Specify an empty set to respect safe area insets on all edges.
    ///
    /// - Returns: A view with the specified style drawn behind it.
    @inlinable
    nonisolated public func background<S>(_ style: S, ignoresSafeAreaEdges edges: Edge.Set = .all) -> some View where S: ShapeStyle {
        modifier(_BackgroundStyleModifier(style: style, ignoresSafeAreaEdges: edges))
    }

    /// Sets the view's background to a shape filled with the
    /// default background style.
    ///
    /// This modifier behaves like ``View/background(_:in:fillStyle:)``,
    /// except that it always uses the ``ShapeStyle/background`` shape style
    /// to fill the specified shape. For example, you can create a ``Path``
    /// that outlines a trapezoid:
    ///
    ///     let trapezoid = Path { path in
    ///         path.move(to: .zero)
    ///         path.addLine(to: CGPoint(x: 90, y: 0))
    ///         path.addLine(to: CGPoint(x: 80, y: 50))
    ///         path.addLine(to: CGPoint(x: 10, y: 50))
    ///     }
    ///
    /// Then you can use that shape as a background for a ``Label``:
    ///
    ///     ZStack {
    ///         Color.teal
    ///         Label("Flag", systemImage: "flag.fill")
    ///             .padding()
    ///             .background(in: trapezoid)
    ///     }
    ///
    /// Without the background modifier, the fill color shows
    /// through the label. With the modifier, the label's text and icon appear
    /// backed by a shape filled with a color that's appropriate for light
    /// or dark appearance:
    ///
    /// ![A screenshot of a flag icon and the word flag inside a trapezoid; the
    /// trapezoid is filled with the background color and layered on top of
    /// a rectangle filled with the color teal.](View-background-B)
    ///
    /// To create a background with other ``View`` types --- or with a stack
    /// of views --- use ``View/background(alignment:content:)`` instead.
    /// To add a ``ShapeStyle`` as a background, use
    /// ``View/background(_:ignoresSafeAreaEdges:)``.
    ///
    /// - Parameters:
    ///   - shape: An instance of a type that conforms to ``Shape`` that
    ///     OpenSwiftUI draws behind the view using the ``ShapeStyle/background``
    ///     shape style.
    ///   - fillStyle: The ``FillStyle`` to use when drawing the shape.
    ///     The default style uses the nonzero winding number rule and
    ///     antialiasing.
    ///
    /// - Returns: A view with the specified shape drawn behind it.
    @inlinable
    nonisolated public func background<S>(in shape: S, fillStyle: FillStyle = FillStyle()) -> some View where S: Shape {
        modifier(_BackgroundShapeModifier(style: .background, shape: shape, fillStyle: fillStyle))
    }

    /// Sets the view's background to a shape filled with a style.
    ///
    /// Use this modifier to layer a type that conforms to the ``Shape``
    /// protocol behind a view. Specify the ``ShapeStyle`` that's used to
    /// fill the shape. For example, you can create a ``Path`` that outlines
    /// a trapezoid:
    ///
    ///     let trapezoid = Path { path in
    ///         path.move(to: .zero)
    ///         path.addLine(to: CGPoint(x: 90, y: 0))
    ///         path.addLine(to: CGPoint(x: 80, y: 50))
    ///         path.addLine(to: CGPoint(x: 10, y: 50))
    ///     }
    ///
    /// Then you can use that shape as a background for a ``Label``:
    ///
    ///     Label("Flag", systemImage: "flag.fill")
    ///         .padding()
    ///         .background(.teal, in: trapezoid)
    ///
    /// The ``ShapeStyle/teal`` color fills the shape:
    ///
    /// ![A screenshot of the flag icon and the word flag inside a trapezoid;
    /// The trapezoid is filled with the color teal.](View-background-A)
    ///
    /// This modifier is a convenience method for placing a single shape behind a view. To
    /// create a background with other ``View`` types --- or with a stack
    /// of views --- use ``View/background(alignment:content:)`` instead.
    /// To add a ``ShapeStyle`` as a background, use
    /// ``View/background(_:ignoresSafeAreaEdges:)``.
    ///
    /// - Parameters:
    ///   - style: A ``ShapeStyle`` that OpenSwiftUI uses to the fill the shape
    ///     that you specify.
    ///   - shape: An instance of a type that conforms to ``Shape`` that
    ///     OpenSwiftUI draws behind the view.
    ///   - fillStyle: The ``FillStyle`` to use when drawing the shape.
    ///     The default style uses the nonzero winding number rule and
    ///     antialiasing.
    ///
    /// - Returns: A view with the specified shape drawn behind it.
    @inlinable
    nonisolated public func background<S, T>(_ style: S, in shape: T, fillStyle: FillStyle = FillStyle()) -> some View where S: ShapeStyle, T: Shape {
        modifier(_BackgroundShapeModifier(style: style, shape: shape, fillStyle: fillStyle))
    }

    /// Sets the view's background to an insettable shape filled with the
    /// default background style.
    ///
    /// This modifier behaves like ``View/background(_:in:fillStyle:)``,
    /// except that it always uses the ``ShapeStyle/background`` shape style
    /// to fill the specified insettable shape. For example, you can use
    /// a ``RoundedRectangle`` as a background on a ``Label``:
    ///
    ///     ZStack {
    ///         Color.teal
    ///         Label("Flag", systemImage: "flag.fill")
    ///             .padding()
    ///             .background(in: RoundedRectangle(cornerRadius: 8))
    ///     }
    ///
    /// Without the background modifier, the fill color shows
    /// through the label. With the modifier, the label's text and icon appear
    /// backed by a shape filled with a color that's appropriate for light
    /// or dark appearance:
    ///
    /// ![A screenshot of a flag icon and the word flag inside a rectangle with
    /// rounded corners; the rectangle is filled with the background color, and
    /// is layered on top of a larger rectangle that's filled with the color
    /// teal.](View-background-9)
    ///
    /// To create a background with other ``View`` types --- or with a stack
    /// of views --- use ``View/background(alignment:content:)`` instead.
    /// To add a ``ShapeStyle`` as a background, use
    /// ``View/background(_:ignoresSafeAreaEdges:)``.
    ///
    /// - Parameters:
    ///   - shape: An instance of a type that conforms to ``InsettableShape``
    ///     that OpenSwiftUI draws behind the view using the
    ///     ``ShapeStyle/background`` shape style.
    ///   - fillStyle: The ``FillStyle`` to use when drawing the shape.
    ///     The default style uses the nonzero winding number rule and
    ///     antialiasing.
    ///
    /// - Returns: A view with the specified insettable shape drawn behind it.
    @inlinable
    nonisolated public func background<S>(in shape: S, fillStyle: FillStyle = FillStyle()) -> some View where S: InsettableShape {
        modifier(_InsettableBackgroundShapeModifier(style: .background, shape: shape, fillStyle: fillStyle))
    }

    /// Sets the view's background to an insettable shape filled with a style.
    ///
    /// Use this modifier to layer a type that conforms to the
    /// ``InsettableShape`` protocol --- like a ``Rectangle``, ``Circle``, or
    /// ``Capsule`` --- behind a view. Specify the ``ShapeStyle`` that's used to
    /// fill the shape. For example, you can place a ``RoundedRectangle``
    /// behind a ``Label``:
    ///
    ///     Label("Flag", systemImage: "flag.fill")
    ///         .padding()
    ///         .background(.teal, in: RoundedRectangle(cornerRadius: 8))
    ///
    /// The ``ShapeStyle/teal`` color fills the shape:
    ///
    /// ![A screenshot of the flag icon and word on a teal rectangle with
    /// rounded corners.](View-background-8)
    ///
    /// This modifier is a convenience method for placing a single shape behind a view. To
    /// create a background with other ``View`` types --- or with a stack
    /// of views --- use ``View/background(alignment:content:)`` instead.
    /// To add a ``ShapeStyle`` as a background, use
    /// ``View/background(_:ignoresSafeAreaEdges:)``.
    ///
    /// - Parameters:
    ///   - style: A ``ShapeStyle`` that OpenSwiftUI uses to the fill the shape
    ///     that you specify.
    ///   - shape: An instance of a type that conforms to ``InsettableShape``
    ///     that OpenSwiftUI draws behind the view.
    ///   - fillStyle: The ``FillStyle`` to use when drawing the shape.
    ///     The default style uses the nonzero winding number rule and
    ///     antialiasing.
    ///
    /// - Returns: A view with the specified insettable shape drawn behind it.
    @inlinable
    nonisolated public func background<S, T>(_ style: S, in shape: T, fillStyle: FillStyle = FillStyle()) -> some View where S: ShapeStyle, T: InsettableShape {
        modifier(_InsettableBackgroundShapeModifier(style: style, shape: shape, fillStyle: fillStyle))
    }
}

// MARK: - _ViewInputs + applyBackgroundStyle

@available(OpenSwiftUI_v3_0, *)
package struct ImplicitContainerShape: Shape {
    package init() {}

    nonisolated package func path(in rect: CGRect) -> Path {
        Path(rect)
    }

    nonisolated package var layoutDirectionBehavior: LayoutDirectionBehavior {
        .fixed
    }
}

extension _ViewInputs {
    fileprivate mutating func applyBackgroundStyle<Value, Style>(
        value: Attribute<Value>,
        offset: PointerOffset<Value, Style>
    ) where Style: ShapeStyle {
        var type = _ShapeStyle_ShapeType(operation: .modifiesBackground, result: .none)
        Style._apply(to: &type)
        guard case .bool(true) = type.result else {
            return
        }
        environment = Attribute(ForegroundEnvironment(
            style: value.applying(offset: offset),
            environment: environment
        ))
    }

    mutating func setContainerShape<S>(_ shape: Attribute<S>, isSystemShape: Bool) where S: InsettableShape {
        // TODO: Wire ContainerShapeTransform/ContainerShapeEnvironment when the container-shape pipeline exists.
    }
}

private struct ForegroundEnvironment<Style>: Rule, AsyncAttribute where Style: ShapeStyle {
    @Attribute var style: Style
    @Attribute var environment: EnvironmentValues

    var value: EnvironmentValues {
        var shape = _ShapeStyle_Shape(
            operation: .modifyBackground(level: 0),
            environment: environment
        )
        style._apply(to: &shape)
        return shape.environment
    }
}
