//
//  Defaultable.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol Defaultable {
    associatedtype Value
    static var defaultValue: Value { get }
}
