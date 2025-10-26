//
//  GestureDebug.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 40D5679141F478561068F8E300838A67 (SwiftUICore)

package import Foundation
package import OpenAttributeGraphShims
import OpenSwiftUI_SPI

package enum GestureDebug {
    package typealias Properties = ArrayWith2Inline<(String, String)>

    package enum Kind {
        case empty
        case primitive
        case modifier
        case gesture
        case combiner
    }

    private enum ChildrenBox {
        indirect case value(Data.Children)
    }

    package struct Data {
        package var kind: GestureDebug.Kind
        package var type: any Any.Type
        package var phase: GesturePhase<()>
        package var attribute: AnyOptionalAttribute
        package var resetSeed: UInt32
        package var frame: CGRect
        package var properties: GestureDebug.Properties
        private var childrenBox: GestureDebug.ChildrenBox

        package typealias Children = ArrayWith2Inline<GestureDebug.Data>

        package var children: GestureDebug.Data.Children {
            get { _openSwiftUIUnimplementedFailure() }
            set { _openSwiftUIUnimplementedFailure() }
        }

        package init() {
            kind = .empty
            type = EmptyGesture<()>.self
            phase = .failed
            attribute = .init()
            resetSeed = 0
            frame = .zero
            properties = .init()
            childrenBox = .value([]) // FIXME
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
            _openSwiftUIUnimplementedFailure()
        }
    }
}

extension GestureDebug.Data: Defaultable {
    package static let defaultValue: GestureDebug.Data = .init()
}

// MARK: - PrimitiveDebuggableGesture [6.5.4]

package protocol PrimitiveDebuggableGesture {}

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
    nonisolated package static func makeDebuggableGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Self.Value> {
        var outputs = _makeGesture(gesture: gesture, inputs: inputs)
        guard inputs.options.contains(.includeDebugOutput),
              // FIXME
              !(self is PrimitiveDebuggableGesture) else {
            return outputs
        }
        outputs.wrapDebugOutputs(Self.self, inputs: inputs)
        return outputs
    }
}

extension GestureModifier {
    @inline(__always)
    nonisolated package static func makeDebuggableGesture(
        modifier: _GraphValue<Self>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<Self.BodyValue>
    ) -> _GestureOutputs<Self.Value> {
        var outputs = _makeGesture(modifier: modifier, inputs: inputs, body: body)
        guard inputs.options.contains(.includeDebugOutput),
              // FIXME
              !(self is PrimitiveDebuggableGesture) else {
            return outputs
        }
        outputs.wrapDebugOutputs(Self.self, inputs: inputs)
        return outputs
    }
}

extension _GestureOutputs {
    @inline(__always)
    package mutating func wrapDebugOutputs<T>(
        _ type: T.Type,
        properties: Attribute<GestureDebug.Properties>? = nil,
        inputs: _GestureInputs
    ) {
        guard inputs.options.contains(.includeDebugOutput) else {
            return
        }
        reallyWrap(
            type,
            kind: conformsToProtocol(type, _gestureModifierProtocolDescriptor()) ? .modifier : .primitive,
            properties: properties,
            inputs: inputs,
            data: (debugData, nil)
        )
    }

    @inline(__always)
    package mutating func wrapDebugOutputs<T, V1, V2>(
        _ type: T.Type,
        kind: GestureDebug.Kind,
        properties: Attribute<GestureDebug.Properties>? = nil,
        inputs: _GestureInputs,
        combiningOutputs outputs: (_GestureOutputs<V1>, _GestureOutputs<V2>)
    ) {
        guard inputs.options.contains(.includeDebugOutput) else {
            return
        }
        reallyWrap(
            type,
            kind: kind,
            properties: properties,
            inputs: inputs,
            data: (outputs.0.debugData, outputs.1.debugData)
        )
    }

    private func reallyWrap<T>(
        _ type: T.Type,
        kind: GestureDebug.Kind,
        properties: Attribute<GestureDebug.Properties>?,
        inputs: _GestureInputs,
        data: (Attribute<GestureDebug.Data>?, Attribute<GestureDebug.Data>?)
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}

@_spi(ForOpenSwiftUIOnly)
extension GesturePhase {
    package var descriptionWithoutValue: String {
        switch self {
        case let .possible(value): value == nil ? "" : "possible(some)"
        case .active: "active"
        case .ended: "ended"
        case .failed: "failed"
        }
    }
}

extension GestureDebug.Data {
    package func printTree() {
        _openSwiftUIUnimplementedFailure()
    }

    private typealias Indent = String

    private func printSubtree(parent: GestureDebug.Data?, indent: Indent) {
        _openSwiftUIUnimplementedFailure()
    }
}
