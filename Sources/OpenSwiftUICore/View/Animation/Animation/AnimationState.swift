//
//  AnimationState.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// A container that stores the state for a custom animation.
///
/// An ``AnimationContext`` uses this type to store state for a
/// ``CustomAnimation``. To retrieve the stored state of a context, you can
/// use the ``AnimationContext/state`` property. However, a more convenient
/// way to access the animation state is to define an ``AnimationStateKey``
/// and extend ``AnimationContext`` with a computed property that gets
/// and sets the animation state, as shown in the following code:
///
///     private struct PausableState<Value: VectorArithmetic>: AnimationStateKey {
///         static var defaultValue: Self { .init() }
///     }
///
///     extension AnimationContext {
///         fileprivate var pausableState: PausableState<Value> {
///             get { state[PausableState<Value>.self] }
///             set { state[PausableState<Value>.self] = newValue }
///         }
///     }
///
/// When creating an ``AnimationStateKey``, it's convenient to define the
/// state values that your custom animation needs. For example, the following
/// code adds the properties `paused` and `pauseTime` to the `PausableState`
/// animation state key:
///
///     private struct PausableState<Value: VectorArithmetic>: AnimationStateKey {
///         var paused = false
///         var pauseTime: TimeInterval = 0.0
///
///         static var defaultValue: Self { .init() }
///     }
///
/// To access the pausable state in a `PausableAnimation`, the follow code
/// calls `pausableState` instead of using the context's
/// ``AnimationContext/state`` property. And because the animation state key
/// `PausableState` defines properties for state values, the custom animation
/// can read and write those values.
///
///     struct PausableAnimation: CustomAnimation {
///         let base: Animation
///
///         func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
///             let paused = context.environment.animationPaused
///
///             let pausableState = context.pausableState
///             var pauseTime = pausableState.pauseTime
///             if pausableState.paused != paused {
///                 pauseTime = time - pauseTime
///                 context.pausableState = PausableState(paused: paused, pauseTime: pauseTime)
///             }
///
///             let effectiveTime = paused ? pauseTime : time - pauseTime
///             let result = base.animate(value: value, time: effectiveTime, context: &context)
///             return result
///         }
///     }
///
/// ### Storing state for secondary animations
///
/// A custom animation can also use `AnimationState` to store the state of a
/// secondary animation. For example, the following code creates an
/// ``AnimationStateKey`` that includes the property `secondaryState`, which a
/// custom animation can use to store other state:
///
///     private struct TargetState<Value: VectorArithmetic>: AnimationStateKey {
///         var timeDelta = 0.0
///         var valueDelta = Value.zero
///         var secondaryState: AnimationState<Value>? = .init()
///
///         static var defaultValue: Self { .init() }
///     }
///
///     extension AnimationContext {
///         fileprivate var targetState: TargetState<Value> {
///             get { state[TargetState<Value>.self] }
///             set { state[TargetState<Value>.self] = newValue }
///         }
///     }
///
/// The custom animation `TargetAnimation` uses `TargetState` to store state
/// data in `secondaryState` for another animation that runs as part of the
/// target animation.
///
///     struct TargetAnimation: CustomAnimation {
///         var base: Animation
///         var secondary: Animation
///
///         func animate<V: VectorArithmetic>(value: V, time: Double, context: inout AnimationContext<V>) -> V? {
///             var targetValue = value
///             if let secondaryState = context.targetState.secondaryState {
///                 var secondaryContext = context
///                 secondaryContext.state = secondaryState
///                 let secondaryValue = value - context.targetState.valueDelta
///                 let result = secondary.animate(
///                     value: secondaryValue, time: time - context.targetState.timeDelta,
///                     context: &secondaryContext)
///                 if let result = result {
///                     context.targetState.secondaryState = secondaryContext.state
///                     targetValue = result + context.targetState.valueDelta
///                 } else {
///                     context.targetState.secondaryState = nil
///                 }
///             }
///             let result = base.animate(value: targetValue, time: time, context: &context)
///             if let result = result {
///                 targetValue = result
///             } else if context.targetState.secondaryState == nil {
///                 return nil
///             }
///             return targetValue
///     }
///
///         func shouldMerge<V: VectorArithmetic>(previous: Animation, value: V, time: Double, context: inout AnimationContext<V>) -> Bool {
///             guard let previous = previous.base as? Self else { return false }
///             var secondaryContext = context
///             if let secondaryState = context.targetState.secondaryState {
///                 secondaryContext.state = secondaryState
///                 context.targetState.valueDelta = secondary.animate(
///                     value: value, time: time - context.targetState.timeDelta,
///                     context: &secondaryContext) ?? value
///             } else {
///                 context.targetState.valueDelta = value
///             }
///             // Reset the target each time a merge occurs.
///             context.targetState.secondaryState = .init()
///             context.targetState.timeDelta = time
///             return base.shouldMerge(
///                 previous: previous.base, value: value, time: time,
///                 context: &context)
///         }
///     }
@available(OpenSwiftUI_v5_0, *)
public struct AnimationState<Value> where Value: VectorArithmetic {
    var storage: [ObjectIdentifier: Any]

    /// Create an empty state container.
    ///
    /// You don't typically create an instance of ``AnimationState`` directly.
    /// Instead, the ``AnimationContext`` provides the animation state to an
    /// instance of ``CustomAnimation``.
    public init() {
        self.storage = [:]
    }

    /// Accesses the state for a custom key.
    ///
    /// Create a custom animation state value by defining a key that conforms
    /// to the ``AnimationStateKey`` protocol and provide the
    /// ``AnimationStateKey/defaultValue`` for the key. Also include properties
    /// to read and write state values that your ``CustomAnimation`` uses. For
    /// example, the following code defines a key named `PausableState` that
    /// has two state values, `paused` and `pauseTime`:
    ///
    ///     private struct PausableState<Value: VectorArithmetic>: AnimationStateKey {
    ///         var paused = false
    ///         var pauseTime: TimeInterval = 0.0
    ///
    ///         static var defaultValue: Self { .init() }
    ///     }
    ///
    /// Use that key with the subscript operator of the ``AnimationState``
    /// structure to get and set a value for the key. For more convenient
    /// access to the key value, extend ``AnimationContext`` with a computed
    /// property that gets and sets the key's value.
    ///
    ///     extension AnimationContext {
    ///         fileprivate var pausableState: PausableState<Value> {
    ///             get { state[PausableState<Value>.self] }
    ///             set { state[PausableState<Value>.self] = newValue }
    ///         }
    ///     }
    ///
    /// To access the state values in a ``CustomAnimation``, call the custom
    /// computed property, then read and write the state values that the
    /// custom ``AnimationStateKey`` provides.
    ///
    ///     struct PausableAnimation: CustomAnimation {
    ///         let base: Animation
    ///
    ///         func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
    ///             let paused = context.environment.animationPaused
    ///
    ///             let pausableState = context.pausableState
    ///             var pauseTime = pausableState.pauseTime
    ///             if pausableState.paused != paused {
    ///                 pauseTime = time - pauseTime
    ///                 context.pausableState = PausableState(paused: paused, pauseTime: pauseTime)
    ///             }
    ///
    ///             let effectiveTime = paused ? pauseTime : time - pauseTime
    ///             let result = base.animate(value: value, time: effectiveTime, context: &context)
    ///             return result
    ///         }
    ///     }
    public subscript<K>(key: K.Type) -> K.Value where K: AnimationStateKey {
        get {
            if let value = storage[ObjectIdentifier(key)] {
                return value as! K.Value
            } else {
                return key.defaultValue
            }
        }
        set {
            storage[ObjectIdentifier(key)] = newValue
        }
    }
}

@available(*, unavailable)
extension AnimationState: Sendable {}

/// A key for accessing animation state values.
///
/// To access animation state from an ``AnimationContext`` in a custom
/// animation, create an `AnimationStateKey`. For example, the following
/// code creates an animation state key named `PausableState` and sets the
/// value for the required ``defaultValue`` property. The code also defines
/// properties for state values that the custom animation needs when
/// calculating animation values. Keeping the state values in the animation
/// state key makes it more convenient to read and write those values in the
/// implementation of a ``CustomAnimation``.
///
///     private struct PausableState<Value: VectorArithmetic>: AnimationStateKey {
///         var paused = false
///         var pauseTime: TimeInterval = 0.0
///
///         static var defaultValue: Self { .init() }
///     }
///
/// To make accessing the value of the animation state key more convenient,
/// define a property for it by extending ``AnimationContext``:
///
///     extension AnimationContext {
///         fileprivate var pausableState: PausableState<Value> {
///             get { state[PausableState<Value>.self] }
///             set { state[PausableState<Value>.self] = newValue }
///         }
///     }
///
/// Then, you can read and write your state in an instance of `CustomAnimation`
/// using the ``AnimationContext``:
///
///     struct PausableAnimation: CustomAnimation {
///         let base: Animation
///
///         func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
///             let paused = context.environment.animationPaused
///
///             let pausableState = context.pausableState
///             var pauseTime = pausableState.pauseTime
///             if pausableState.paused != paused {
///                 pauseTime = time - pauseTime
///                 context.pausableState = PausableState(paused: paused, pauseTime: pauseTime)
///             }
///
///             let effectiveTime = paused ? pauseTime : time - pauseTime
///             let result = base.animate(value: value, time: effectiveTime, context: &context)
///             return result
///         }
///     }
@available(OpenSwiftUI_v5_0, *)
public protocol AnimationStateKey {
    /// The associated type representing the type of the animation state key's
    /// value.
    associatedtype Value

    /// The default value for the animation state key.
    static var defaultValue: Self.Value { get }
}
