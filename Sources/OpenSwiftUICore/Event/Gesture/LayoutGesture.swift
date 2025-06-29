//
//  LayoutGesture.swift
//  OpenSwiftUICore
//
//  Status: WIP

// MARK: - LayoutGesture [6.5.4] [WIP]

package protocol LayoutGesture: PrimitiveDebuggableGesture, PrimitiveGesture where Value == () {
    var responder: MultiViewResponder { get }

    func updateEventBindings(
        _ events: inout [EventID : any EventType],
        proxy: LayoutGestureChildProxy
    )
}

extension LayoutGesture {
    package static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Void> {
        openSwiftUIUnimplementedFailure()
    }

    package func updateEventBindings(
        _ events: inout [EventID : any EventType],
        proxy: LayoutGestureChildProxy
    ) {}
}

// MARK: - DefaultLayoutGesture [6.5.4] [WIP]

package struct DefaultLayoutGesture: LayoutGesture {
    package var responder: MultiViewResponder

    package typealias Body = Never
    package typealias Value = ()
}

// MARK: - LayoutGestureChildProxy [6.5.4] [WIP]

package struct LayoutGestureChildProxy: RandomAccessCollection {
    package struct Child {
        package func binds(_ binding: EventBinding) -> Bool {
            preconditionFailure("TODO")
        }

        package func containsGlobalLocation(_ p: PlatformPoint) -> Bool {
            preconditionFailure("TODO")
        }
    }

    package var startIndex: Int {
        get { preconditionFailure("TODO") }
    }

    package var endIndex: Int {
        get { preconditionFailure("TODO") }
    }

    package subscript(index: Int) -> LayoutGestureChildProxy.Child {
        get { preconditionFailure("TODO") }
    }

    package func bindChild(
        index: Int,
        event: any EventType,
        id: EventID
    ) -> (from: EventBinding?, to: EventBinding?)? {
        preconditionFailure("TODO")
    }
}
