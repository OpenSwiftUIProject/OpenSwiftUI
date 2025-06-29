//
//  DefaultLayoutGesture.swift
//  OpenSwiftUICore
//
//  Status: WIP


import Foundation

struct DefaultLayoutGesture: PrimitiveGesture {
    nonisolated static func _makeGesture(gesture: _GraphValue<DefaultLayoutGesture>, inputs: _GestureInputs) -> _GestureOutputs<Void> {
        openSwiftUIUnimplementedFailure()
    }
    
    var responder: MultiViewResponder

    typealias Value = Void
}
