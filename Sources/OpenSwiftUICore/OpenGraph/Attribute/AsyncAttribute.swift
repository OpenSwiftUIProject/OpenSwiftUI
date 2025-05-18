//
//  AsyncAttribute.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

package import OpenGraphShims

package protocol AsyncAttribute: _AttributeBody {}

extension AsyncAttribute {
    package static var flags: OGAttributeTypeFlags { [] }
}

extension Attribute {
    package func syncMainIfReferences<V>(do body: (Value) -> V) -> V {
        let (value, flags) = valueAndFlags(options: [._2])
        if flags.contains(.requiresMainThread) {
            var result: V?
            Update.syncMain {
                result = body(value)
            }
            return result!
        } else {
            return body(value)
        }
    }
}

// FIXME: Add OGChangedValueFlagsRequiresMainThread in OpenGraph

extension OGChangedValueFlags {
    static let requiresMainThread = Self(rawValue: 2)
}
