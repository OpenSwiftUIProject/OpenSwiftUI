//
//  GestureState.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 21F35D06B45C9C73387B9CC0A9D4E779 (SwiftUI)

@_spi(ForOpenSwiftUIOnly) public import OpenSwiftUICore
import OpenAttributeGraphShims

// MARK: - GestureState

/// A property wrapper type that updates a property while the user performs a
/// gesture and resets the property back to its initial state when the gesture
/// ends.
///
/// Declare a property as `@GestureState`, pass as a binding to it as a
/// parameter to a gesture's ``Gesture/updating(_:body:)`` callback, and receive
/// updates to it. A property that's declared as `@GestureState` implicitly
/// resets when the gesture becomes inactive, making it suitable for tracking
/// transient state.
///
/// Add a long-press gesture to a ``Circle``, and update the interface during
/// the gesture by declaring a property as `@GestureState`:
///
///     struct SimpleLongPressGestureView: View {
///         @GestureState private var isDetectingLongPress = false
///
///         var longPress: some Gesture {
///             LongPressGesture(minimumDuration: 3)
///                 .updating($isDetectingLongPress) { currentState, gestureState, transaction in
///                     gestureState = currentState
///                 }
///         }
///
///         var body: some View {
///             Circle()
///                 .fill(self.isDetectingLongPress ? Color.red : Color.green)
///                 .frame(width: 100, height: 100, alignment: .center)
///                 .gesture(longPress)
///         }
///     }
@available(OpenSwiftUI_v1_0, *)
@propertyWrapper
@frozen
public struct GestureState<Value>: DynamicProperty {
    fileprivate var state: State<Value>

    fileprivate let reset: (Binding<Value>) -> Void

    /// Creates a view state that's derived from a gesture.
    ///
    /// - Parameter wrappedValue: A wrapped value for the gesture state
    ///   property.
    public init(wrappedValue: Value) {
        self.init(wrappedValue: wrappedValue, resetTransaction: Transaction())
    }

    /// Creates a view state that's derived from a gesture with an initial
    /// value.
    ///
    /// - Parameter initialValue: An initial value for the gesture state
    ///   property.
    @_alwaysEmitIntoClient
    public init(initialValue: Value) {
        self.init(wrappedValue: initialValue, resetTransaction: Transaction())
    }

    /// Creates a view state that's derived from a gesture with a wrapped state
    /// value and a transaction to reset it.
    ///
    /// - Parameters:
    ///   - wrappedValue: A wrapped value for the gesture state property.
    ///   - resetTransaction: A transaction that provides metadata for view
    ///     updates.
    public init(wrappedValue: Value, resetTransaction: Transaction) {
        state = State(wrappedValue: wrappedValue)
        reset = { binding in
            let binding = binding.transaction(resetTransaction)
            binding.wrappedValue = wrappedValue
        }
    }

    /// Creates a view state that's derived from a gesture with an initial state
    /// value and a transaction to reset it.
    ///
    /// - Parameters:
    ///   - initialValue: An initial state value.
    ///   - resetTransaction: A transaction that provides metadata for view
    ///     updates.
    @_alwaysEmitIntoClient
    public init(initialValue: Value, resetTransaction: Transaction) {
        self.init(wrappedValue: initialValue, resetTransaction: resetTransaction)
    }

    /// Creates a view state that's derived from a gesture with a wrapped state
    /// value and a closure that provides a transaction to reset it.
    ///
    /// - Parameters:
    ///   - wrappedValue: A wrapped value for the gesture state property.
    ///   - reset: A closure that provides a ``Transaction``.
    public init(
        wrappedValue: Value,
        reset: @escaping (Value, inout Transaction) -> Void
    ) {
        state = State(wrappedValue: wrappedValue)
        self.reset = { binding in
            var binding = binding
            reset(binding.wrappedValue, &binding.transaction)
            binding.wrappedValue = wrappedValue
        }
    }

    /// Creates a view state that's derived from a gesture with an initial state
    /// value and a closure that provides a transaction to reset it.
    ///
    /// - Parameters:
    ///   - initialValue: An initial state value.
    ///   - reset: A closure that provides a ``Transaction``.
    @_alwaysEmitIntoClient
    public init(
        initialValue: Value,
        reset: @escaping (Value, inout Transaction) -> Void
    ) {
        self.init(wrappedValue: initialValue, reset: reset)
    }

    /// The wrapped value referenced by the gesture state property.
    public var wrappedValue: Value {
        state.wrappedValue
    }

    /// A binding to the gesture state property.
    public var projectedValue: GestureState<Value> {
        self
    }
}

@available(OpenSwiftUI_v1_0, *)
extension GestureState: @unchecked Sendable where Value: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension GestureState where Value: ExpressibleByNilLiteral {
    /// Creates a view state that's derived from a gesture with a transaction to
    /// reset it.
    ///
    /// - Parameter resetTransaction: A transaction that provides metadata for
    ///   view updates.
    public init(resetTransaction: Transaction = Transaction()) {
        self.init(wrappedValue: nil, resetTransaction: resetTransaction)
    }

    /// Creates a view state that's derived from a gesture with a closure that
    /// provides a transaction to reset it.
    ///
    /// - Parameter reset: A closure that provides a ``Transaction``.
    public init(reset: @escaping (Value, inout Transaction) -> Void) {
        self.init(wrappedValue: nil, reset: reset)
    }
}

// MARK: - Gesture + updating

@available(OpenSwiftUI_v1_0, *)
extension Gesture {
    /// Updates the provided gesture state property as the gesture's value
    /// changes.
    ///
    /// Use this callback to update transient UI state as described in
    /// <doc:Adding-Interactivity-with-Gestures>.
    ///
    /// - Parameters:
    ///   - state: A binding to a view's ``GestureState`` property.
    ///   - body: The callback that OpenSwiftUI invokes as the gesture's value
    ///     changes. Its `currentState` parameter is the updated state of the
    ///     gesture. The `gestureState` parameter is the previous state of the
    ///     gesture, and the `transaction` is the context of the gesture.
    ///
    /// - Returns: A version of the gesture that updates the provided `state` as
    ///   the originating gesture's value changes and that resets the `state`
    ///   to its initial value when the user or the system ends or cancels the
    ///   gesture.
    @inlinable
    @MainActor
    @preconcurrency
    public func updating<State>(
        _ state: GestureState<State>,
        body: @escaping (Self.Value, inout State, inout Transaction) -> Void
    ) -> GestureStateGesture<Self, State> {
        GestureStateGesture(base: self, state: state, body: body)
    }
}

// MARK: - GestureStateGesture

/// A gesture that updates the state provided by a gesture's updating callback.
///
/// A gesture's ``Gesture/updating(_:body:)`` callback returns a
/// `GestureStateGesture` instance for updating a transient state property
/// that's annotated with the ``GestureState`` property wrapper.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct GestureStateGesture<Base, State>: Gesture, PrimitiveGesture where Base: Gesture {
    /// The type representing the gesture's value.
    public typealias Value = Base.Value

    /// The originating gesture.
    public var base: Base

    /// A value that changes as the user performs the gesture.
    public var state: GestureState<State>

    /// The updating gesture containing the originating gesture's value, the
    /// updated state of the gesture, and a transaction.
    public var body: (Value, inout State, inout Transaction) -> Void

    /// Creates a new gesture that's the result of an ongoing gesture.
    ///
    /// - Parameters:
    ///   - base: The originating gesture.
    ///   - state: The wrapped value of a ``GestureState`` property.
    ///   - body: The callback that OpenSwiftUI invokes as the gesture's value
    ///     changes.
    @inlinable
    public init(
        base: Base,
        state: GestureState<State>,
        body: @escaping (Value, inout State, inout Transaction) -> Void
    ) {
        self.base = base
        self.state = state
        self.body = body
    }

    nonisolated public static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Value> {
        var inputs = inputs
        inputs.options.insert(.hasChangedCallbacks)
        let outputs = Base.makeDebuggableGesture(
            gesture: gesture[\.base],
            inputs: inputs
        )
        let phase = Attribute(GestureStatePhase(
            gesture: gesture.value,
            phase: outputs.phase,
            resetSeed: inputs.resetSeed,
            useGestureGraph: inputs.options.contains(.gestureGraph),
            lastResetSeed: .zero,
            callback: nil
        ))
        phase.setFlags([.transactional, .removable], mask: .all)
        return outputs.withPhase(phase)
    }
}

@available(*, unavailable)
extension GestureStateGesture: Sendable {}

// MARK: - GestureStatePhase

private struct GestureStatePhase<Base, State>: ResettableGestureRule, RemovableAttribute where Base: Gesture {
    @Attribute var gesture: GestureStateGesture<Base, State>
    @Attribute var phase: GesturePhase<Base.Value>
    @Attribute var resetSeed: UInt32
    var useGestureGraph: Bool
    var lastResetSeed: UInt32
    var callback: (() -> Void)?

    typealias PhaseValue = Base.Value
    typealias Value = GesturePhase<Base.Value>

    mutating func resetPhase() {
        guard let callback else {
            return
        }
        Update.enqueueAction(reason: nil, callback)
        self.callback = nil
    }

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        switch phase {
        case .possible:
            break
        case let .active(value):
            let g = Graph.withoutUpdate { gesture }
            var binding = g.state.state.projectedValue
            callback = {
                g.state.reset(binding)
            }
            var state = Update.dispatchImmediately(reason: nil) {
                binding.wrappedValue
            }
            binding.transaction.tracksVelocity = true
            if useGestureGraph {
                GestureGraph.current.enqueueAction {
                    g.body(value, &state, &binding.transaction)
                    binding.wrappedValue = state
                }
            } else {
                g.body(value, &state, &binding.transaction)
                Update.enqueueAction(reason: nil) {
                    binding.wrappedValue = state
                }
            }
        case .ended, .failed:
            resetPhase()
        }
        value = phase
    }

    static func willRemove(attribute: AnyAttribute) {
        let phasePointer = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: Self.self)
        phasePointer.pointee.resetPhase()
    }

    static func didReinsert(attribute: AnyAttribute) {
        _openSwiftUIEmptyStub()
    }
}
