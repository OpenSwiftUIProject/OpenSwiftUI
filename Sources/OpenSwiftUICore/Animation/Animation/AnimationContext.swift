//
//  AnimationContext.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import OpenAttributeGraphShims

/// Contextual values that a custom animation can use to manage state and
/// access a view's environment.
///
/// The system provides an `AnimationContext` to a ``CustomAnimation`` instance
/// so that the animation can store and retrieve values in an instance of
/// ``AnimationState``. To access these values, use the context's
/// ``AnimationContext/state`` property.
///
/// For more convenient access to state, create an ``AnimationStateKey`` and
/// extend `AnimationContext` to include a computed property that gets and
/// sets the ``AnimationState`` value. Then use this property instead of
/// ``AnimationContext/state`` to retrieve the state of a custom animation. For
/// example, the following code creates an animation state key named
/// `PausableState`. Then the code extends `AnimationContext` to include the
/// `pausableState` property:
///
///     private struct PausableState<Value: VectorArithmetic>: AnimationStateKey {
///         var paused = false
///         var pauseTime: TimeInterval = 0.0
///
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
/// To access the pausable state, the custom animation `PausableAnimation` uses
/// the `pausableState` property instead of the ``AnimationContext/state``
/// property:
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
/// The animation can also retrieve environment values of the view that created
/// the animation. To retrieve a view's environment value, use the context's
/// ``AnimationContext/environment`` property. For instance, the following code
/// creates a custom ``EnvironmentValues`` property named `animationPaused`, and the
/// view `PausableAnimationView` uses the property to store the paused state:
///
///     extension EnvironmentValues {
///         @Entry var animationPaused: Bool = false
///     }
///
///     struct PausableAnimationView: View {
///         @State private var paused = false
///
///         var body: some View {
///             VStack {
///                 ...
///             }
///             .environment(\.animationPaused, paused)
///         }
///     }
///
/// Then the custom animation `PausableAnimation` retrieves the paused state
/// from the view's environment using the ``AnimationContext/environment``
/// property:
///
///     struct PausableAnimation: CustomAnimation {
///         func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
///             let paused = context.environment.animationPaused
///             ...
///         }
///     }
@available(OpenSwiftUI_v5_0, *)
public struct AnimationContext<Value> where Value: VectorArithmetic {
    /// The current state of a custom animation.
    ///
    /// An instance of ``CustomAnimation`` uses this property to read and
    /// write state values as the animation runs.
    ///
    /// An alternative to using the `state` property in a custom animation is
    /// to create an ``AnimationStateKey`` type and extend ``AnimationContext``
    /// with a custom property that returns the state as a custom type. For
    /// example, the following code creates a state key named `PausableState`.
    /// It's convenient to store state values in the key type, so the
    /// `PausableState` structure includes properties for the stored state
    /// values `paused` and `pauseTime`.
    ///
    ///     private struct PausableState<Value: VectorArithmetic>: AnimationStateKey {
    ///         var paused = false
    ///         var pauseTime: TimeInterval = 0.0
    ///
    ///         static var defaultValue: Self { .init() }
    ///     }
    ///
    /// To provide access the pausable state, the following code extends
    /// `AnimationContext` to include the `pausableState` property. This
    /// property returns an instance of the custom `PausableState` structure
    /// stored in ``AnimationContext/state``, and it can also store a new
    /// `PausableState` instance in `state`.
    ///
    ///     extension AnimationContext {
    ///         fileprivate var pausableState: PausableState<Value> {
    ///             get { state[PausableState<Value>.self] }
    ///             set { state[PausableState<Value>.self] = newValue }
    ///         }
    ///     }
    ///
    /// Now a custom animation can use the `pausableState` property instead of
    /// the ``AnimationContext/state`` property as a convenient way to read and
    /// write state values as the animation runs.
    ///
    ///     struct PausableAnimation: CustomAnimation {
    ///         func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
    ///             let pausableState = context.pausableState
    ///             var pauseTime = pausableState.pauseTime
    ///             ...
    ///         }
    ///     }
    ///
    public var state: AnimationState<Value>

    private var _environment: WeakAttribute<EnvironmentValues>?

    /// Set this to `true` to indicate that an animation is logically complete.
    ///
    /// This controls when AnimationCompletionCriteria.logicallyComplete
    /// completion callbacks are fired. This should be set to `true` at most
    /// once in the life of an animation, changing back to `false` later will be
    /// ignored. If this is never set to `true`, the behavior is equivalent to
    /// if this had been set to `true` just as the animation finished (by
    /// returning `nil`).
    public var isLogicallyComplete: Bool

    /// The current environment of the view that created the custom animation.
    ///
    /// An instance of ``CustomAnimation`` uses this property to read
    /// environment values from the view that created the animation. To learn
    /// more about environment values including how to define custom
    /// environment values, see ``EnvironmentValues``.
    public var environment: EnvironmentValues {
        _environment?.value ?? EnvironmentValues()
    }

    package init(
        state: AnimationState<Value>,
        environment: WeakAttribute<EnvironmentValues>?,
        isLogicallyComplete: Bool
    ) {
        self.state = state
        self._environment = environment
        self.isLogicallyComplete = isLogicallyComplete
    }

    package init(
        state: AnimationState<Value>,
        environment: WeakAttribute<EnvironmentValues>?
    ) {
        self.state = state
        self._environment = environment
        self.isLogicallyComplete = false
    }

    package init(
        environment: WeakAttribute<EnvironmentValues>?,
        isLogicallyComplete: Bool
    ) {
        self.state = .init()
        self._environment = environment
        self.isLogicallyComplete = isLogicallyComplete
    }

    package init(environment: WeakAttribute<EnvironmentValues>?) {
        self.state = .init()
        self._environment = environment
        self.isLogicallyComplete = false
    }

    package init(
        state: AnimationState<Value> = .init(),
        environment: Attribute<EnvironmentValues>?,
        isLogicallyComplete: Bool = false
    ) {
        self.state = state
        self._environment = WeakAttribute(environment)
        self.isLogicallyComplete = isLogicallyComplete
    }

    package init(
        state: AnimationState<Value>,
        environment: Attribute<EnvironmentValues>?
    ) {
        self.state = state
        self._environment = WeakAttribute(environment)
        self.isLogicallyComplete = false
    }

    package init(
        environment: Attribute<EnvironmentValues>?,
        isLogicallyComplete: Bool
    ) {
        self.state = .init()
        self._environment = WeakAttribute(environment)
        self.isLogicallyComplete = isLogicallyComplete
    }

    package init(environment: Attribute<EnvironmentValues>?) {
        self.state = .init()
        self._environment = WeakAttribute(environment)
        self.isLogicallyComplete = false
    }

    /// Creates a new context from another one with a state that you provide.
    ///
    /// Use this method to create a new context that contains the state that
    /// you provide and view environment values from the original context.
    ///
    /// - Parameter state: The initial state for the new context.
    /// - Returns: A new context that contains the specified state.
    public func withState<T>(
        _ state: AnimationState<T>
    ) -> AnimationContext<T> where T: VectorArithmetic {
        AnimationContext<T>(
            state: state,
            environment: _environment,
            isLogicallyComplete: isLogicallyComplete
        )
    }
}

@available(*, unavailable)
extension AnimationContext: Sendable {}
