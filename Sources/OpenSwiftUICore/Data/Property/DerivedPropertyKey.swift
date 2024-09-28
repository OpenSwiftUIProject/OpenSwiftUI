//
//  DerivedPropertyKey.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

package protocol DerivedPropertyKey {
    associatedtype Value: Equatable
    static func value(in: PropertyList) -> Value
}
