//
//  RemovableAttribute.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

package import OpenGraphShims

package protocol RemovableAttribute: _AttributeBody {
    static func willRemove(attribute: AnyAttribute)
    static func didReinsert(attribute: AnyAttribute)
}
