//
//  ViewTraitKey.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

public protocol _ViewTraitKey {
    associatedtype Value
    static var defaultValue: Value { get }
}
