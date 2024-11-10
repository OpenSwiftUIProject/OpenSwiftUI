//
//  BodyAccessorRule.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

package import OpenGraphShims

package protocol BodyAccessorRule {
    static var container: Any.Type { get }
    static func value<Value>(as: Value.Type, attribute: AnyAttribute) -> Value?
    static func buffer<Value>(as: Value.Type, attribute: AnyAttribute) -> _DynamicPropertyBuffer?
    static func metaProperties<Value>(as: Value.Type, attribute: AnyAttribute) -> [(String, AnyAttribute)]
}
