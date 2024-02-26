//
//  DerivedPropertyKey.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol DerivedPropertyKey {
    associatedtype Value: Equatable
    static func value(in: PropertyList) -> Value
}
