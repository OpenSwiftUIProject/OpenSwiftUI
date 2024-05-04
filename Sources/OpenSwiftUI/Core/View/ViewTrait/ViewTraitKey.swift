//
//  ViewTraitKey.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol _ViewTraitKey {
    associatedtype Value
    static var defaultValue: Value { get }
}
