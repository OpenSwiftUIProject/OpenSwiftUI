//
//  Defaultable.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/16.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol Defaultable {
    associatedtype Value
    static var defaultValue: Value { get }
}
