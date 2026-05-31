//
//  MapGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: EA8BFBF553A9179E7F3A85C72F795A9F (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - MapGesture

package struct MapGesture<From, To>: GestureModifier {
    package var body: (GesturePhase<From>) -> GesturePhase<To>

    package init(_ body: @escaping (GesturePhase<From>) -> GesturePhase<To>) {
        self.body = body
    }

    package init(_ body: @escaping (From) -> To) {
        self.body = { $0.map(body) }
    }

    package static func _makeGesture(
        modifier: _GraphValue<Self>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<From>
    ) -> _GestureOutputs<To> {
        let outputs = body(inputs)
        let phase = Attribute(MapPhase(
            modifier: modifier.value,
            phase: outputs.phase,
            resetSeed: inputs.resetSeed,
            lastResetSeed: .zero
        ))
        return outputs.withPhase(phase)
    }

    package typealias BodyValue = From

    package typealias Value = To
}

@available(OpenSwiftUI_v1_0, *)
extension Gesture {
    package func mapPhase<T>(
        _ body: @escaping (GesturePhase<Self.Value>) -> GesturePhase<T>
    ) -> ModifierGesture<MapGesture<Value, T>, Self> {
        modifier(MapGesture(body))
    }

    /// Returns a gesture that uses the given closure to map over this
    /// gesture's value.
    public func map<T>(_ body: @escaping (Value) -> T) -> _MapGesture<Self, T> {
        _MapGesture(_body: modifier(MapGesture(body)))
    }

    package func discrete(_ enabled: Bool = true) -> ModifierGesture<MapGesture<Value, Value>, Self> {
        mapPhase { phase in
            guard enabled,
                  case let .active(value) = phase else {
                return phase
            }
            return .possible(value)
        }
    }
}

@available(OpenSwiftUI_v1_0, *)
public struct _MapGesture<Content, Value>: PrimitiveGesture where Content: Gesture {
    package var _body: ModifierGesture<MapGesture<Content.Value, Value>, Content>

    package init(_body: ModifierGesture<MapGesture<Content.Value, Value>, Content>) {
        self._body = _body
    }

    public static func _makeGesture(
        gesture: _GraphValue<_MapGesture<Content, Value>>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Value> {
        MapGesture<Content.Value, Value>.makeDebuggableGesture(
            modifier: gesture[offset: { .of(&$0._body.modifier) }],
            inputs: inputs
        ) { inputs in
            Content.makeDebuggableGesture(
                gesture: gesture[offset: { .of(&$0._body.content) }],
                inputs: inputs
            )
        }
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension _MapGesture: Sendable {}

private struct MapPhase<From, To>: ResettableGestureRule, CustomStringConvertible {
    @Attribute var modifier: MapGesture<From, To>
    @Attribute var phase: GesturePhase<From>
    @Attribute var resetSeed: UInt32
    var lastResetSeed: UInt32

    typealias PhaseValue = To
    typealias Value = GesturePhase<To>

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        value = modifier.body(phase)
    }

    var description: String {
        "Map → \(To.self)"
    }
}
