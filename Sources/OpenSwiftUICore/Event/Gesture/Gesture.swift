//
//  Gesture.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 5DF390A778F4D193C5F92C06542566B0 (SwiftUICore)

// MARK: - Gesture [6.5.4]

/// An instance that matches a sequence of events to a gesture, and returns a
/// stream of values for each of its states.
///
/// Create custom gestures by declaring types that conform to the `Gesture`
/// protocol.
@available(OpenSwiftUI_v1_0, *)
@MainActor
@preconcurrency
public protocol Gesture<Value> {
    /// The type representing the gesture's value.
    associatedtype Value

    nonisolated static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Value>

    /// The type of gesture representing the body of `Self`.
    associatedtype Body: Gesture

    /// The content and behavior of the gesture.
    var body: Body { get }
}

// MARK: - PrimitiveGesture [6.5.4]

package protocol PrimitiveGesture: Gesture where Body == Never {}

// MARK: - PubliclyPrimitiveGesture [6.5.4]

package protocol PubliclyPrimitiveGesture: PrimitiveGesture {
    associatedtype InternalBody: Gesture where Value == InternalBody.Value

    var internalBody: InternalBody { get }
}

@available(OpenSwiftUI_v1_0, *)
extension PubliclyPrimitiveGesture {
    nonisolated public static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Self.Value> {
        makeGesture(gesture: gesture, inputs: inputs)
    }

    nonisolated package static func makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Self.Value> {
        InternalBody.makeDebuggableGesture(
            gesture: gesture[\.internalBody],
            inputs: inputs
        )
    }
}

// MARK: - Never + Gesture [6.5.4]

@available(OpenSwiftUI_v1_0, *)
extension Never: Gesture {
    public typealias Value = Never
}

@available(OpenSwiftUI_v1_0, *)
extension PrimitiveGesture {
    public var body: Never {
        preconditionFailure("body() should not be called on \(Self.self).")
    }
}

// MARK: - GestureBodyAccessor [6.5.4]

private struct GestureBodyAccessor<Container>: BodyAccessor where Container: Gesture {
    typealias Body = Container.Body

    func updateBody(of container: Container, changed: Bool) {
        guard changed else { return }
        setBody { container.body }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Gesture where Value == Body.Value {
    nonisolated public static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Self.Body.Value> {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, _) = GestureBodyAccessor().makeBody(container: gesture, inputs: &inputs.viewInputs.base, fields: fields)
        return Body.makeDebuggableGesture(gesture: body, inputs: inputs)
    }
}
