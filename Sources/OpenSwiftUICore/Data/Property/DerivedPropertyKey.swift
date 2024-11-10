//
//  DerivedPropertyKey.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package protocol DerivedPropertyKey {
    associatedtype Value: Equatable
    static func value(in: PropertyList) -> Value
}
