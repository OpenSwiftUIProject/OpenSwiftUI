//
//  AsyncAttribute.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

package import OpenGraphShims

package protocol AsyncAttribute: _AttributeBody {}

extension AsyncAttribute {
    package static var flags: OGAttributeTypeFlags { [] }
}

extension Attribute {
    package func syncMainIfReferences<V>(do body: (Value) -> V) -> V {
        fatalError("TODO")
    }
}
