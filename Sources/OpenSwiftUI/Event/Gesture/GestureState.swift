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

@available(OpenSwiftUI_v1_0, *)
@propertyWrapper
@frozen
public struct GestureState<Value>: DynamicProperty {
    fileprivate var state: State<Value>

    fileprivate let reset: (Binding<Value>) -> Void

    public init(wrappedValue: Value) {
        self.init(wrappedValue: wrappedValue, resetTransaction: Transaction())
    }

    @_alwaysEmitIntoClient
    public init(initialValue: Value) {
        self.init(wrappedValue: initialValue, resetTransaction: Transaction())
    }

    public init(wrappedValue: Value, resetTransaction: Transaction) {
        state = State(wrappedValue: wrappedValue)
        reset = { binding in
            let binding = binding.transaction(resetTransaction)
            binding.wrappedValue = wrappedValue
        }
    }

    @_alwaysEmitIntoClient
    public init(initialValue: Value, resetTransaction: Transaction) {
        self.init(wrappedValue: initialValue, resetTransaction: resetTransaction)
    }

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

    @_alwaysEmitIntoClient
    public init(
        initialValue: Value,
        reset: @escaping (Value, inout Transaction) -> Void
    ) {
        self.init(wrappedValue: initialValue, reset: reset)
    }

    public var wrappedValue: Value {
        state.wrappedValue
    }

    public var projectedValue: GestureState<Value> {
        self
    }
}

@available(OpenSwiftUI_v1_0, *)
extension GestureState: @unchecked Sendable where Value: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension GestureState where Value: ExpressibleByNilLiteral {
    public init(resetTransaction: Transaction = Transaction()) {
        self.init(wrappedValue: nil, resetTransaction: resetTransaction)
    }

    public init(reset: @escaping (Value, inout Transaction) -> Void) {
        self.init(wrappedValue: nil, reset: reset)
    }
}

// MARK: - Gesture + updating

@available(OpenSwiftUI_v1_0, *)
extension Gesture {
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

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct GestureStateGesture<Base, State>: Gesture, PrimitiveGesture where Base: Gesture {
    public typealias Value = Base.Value

    public var base: Base

    public var state: GestureState<State>

    public var body: (Value, inout State, inout Transaction) -> Void

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
