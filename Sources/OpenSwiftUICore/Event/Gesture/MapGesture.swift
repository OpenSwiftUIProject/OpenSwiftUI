//
//  MapGesture.swift
//  OpenSwiftUICore
//
//  Status: Unimplmented
//  ID: EA8BFBF553A9179E7F3A85C72F795A9F (SwiftUICore)

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



//        ModifierGesture<Self, <#Content: Gesture#>>.makeDebuggableGesture(
//            gesture: modifier[offset: { .of(&$0.body) }],
//            inputs: inputs
//        )
        openSwiftUIUnimplementedFailure()
    }

    package typealias BodyValue = From

    package typealias Value = To
}

extension Gesture {
    package func mapPhase<T>(
        _ body: @escaping (GesturePhase<Self.Value>) -> GesturePhase<T>
    ) -> ModifierGesture<MapGesture<Value, T>, Self> {
        modifier(MapGesture(body))
    }

    public func map<T>(_ body: @escaping (Value) -> T) -> _MapGesture<Self, T> {
        openSwiftUIUnimplementedFailure()
    }

    package func discrete(_ enabled: Bool = true) -> ModifierGesture<MapGesture<Value, Value>, Self> {
        openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
public struct _MapGesture<Content, Value>: PrimitiveGesture where Content: Gesture {
    public static func _makeGesture(
        gesture: _GraphValue<_MapGesture<Content, Value>>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Value> {
        openSwiftUIUnimplementedFailure()
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension _MapGesture: Sendable {}
