//
//  GestureModifier.swift
//  OpenSwiftUICore
//
//  Status: Complete

package protocol GestureModifier {
    associatedtype Value

    associatedtype BodyValue

    static func _makeGesture(
        modifier: _GraphValue<Self>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<BodyValue>
    ) -> _GestureOutputs<Value>
}

extension Gesture {
    package func modifier<T>(_ modifier: T) -> ModifierGesture<T, Self> where T: GestureModifier, Value == T.BodyValue {
        ModifierGesture(content: self, modifier: modifier)
    }
}

package struct ModifierGesture<ContentModifier, Content>: PrimitiveGesture
    where ContentModifier: GestureModifier,
          Content: Gesture,
          ContentModifier.BodyValue == Content.Value {
    var content: Content

    var modifier: ContentModifier

    package typealias Value = ContentModifier.Value

    package static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<ContentModifier.Value> {
        ContentModifier.makeDebuggableGesture(
            modifier: gesture[offset: { .of(&$0.modifier) }],
            inputs: inputs
        ) { inputs in
            Content.makeDebuggableGesture(
                gesture: gesture[offset: { .of(&$0.content) }],
                inputs: inputs
            )
        }
    }
}

extension ModifierGesture: PrimitiveDebuggableGesture {}
