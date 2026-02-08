//
//  ShadowEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

// MARK: - _ShadowEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _ShadowEffect: EnvironmentalModifier, Equatable {
    public var color: Color

    public var radius: CGFloat

    public var offset: CGSize

    @inlinable
    public init(color: Color, radius: CGFloat, offset: CGSize) {
        self.color = color
        self.radius = radius
        self.offset = offset
    }

    public func resolve(in environment: EnvironmentValues) -> _ShadowEffect._Resolved {
        _Resolved(style: ResolvedShadowStyle(
            color: color.resolve(in: environment),
            radius: radius,
            offset: offset
        ))
    }

    @available(OpenSwiftUI_v4_0, *)
    public static var _requiresMainThread: Bool {
        false
    }

    @usableFromInline
    internal var _requiresMainThread: Bool {
        false
    }

    // MARK: - _Resolved

    public struct _Resolved: RendererEffect {
        package var style: ResolvedShadowStyle

        public typealias AnimatableData = AnimatablePair<AnimatablePair<Float, AnimatablePair<Float, AnimatablePair<Float, Float>>>, AnimatablePair<CGFloat, CGSize.AnimatableData>>

        public var animatableData: AnimatableData {
            get { style.animatableData }
            set { style.animatableData = newValue }
        }

        package func effectValue(size: CGSize) -> DisplayList.Effect {
            .filter(.shadow(style))
        }

        public typealias Body = Never
    }

    nonisolated public static func == (a: _ShadowEffect, b: _ShadowEffect) -> Bool {
        a.color == b.color && a.radius == b.radius && a.offset == b.offset
    }

    public typealias Body = Never

    public typealias ResolvedModifier = _ShadowEffect._Resolved
}

@available(*, unavailable)
extension _ShadowEffect: Sendable {}

@available(*, unavailable)
extension _ShadowEffect._Resolved: Sendable {}

// MARK: - View + shadow

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Adds a shadow to this view.
    ///
    /// Use this modifier to add a shadow of a specified color behind a view.
    /// You can offset the shadow from its view independently in the horizontal
    /// and vertical dimensions using the `x` and `y` parameters. You can also
    /// blur the edges of the shadow using the `radius` parameter. Use a
    /// radius of zero to create a sharp shadow. Larger radius values produce
    /// softer shadows.
    ///
    /// The example below creates a grid of boxes with varying offsets and blur.
    /// Each box displays its radius and offset values for reference.
    ///
    ///     struct Shadow: View {
    ///         let steps = [0, 5, 10]
    ///
    ///         var body: some View {
    ///             VStack(spacing: 50) {
    ///                 ForEach(steps, id: \.self) { offset in
    ///                     HStack(spacing: 50) {
    ///                         ForEach(steps, id: \.self) { radius in
    ///                             Color.blue
    ///                                 .shadow(
    ///                                     color: .primary,
    ///                                     radius: CGFloat(radius),
    ///                                     x: CGFloat(offset), y: CGFloat(offset))
    ///                                 .overlay {
    ///                                     VStack {
    ///                                         Text("\(radius)")
    ///                                         Text("(\(offset), \(offset))")
    ///                                     }
    ///                                 }
    ///                         }
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// ![A three by three grid of blue boxes with shadows.
    /// All the boxes display an integer that indicates the shadow's radius and
    /// an ordered pair that indicates the shadow's offset. The boxes in the
    /// first row show zero offset and have shadows directly below the box;
    /// the boxes in the second row show an offset of five in both directions
    /// and have shadows with a small offset toward the right and down; the
    /// boxes in the third row show an offset of ten in both directions and have
    /// shadows with a large offset toward the right and down. The boxes in
    /// the first column show a radius of zero have shadows with sharp edges;
    /// the boxes in the second column show a radius of five and have shadows
    /// with slightly blurry edges; the boxes in the third column show a radius
    /// of ten and have very blurry edges. Because the shadow of the box in the
    /// upper left is both completely sharp and directly below the box, it isn't
    /// visible.](View-shadow-1-iOS)
    ///
    /// The example above uses ``Color/primary`` as the color to make the
    /// shadow easy to see for the purpose of illustration. In practice,
    /// you might prefer something more subtle, like ``Color/gray-8j2b``.
    /// If you don't specify a color, the method uses a semi-transparent
    /// black.
    ///
    /// - Parameters:
    ///   - color: The shadow's color.
    ///   - radius: A measure of how much to blur the shadow. Larger values
    ///     result in more blur.
    ///   - x: An amount to offset the shadow horizontally from the view.
    ///   - y: An amount to offset the shadow vertically from the view.
    ///
    /// - Returns: A view that adds a shadow to this view.
    @inlinable
    nonisolated public func shadow(
        color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> some View {
        return modifier(
            _ShadowEffect(
                color: color,
                radius: radius,
                offset: CGSize(width: x, height: y)
            )
        )
    }
}
