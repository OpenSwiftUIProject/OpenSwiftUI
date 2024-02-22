//
//  BodyAccessorRule.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/2/21.
//  Lastest Version: iOS 15.5
//  Status: Complete

internal import OpenGraphShims

protocol BodyAccessorRule {
    static var container: Any.Type { get }
    static func value<Value>(as: Value.Type, attribute: OGAttribute) -> Value?
    static func buffer<Value>(as: Value.Type, attribute: OGAttribute) -> _DynamicPropertyBuffer?
    static func metaProperties<Value>(as: Value.Type, attribute: OGAttribute) -> [(String, OGAttribute)]
}
