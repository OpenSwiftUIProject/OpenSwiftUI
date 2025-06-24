//
//  GestureDebug.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 40D5679141F478561068F8E300838A67 (SwiftUICore)

package import Foundation
package import OpenGraphShims

package enum GestureDebug {
    package typealias Properties = ArrayWith2Inline<(String, String)>

    package enum Kind {
        case empty
        case primitive
        case modifier
        case gesture
        case combiner
    }

    package struct Data {
        package var kind: GestureDebug.Kind
        package var type: any Any.Type
        package var phase: GesturePhase<()>
        package var attribute: AnyOptionalAttribute
        package var resetSeed: UInt32
        package var frame: CGRect
        package var properties: GestureDebug.Properties
        // private var childrenBox: GestureDebug.ChildrenBox

        package typealias Children = ArrayWith2Inline<GestureDebug.Data>

        package var children: GestureDebug.Data.Children {
            get { preconditionFailure("TODO") }
            set { preconditionFailure("TODO") }
        }

        package init() {
            kind = .empty
            type = EmptyGesture<()>.self
            phase = .failed
            attribute = .init()
            resetSeed = 0
            frame = .zero
            properties = .init()
        }

        package init(
            kind: GestureDebug.Kind,
            type: any Any.Type,
            children: GestureDebug.Data.Children,
            phase: GesturePhase<()>,
            attribute: AnyAttribute?,
            resetSeed: UInt32,
            frame: CGRect,
            properties: GestureDebug.Properties
        ) {
            preconditionFailure("TODO")
        }
    }
}

extension GestureDebug.Data: Defaultable {
    package static let defaultValue: GestureDebug.Data = .init()
}

// MARK: - PrimitiveDebuggableGesture [6.5.4]

package protocol PrimitiveDebuggableGesture {
}

// MARK: - DebuggableGesturePhase [6.5.4]

package protocol DebuggableGesturePhase {
    associatedtype PhaseValue
    var phase: GesturePhase<PhaseValue> { get set }
    var properties: GestureDebug.Properties { get }
}

extension Attribute where Value: DebuggableGesturePhase {
    package func phase() -> Attribute<GesturePhase<Value.PhaseValue>> {
        self[offset: { .of(&$0.phase) }]
    }
}

extension Gesture {
    @inline(__always)
    package static func makeDebuggableGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Self.Value> {
        preconditionFailure("TODO")
    }
}

extension GestureModifier {
    @inline(__always)
    package static func makeDebuggableGesture(
        modifier: _GraphValue<Self>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<Self.BodyValue>
    ) -> _GestureOutputs<Self.Value> {
        preconditionFailure("TODO")
    }
}

extension _GestureOutputs {
    @inline(__always)
    package mutating func wrapDebugOutputs<T>(
        _ type: T.Type,
        properties: Attribute<GestureDebug.Properties>? = nil,
        inputs: _GestureInputs
    ) {
        preconditionFailure("TODO")
    }

    @inline(__always)
    package mutating func wrapDebugOutputs<T, V1, V2>(
        _ type: T.Type,
        kind: GestureDebug.Kind,
        properties: Attribute<GestureDebug.Properties>? = nil,
        inputs: _GestureInputs,
        combiningOutputs outputs: (_GestureOutputs<V1>, _GestureOutputs<V2>)
    ) {
        preconditionFailure("TODO")
    }
}

@_spi(ForSwiftUIOnly)
extension GesturePhase {
    @_spi(ForSwiftUIOnly)
    package var descriptionWithoutValue: String {
        @_spi(ForSwiftUIOnly)
        get { preconditionFailure("TODO") }
    }
}

extension GestureDebug.Data {
    package func printTree() {
        preconditionFailure("TODO")
    }
}
