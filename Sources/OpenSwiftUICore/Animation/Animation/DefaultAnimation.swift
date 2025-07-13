//
//  DefaultAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by FluidSpringAnimation

package import Foundation

@available(OpenSwiftUI_v1_0, *)
extension Animation {
    /// A default animation instance.
    ///
    /// The `default` animation is ``spring(response:dampingFraction:blendDuration:)``
    /// with:
    ///
    /// - `response` equal to `0.55`
    /// - `dampingFraction` equal to `1.0`
    /// - `blendDuration` equal to `0.0`
    ///
    /// Prior to iOS 17, macOS 14, tvOS 17, and watchOS 10, the `default`
    /// animation is ``easeInOut``.
    ///
    /// The global function
    /// ``withAnimation(_:_:)`` uses the default animation if you don't
    /// provide one. For instance, the following code listing shows
    /// an example of using the `default` animation to flip the text "Hello"
    /// each time someone clicks the Animate button.
    ///
    ///     struct ContentView: View {
    ///         @State private var degrees = Double.zero
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Spacer()
    ///                 Text("Hello")
    ///                     .font(.largeTitle)
    ///                     .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))
    ///
    ///                 Spacer()
    ///                 Button("Animate") {
    ///                     withAnimation {
    ///                         degrees = (degrees == .zero) ? 180 : .zero
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-04-default-flip.mp4", poster: "animation-04-default-flip.png", alt: "A video that shows the word Hello flip horizontally so that its letters appear backwards. Then it flips in reverse so that the word Hello appears correctly.")
    ///
    /// To use the `default` animation when adding the ``View/animation(_:value:)``
    /// view modifier, specify it explicitly as the animation type. For
    /// instance, the following code shows an example of the `default`
    /// animation to spin the text "Hello" each time someone clicks the Animate
    /// button.
    ///
    ///     struct ContentView: View {
    ///         @State private var degrees = Double.zero
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Spacer()
    ///                 Text("Hello")
    ///                     .font(.largeTitle)
    ///                     .rotationEffect(.degrees(degrees))
    ///                     .animation(.default, value: degrees)
    ///
    ///                 Spacer()
    ///                 Button("Animate") {
    ///                     degrees = (degrees == .zero) ? 360 : .zero
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-05-default-spin.mp4", poster: "animation-05-default-spin.png", alt: "A video that shows the word Hello spinning clockwise for one full rotation, that is, 360 degrees. Then Hello spins counterclockwise for one full rotation.")
    ///
    /// A `default` animation instance is only equal to other `default`
    /// animation instances (using `==`), and not equal to other animation
    /// instances even when the animations are identical. For example, if you
    /// create an animation using the ``spring(response:dampingFraction:blendDuration:)``
    /// modifier with the same parameter values that `default` uses, the
    /// animation isn't equal to `default`. This behavior lets you
    /// differentiate between animations that you intentionally choose and
    /// those that use the `default` animation.
    public static let `default` = Animation(defaultCustomAnimation)

    package static let defaultCustomAnimation = DefaultAnimation()
}

package struct DefaultAnimation: InternalCustomAnimation {
    static let base: Animation = {
        if isDeployedOnOrAfter(Semantics.v5) {
            // TODO: FluidSpringAnimation()
            Animation(
                BezierAnimation(
                    curve: .init(
                        startControlPoint: .init(x: 0.42, y: 0),
                        endControlPoint: .init(x: 0.58, y: 1)
                    ),
                    duration: 0.35
                )
            )
        } else {
            Animation(
                BezierAnimation(
                    curve: .init(
                        startControlPoint: .init(x: 0.42, y: 0),
                        endControlPoint: .init(x: 0.58, y: 1)
                    ),
                    duration: 0.35
                )
            )
        }
    }()

    package init() {
        _openSwiftUIEmptyStub()
    }

    @_specialize(exported: false, kind: partial, where V == Double)
    @_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
    package func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        Self.base.animate(
            value: value,
            time: time,
            context: &context
        )
    }

    package func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        Self.base.velocity(
            value: value,
            time: time,
            context: context
        )
    }

    package func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        Self.base.shouldMerge(
            previous: previous,
            value: value,
            time: time,
            context: &context
        )
    }

    package var function: Animation.Function {
        Self.base.function
    }

    package func hash(into hasher: inout Hasher) {
        Self.base.hash(into: &hasher)
    }
}

extension DefaultAnimation: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIEmptyStub()
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIEmptyStub()
    }
}
