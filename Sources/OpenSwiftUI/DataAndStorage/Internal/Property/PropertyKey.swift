//
//  PropertyKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/5.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol PropertyKey {
    associatedtype Value
    static var defaultValue: Value { get }
}
