//
//  ViewTraitKey.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

public protocol _ViewTraitKey {
    associatedtype Value
    static var defaultValue: Value { get }
}
