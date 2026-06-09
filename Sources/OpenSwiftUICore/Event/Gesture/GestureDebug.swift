//
//  GestureDebug.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 40D5679141F478561068F8E300838A67 (SwiftUICore)

package import Foundation
package import OpenAttributeGraphShims
import OpenSwiftUI_SPI

// MARK: - GestureDebug

package enum GestureDebug {
    package typealias Properties = ArrayWith2Inline<(String, String)>

    package enum Kind: Hashable {
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
            get {
                switch childrenBox {
                case let .value(children):
                    children
                }
            }
            set {
                childrenBox = .value(newValue)
            }
        }

        package init() {
            let box: ChildrenBox = .value(ArrayWith2Inline())
            kind = .empty
            type = EmptyGesture<()>.self
            phase = .failed
            attribute = .init()
            resetSeed = 0
            frame = .zero
            properties = .init()
            childrenBox = box
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
            let box: ChildrenBox = .value(children)
            self.kind = kind
            self.type = type
            self.phase = phase
            self.attribute = AnyOptionalAttribute(attribute)
            self.resetSeed = resetSeed
            self.frame = frame
            self.properties = properties
            self.childrenBox = box
        }
    }

    fileprivate struct Value<PhaseValue>: Rule {
        var kind: GestureDebug.Kind
        var type: any Any.Type
        @OptionalAttribute var properties: GestureDebug.Properties?
        @Attribute var phase: GesturePhase<PhaseValue>
        @Attribute var resetSeed: UInt32
        @Attribute var position: ViewOrigin
        @Attribute var size: ViewSize
        @Attribute var transform: ViewTransform
        @OptionalAttribute var debugData1: GestureDebug.Data?
        @OptionalAttribute var debugData2: GestureDebug.Data?

        var childData: GestureDebug.Data.Children {
            switch (debugData1, debugData2) {
            case (.none, .none):
                GestureDebug.Data.Children()
            case let (.some(debugData), .none), let (.none, .some(debugData)):
                GestureDebug.Data.Children(debugData)
            case let (.some(debugData1), .some(debugData2)):
                GestureDebug.Data.Children(debugData1, debugData2)
            }
        }

        var value: GestureDebug.Data {
            let origin = transform.convert(.localToSpace(.global), point: position)
            let frame = CGRect(origin: origin, size: size.value)
            return GestureDebug.Data(
                kind: kind,
                type: type,
                children: childData,
                phase: phase.withValue(()),
                attribute: $phase.identifier,
                resetSeed: resetSeed,
                frame: frame,
                properties: properties ?? .init()
            )
        }
    }
}

extension GestureDebug.Data: Defaultable {
    package typealias Value = GestureDebug.Data

    package static let defaultValue: GestureDebug.Data = .init()
}

// MARK: - PrimitiveDebuggableGesture

package protocol PrimitiveDebuggableGesture {}

// MARK: - DebuggableGesturePhase

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

// MARK: - makeDebuggableGesture

extension Gesture {
    @inline(__always)
    nonisolated package static func makeDebuggableGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Self.Value> {
        var outputs = _makeGesture(gesture: gesture, inputs: inputs)
        guard inputs.options.contains(.includeDebugOutput),
              !(self is PrimitiveDebuggableGesture.Type) else {
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
              !(self is PrimitiveDebuggableGesture.Type) else {
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

    private mutating func reallyWrap<T>(
        _ type: T.Type,
        kind: GestureDebug.Kind,
        properties: Attribute<GestureDebug.Properties>?,
        inputs: _GestureInputs,
        data: (Attribute<GestureDebug.Data>?, Attribute<GestureDebug.Data>?)
    ) {
        debugData = Attribute(GestureDebug.Value<Value>(
            kind: kind,
            type: type,
            properties: OptionalAttribute(properties),
            phase: phase,
            resetSeed: inputs.resetSeed,
            position: inputs.animatedPosition(),
            size: inputs.viewInputs.size,
            transform: inputs.transform,
            debugData1: OptionalAttribute(data.0),
            debugData2: OptionalAttribute(data.1)
        ))
    }
}

// MARK: - GesturePhase + descriptionWithoutValue

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

// MARK: - GestureDebug.Data + printTree [TBA]

extension GestureDebug.Data {
    package func printTree() {
        printSubtree(parent: nil, indent: Indent(kind: kind))
    }

    private struct Indent {
        var text: String
        var kind: GestureDebug.Kind

        init(_ text: String = "", kind: GestureDebug.Kind = .empty) {
            self.text = text
            self.kind = kind
        }

        var linePrefix: String {
            switch kind {
            case .gesture:
                text + "* "
            case .combiner:
                text + "+ "
            default:
                text
            }
        }

        var childText: String {
            switch kind {
            case .gesture:
                text + "* "
            case .combiner:
                text + "| "
            default:
                text
            }
        }
    }

    private func printSubtree(parent: GestureDebug.Data?, indent: Indent) {
        var line = indent.linePrefix
        let typeDescription = Metadata(type).description
        switch kind {
        case .empty:
            line += "(empty)"
        case .modifier:
            line += ".(\(typeDescription))"
        default:
            line += typeDescription
        }
        if let attribute = attribute.attribute {
            line += " \(attribute.description)"
        }
        line += " (\(phase.descriptionWithoutValue))"
        if resetSeed != 0, parent?.resetSeed != resetSeed {
            line += " reset:\(resetSeed)"
        }
        line += frameDescription(relativeTo: parent)
        if !properties.isEmpty {
            let items = properties.map { "\($0.0): \($0.1)" }
            line += " [\(items.joined(separator: ", "))]"
        }
        Log.eventDebug(line)

        let childIndent = Indent(indent.childText, kind: kind)
        for child in children {
            child.printSubtree(parent: self, indent: childIndent)
        }
    }

    private func frameDescription(relativeTo parent: GestureDebug.Data?) -> String {
        var items: [String] = []
        let size = frame.size
        if parent?.frame.size != size, size != .zero {
            items.append("{\((size.width, size.height))}")
        }

        let origin = frame.origin
        if parent?.frame.origin != origin, origin != .zero {
            items.append("@\((origin.x, origin.y))")
        }
        return items.isEmpty ? "" : " " + items.joined(separator: " ")
    }
}
