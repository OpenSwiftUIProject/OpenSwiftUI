//
//  RemovableAttribute.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

internal import OpenGraphShims

protocol RemovableAttribute: _AttributeBody {
    static func willRemove(attribute: AnyAttribute)
    static func didReinsert(attribute: AnyAttribute)
}
