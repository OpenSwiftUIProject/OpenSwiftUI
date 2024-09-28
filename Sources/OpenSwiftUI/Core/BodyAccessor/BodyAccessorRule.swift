//
//  BodyAccessorRule.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

internal import OpenGraphShims

protocol BodyAccessorRule {
    static var container: Any.Type { get }
    static func value<Value>(as: Value.Type, attribute: AnyAttribute) -> Value?
    static func buffer<Value>(as: Value.Type, attribute: AnyAttribute) -> _DynamicPropertyBuffer?
    static func metaProperties<Value>(as: Value.Type, attribute: AnyAttribute) -> [(String, AnyAttribute)]
}
