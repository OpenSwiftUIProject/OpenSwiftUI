//
//  Animation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4FD7A1D5440B1394D12A74675615ED20 (SwiftUICore)

public import Foundation

/// The way a view changes over time to create a smooth visual transition from
/// one state to another.
///
/// An `Animation` provides a visual transition of a view when a state value
/// changes from one value to another. The characteristics of this transition
/// vary according to the animation type. For instance, a ``linear`` animation
/// provides a mechanical feel to the animation because its speed is consistent
/// from start to finish. In contrast, an animation that uses easing, like
/// ``easeOut``, offers a more natural feel by varying the acceleration
/// of the animation.
///
/// To apply an animation to a view, add the ``View/animation(_:value:)``
/// modifier, and specify both an animation type and the value to animate. For
/// instance, the ``Circle`` view in the following code performs an
/// ``easeIn`` animation each time the state variable `scale` changes:
///
///     struct ContentView: View {
///         @State private var scale = 0.5
///
///         var body: some View {
///             VStack {
///                 Circle()
///                     .scaleEffect(scale)
///                     .animation(.easeIn, value: scale)
///                 HStack {
///                     Button("+") { scale += 0.1 }
///                     Button("-") { scale -= 0.1 }
///                 }
///             }
///             .padding()
///         }
///
/// @Video(source: "animation-01-overview-easein.mp4", poster: "animation-01-overview-easein.png", alt: "A video that shows a circle enlarging then shrinking to its original size using an ease-in animation.")
///
/// When the value of `scale` changes, the modifier
/// ``View/scaleEffect(_:anchor:)`` resizes ``Circle`` according to the
/// new value. OpenSwiftUI can animate the transition between sizes because
/// ``Circle`` conforms to the ``Shape`` protocol. Shapes in OpenSwiftUI conform to
/// the ``Animatable`` protocol, which describes how to animate a property of a
/// view.
///
/// In addition to adding an animation to a view, you can also configure the
/// animation by applying animation modifiers to the animation type. For
/// example, you can:
///
/// - Delay the start of the animation by using the ``delay(_:)`` modifier.
/// - Repeat the animation by using the ``repeatCount(_:autoreverses:)`` or
/// ``repeatForever(autoreverses:)`` modifiers.
/// - Change the speed of the animation by using the ``speed(_:)`` modifier.
///
/// For example, the ``Circle`` view in the following code repeats
/// the ``easeIn`` animation three times by using the
/// ``repeatCount(_:autoreverses:)`` modifier:
///
///     struct ContentView: View {
///         @State private var scale = 0.5
///
///         var body: some View {
///             VStack {
///                 Circle()
///                     .scaleEffect(scale)
///                     .animation(.easeIn.repeatCount(3), value: scale)
///                 HStack {
///                     Button("+") { scale += 0.1 }
///                     Button("-") { scale -= 0.1 }
///                 }
///             }
///             .padding()
///         }
///     }
///
/// @Video(source: "animation-02-overview-easein-repeat.mp4", poster: "animation-02-overview-easein-repeat.png", alt: "A video that shows a circle that repeats the ease-in animation three times: enlarging, then shrinking, then enlarging again. The animation reverses causing the circle to shrink, then enlarge, then shrink to its original size.")
///
/// A view can also perform an animation when a binding value changes. To
/// specify the animation type on a binding, call its ``Binding/animation(_:)``
/// method. For example, the view in the following code performs a
/// ``linear`` animation, moving the box truck between the leading and trailing
/// edges of the view. The truck moves each time a person clicks the ``Toggle``
/// control, which changes the value of the `$isTrailing` binding.
///
///     struct ContentView: View {
///         @State private var isTrailing = false
///
///         var body: some View {
///            VStack(alignment: isTrailing ? .trailing : .leading) {
///                 Image(systemName: "box.truck")
///                     .font(.system(size: 64))
///
///                 Toggle("Move to trailing edge",
///                        isOn: $isTrailing.animation(.linear))
///             }
///         }
///     }
///
/// @Video(source: "animation-03-overview-binding.mp4", poster: "animation-03-overview-binding.png", alt: "A video that shows a box truck that moves from the leading edge of a view to the trailing edge. The box truck then returns to the view's leading edge.")
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Animation: Equatable, Sendable {
    /// Create an `Animation` that contains the specified custom animation.
    @available(OpenSwiftUI_v5_0, *)
    public init<A>(_ base: A) where A: CustomAnimation {
        box = AnimationBox(_base: base)
    }

    package init<A>(_ base: A) where A: InternalCustomAnimation {
        box = InternalAnimationBox(_base: base)
    }

    var box: AnimationBoxBase

    package var codableValue: any CustomAnimation {
        box.base
    }

    public static func == (lhs: Animation, rhs: Animation) -> Bool {
        lhs.box.isEqual(to: rhs.box)
    }

    package func `as`<A>(_ type: A.Type) -> A? where A: CustomAnimation {
        (box as? AnimationBox<A>)?._base
    }

    package enum Function {
        case linear(duration: Double)
        case circularEaseIn(duration: Double)
        case circularEaseOut(duration: Double)
        case circularEaseInOut(duration: Double)
        case bezier(duration: Double, cp1: CGPoint, cp2: CGPoint)
        case spring(duration: Double, mass: Double, stiffness: Double, damping: Double, initialVelocity: Double = 0)
        case customFunction((Double, inout AnimationContext<Double>) -> Double?)
        indirect case delay(Double, Animation.Function)
        indirect case speed(Double, Animation.Function)
        indirect case `repeat`(count: Double, autoreverses: Bool, Animation.Function)

        package static func custom<T>(_ anim: T) -> Animation.Function where T: CustomAnimation {
            .customFunction { time, context in
                anim.animate(value: 1.0, time: time, context: &context)
            }
        }
    }

    package var function: Animation.Function {
        box.function
    }
}

extension Animation.Function {
    package var bezierForm: (duration: Double, cp1: CGPoint, cp2: CGPoint)? {
        switch self {
        case let .linear(duration):
            (duration, CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1.0, y: 1.0))
        case let .circularEaseIn(duration):
            (duration, CGPoint(x: 0.55, y: 0.0), CGPoint(x: 1.0, y: 0.45))
        case let .circularEaseOut(duration):
            (duration, CGPoint(x: 0.0, y: 0.55), CGPoint(x: 0.45, y: 1.0))
        case let .circularEaseInOut(duration):
            (duration, CGPoint(x: 0.85, y: 0), CGPoint(x: 0.15, y: 1.0))
        case let .bezier(duration, cp1, cp2):
            (duration, cp1, cp2)
        default:
            nil
        }
    }
}

// MARK: Animation + Hashable

@available(OpenSwiftUI_v5_0, *)
extension Animation: Hashable {
    /// Calculates the current value of the animation.
    ///
    /// - Returns: The current value of the animation, or `nil` if the animation has finished.
    @_specialize(exported: false, kind: partial, where V == Double)
    @_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
    public func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        box.animate(value: value, time: time, context: &context)
    }

    /// Calculates the current velocity of the animation.
    ///
    /// - Returns: The current velocity of the animation, or `nil` if the the velocity isn't available.
    public func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        box.velocity(value: value, time: time, context: context)
    }

    /// Returns a Boolean value that indicates whether the current animation
    /// should merge with a previous animation.
    public func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        box.shouldMerge(previous: previous, value: value, time: time, context: &context)
    }

    public var base: any CustomAnimation {
        box.base
    }

    public func hash(into hasher: inout Hasher) {
        box.hash(into: &hasher)
    }
}

// MARK: Animation + Debug

@available(OpenSwiftUI_v1_0, *)
extension Animation: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var description: String {
        String(describing: box.base)
    }

    public var debugDescription: String {
        "AnyAnimator(\(String(reflecting: base)))"
    }

    public var customMirror: Mirror {
        Mirror(box, children: ["base": box.base])
    }
}

// MARK: - AnimationBoxBase

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
class AnimationBoxBase: @unchecked Sendable {
    var typeIdentifier: ObjectIdentifier {
        _openSwiftUIBaseClassAbstractMethod()
    }

    var base: any CustomAnimation {
        _openSwiftUIBaseClassAbstractMethod()
    }

    var function: Animation.Function {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func isEqual(to other: AnimationBoxBase) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func hash(into hasher: inout Hasher) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    @_specialize(exported: false, kind: partial, where V == Double)
    @_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
    func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func modifier<Modifier>(_ modifier: Modifier) -> Animation where Modifier: CustomAnimationModifier {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

// MARK: - AnimationBox

private class AnimationBox<Base>: AnimationBoxBase, @unchecked Sendable where Base: CustomAnimation {
    var _base: Base

    init(_base: Base) {
        self._base = _base
    }

    override var typeIdentifier: ObjectIdentifier {
        ObjectIdentifier(Base.self)
    }

    override var base: any CustomAnimation {
        _base
    }

    override var function: Animation.Function {
        .custom(_base)
    }

    override func isEqual(to other: AnimationBoxBase) -> Bool {
        (other as? AnimationBox<Base>).map { $0._base == _base } ?? false
    }

    override func hash(into hasher: inout Hasher) {
        _base.hash(into: &hasher)
    }

    override func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        base.animate(value: value, time: time, context: &context)
    }

    override func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        base.velocity(value: value, time: time, context: context)
    }

    override func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        base.shouldMerge(previous: previous, value: value, time: time, context: &context)
    }

    override func modifier<Modifier>(
        _ modifier: Modifier
    ) -> Animation where Modifier: CustomAnimationModifier {
        Animation(CustomAnimationModifiedContent(base: _base, modifier: modifier))
    }
}

// MARK: - InternalAnimationBox

final private class InternalAnimationBox<Base>: AnimationBox<Base>, @unchecked Sendable where Base: InternalCustomAnimation {
    override var function: Animation.Function {
        _base.function
    }

    override func modifier<Modifier>(
        _ modifier: Modifier
    ) -> Animation where Modifier: CustomAnimationModifier {
        Animation(InternalCustomAnimationModifiedContent(base: _base, modifier: modifier))
    }
}

extension Animation {
    static var `default`: Animation {
        _openSwiftUIUnimplementedFailure()
    }
}
