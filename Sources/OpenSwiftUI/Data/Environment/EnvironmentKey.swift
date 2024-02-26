//
//  EnvironmentKey.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

public protocol EnvironmentKey {
    associatedtype Value

    @inline(__always)
    static var defaultValue: Value { get }
}
