//
//  SizeGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1E238A2DD9F0A69154D5FC25E0CF7514 (SwiftUICore)

package import Foundation
import OpenAttributeGraphShims

// MARK: - SizeGesture

package struct SizeGesture<Content>: PrimitiveGesture where Content: Gesture {
    package typealias Value = Content.Value

    package var content: (CGSize) -> Content

    package init(_ content: @escaping (CGSize) -> Content) {
        self.content = content
    }

    package static func _makeGesture(
        gesture: _GraphValue<SizeGesture<Content>>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Value> {
        let child = _GraphValue(SizeGestureChild(
            gesture: gesture.value,
            size: inputs.size
        ))
        return Content._makeGesture(gesture: child, inputs: inputs)
    }
}

// MARK: - SizeGestureChild

private struct SizeGestureChild<Content>: Rule where Content: Gesture {
    @Attribute var gesture: SizeGesture<Content>
    @Attribute var size: ViewSize

    var value: Content {
        gesture.content(size.value)
    }
}
