//
//  DerivedPropertyKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/5.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol DerivedPropertyKey {
    associatedtype Value: Equatable
    static func value(in: PropertyList) -> Value
}
