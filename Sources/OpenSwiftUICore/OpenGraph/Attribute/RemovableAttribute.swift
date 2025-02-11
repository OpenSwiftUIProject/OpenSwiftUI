//
//  RemovableAttribute.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

package import OpenGraphShims

package protocol RemovableAttribute: _AttributeBody {
    static func willRemove(attribute: AnyAttribute)
    static func didReinsert(attribute: AnyAttribute)
}
