//
//  InvalidatableAttribute.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

package import OpenGraphShims

// TODO: PlatformViewChild in _A513612C07DFA438E70B9FA90719B40D

package protocol InvalidatableAttribute: _AttributeBody {
    static func willInvalidate(attribute: AnyAttribute)
}
