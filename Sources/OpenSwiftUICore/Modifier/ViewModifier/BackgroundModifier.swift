//
//  BackgroundModifier.swift
//  OpenSwiftUICore
//  Status: WIP

// MARK: - BackgroundModifier [6.4.41]

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
extension _BackgroundModifier : Sendable {}

// TODO

// MARK: - View + Background [6.4.41] [WIP]

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
    /// For example, you can place a collection of stars beind a ``Text`` view:
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
}
