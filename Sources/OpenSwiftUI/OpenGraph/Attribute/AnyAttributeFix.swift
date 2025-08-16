//
//  AnyAttributeFix.swift
//  OpenSwiftUI

#if OPENSWIFTUI_ANY_ATTRIBUTE_FIX
package import OpenGraphShims

package typealias AnyAttribute = OpenSwiftUICore.AnyAttribute
package typealias AttributeInfo = OpenSwiftUICore.AttributeInfo

package typealias AttributeType = OpenSwiftUICore.AttributeType

extension AnyAttribute {
    package static var `nil`: AnyAttribute { AnyAttribute(rawValue: 0x2) }

    package var source: AnyAttribute? {
        get { preconditionFailure("#39") }
        nonmutating set { preconditionFailure("#39") }
    }

    package var info: AttributeInfo {
        preconditionFailure("#39")
    }

    package var graph: Graph {
        preconditionFailure("#39")
    }

    package func invalidateValue() {
        preconditionFailure("#39")
    }

    package func createIndirect() -> AnyAttribute {
        preconditionFailure("#39")
    }
}

extension AnyAttribute {
    package init<Value>(_ attribute: Attribute<Value>) {
        self = Swift.unsafeBitCast(attribute, to: AnyAttribute.self)
    }

    package func unsafeCast<Value>(to type: Value.Type) -> Attribute<Value> {
        Swift.unsafeBitCast(self, to: Attribute<Value>.self)
    }

    package static var current: AnyAttribute? {
        preconditionFailure("#39")
    }

    package func unsafeOffset(at offset: Int) -> AnyAttribute {
        preconditionFailure("#39")
    }

    package func setFlags(_ newFlags: Flags, mask: Flags) {
        preconditionFailure("#39")
    }

    package func addInput(_ attribute: AnyAttribute, options: OGInputOptions = [], token: Int) {
        preconditionFailure("#39")
    }

    package func addInput<Value>(_ attribute: Attribute<Value>, options: OGInputOptions = [], token: Int) {
        preconditionFailure("#39")
    }

    package func visitBody<Visitor>(_ visitor: inout Visitor) where Visitor: AttributeBodyVisitor {
        preconditionFailure("#39")
    }

    package func mutateBody<Value>(as: Value.Type, invalidating: Bool, _ body: (inout Value) -> Void) {
        preconditionFailure("#39")
    }

    package func breadthFirstSearch(options: SearchOptions = [], _: (AnyAttribute) -> Bool) -> Bool {
        preconditionFailure("#39")
    }

    package var _bodyType: any Any.Type {
        preconditionFailure("#39")
    }

    package var _bodyPointer: UnsafeRawPointer {
        preconditionFailure("#39")
    }

    package var valueType: any Any.Type {
        preconditionFailure("#39")
    }

    package var indirectDependency: AnyAttribute? {
        get { preconditionFailure("#39") }
        nonmutating set { preconditionFailure("#39") }
    }
}

extension Attribute {
    package init(identifier: AnyAttribute) {
        self = Swift.unsafeBitCast(identifier.rawValue, to: Attribute.self)
    }

    package var identifier: AnyAttribute {
        get { AnyAttribute(rawValue: Swift.unsafeBitCast(self, to: UInt32.self)) }
        nonmutating set { preconditionFailure("#39") }
    }
}

extension AnyWeakAttribute {
    package var attribute: AnyAttribute? {
        preconditionFailure("#39")
    }

    package init(_ attribute: AnyAttribute?) {
        preconditionFailure("#39")
    }
}

extension IndirectAttribute {
    package var identifier: AnyAttribute {
        AnyAttribute(rawValue: Swift.unsafeBitCast(self, to: UInt32.self))
    }
}

extension AnyRuleContext {
    package init(attribute: AnyAttribute) {
        self = Swift.unsafeBitCast(attribute.rawValue, to: AnyRuleContext.self)
    }

    package var attribute: AnyAttribute { AnyAttribute(rawValue: Swift.unsafeBitCast(self, to: UInt32.self)) }
}

extension AnyOptionalAttribute {
    package static var current: AnyOptionalAttribute {
        preconditionFailure("#39")
    }

    package var identifier: AnyAttribute { AnyAttribute(rawValue: Swift.unsafeBitCast(self, to: UInt32.self)) }

    package var attribute: AnyAttribute? {
        get { preconditionFailure("#39") }
        nonmutating set { preconditionFailure("#39") }
    }
}

extension Graph {
    package func onInvalidation(_ callback: @escaping (AnyAttribute) -> Void) {
        preconditionFailure("#39")
    }
}

extension Subgraph {
    package func forEach(_ flags: AnyAttribute.Flags, _ callback: (AnyAttribute) -> Void) {
        preconditionFailure("#39")
    }

    package func isDirty(flags: AnyAttribute.Flags) -> Bool {
        preconditionFailure("#39")
    }

    package func update(flags: AnyAttribute.Flags) {
        preconditionFailure("#39")
    }
}

extension Graph {
    package static func anyInputsChanged(excluding excludedInputs: [AnyAttribute]) -> Bool {
        preconditionFailure("#39")
    }
}

extension Attribute {
    package func setFlags(_ newFlags: AnyAttribute.Flags, mask: AnyAttribute.Flags) {
        preconditionFailure("#39")
    }

    var flags: AnyAttribute.Flags {
        get { preconditionFailure("#39") }
        nonmutating set { preconditionFailure("#39") }
    }
}

#endif
