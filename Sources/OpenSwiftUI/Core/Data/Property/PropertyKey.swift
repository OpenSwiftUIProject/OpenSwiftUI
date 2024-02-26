//
//  PropertyKey.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol PropertyKey {
    associatedtype Value
    static var defaultValue: Value { get }
}
