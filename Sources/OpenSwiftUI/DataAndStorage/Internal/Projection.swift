//
//  Projection.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/2.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol Projection: Hashable {
    associatedtype Base
    associatedtype Projected
    func get(base: Base) -> Projected
    func set(base: inout Base, newValue: Projected)
}
