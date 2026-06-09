//
//  CoordinateSpaceGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8ECA7037C26636F2BB3D86159C23C2C5 (SwiftUICore)

import Foundation
import OpenAttributeGraphShims

// MARK: - CoordinateSpaceGesture

package struct CoordinateSpaceGesture<Value>: GestureModifier {
    private struct CoordinateSpaceEvents<Wrapped>: Rule {
        @Attribute var modifier: CoordinateSpaceGesture<Wrapped>
        @Attribute var events: [EventID: any EventType]
        @Attribute var position: CGPoint
        @Attribute var transform: ViewTransform

        typealias Value = [EventID: any EventType]

        var value: [EventID: any EventType] {
            var events = events
            let coordinateSpace = modifier.coordinateSpace
            if coordinateSpace.isGlobal {
                defaultConvertEventLocations(&events) { _ in }
            } else {
                let resolvedTransform = Graph.withoutUpdate { transform }
                let resolvedPosition = Graph.withoutUpdate { position }
                let convertedTransform = resolvedTransform.withPosition(resolvedPosition)
                defaultConvertEventLocations(&events) { points in
                    convertedTransform.convert(
                        ViewTransform.Conversion.globalToSpace(coordinateSpace),
                        points: &points
                    )
                }
            }
            return events
        }
    }

    package var coordinateSpace: CoordinateSpace

    package init(coordinateSpace: CoordinateSpace) {
        self.coordinateSpace = coordinateSpace
    }

    package static func _makeGesture(
        modifier: _GraphValue<CoordinateSpaceGesture<Value>>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<Value>
    ) -> _GestureOutputs<Value> {
        var newInputs = inputs
        newInputs.events = Attribute(CoordinateSpaceEvents(
            modifier: modifier.value,
            events: inputs.events,
            position: inputs.animatedPosition(),
            transform: inputs.transform
        ))
        newInputs.options.formUnion(.preconvertedEventLocations)
        return body(newInputs)
    }

    package typealias BodyValue = Value
}

// MARK: - Gesture + coordinateSpace

extension Gesture {
    package func coordinateSpace(
        _ coordinateSpace: CoordinateSpace
    ) -> ModifierGesture<CoordinateSpaceGesture<Value>, Self> {
        modifier(CoordinateSpaceGesture(coordinateSpace: coordinateSpace))
    }
}
