// FIXME

package class ResponderNode {}

package class EventBindingManager {}

package protocol EventBindingSource {}

package struct ExclusiveGesture<A, B>: PrimitiveGesture {}

package struct _MapGesture<Content, Value>: PrimitiveGesture where Content: Gesture {
    nonisolated package static func _makeGesture(gesture: _GraphValue<_MapGesture<Content, Value>>, inputs: _GestureInputs) -> _GestureOutputs<Never> {
        preconditionFailure("TODO")
    }
}

package struct AnyGesture<A>: PrimitiveGesture {}
