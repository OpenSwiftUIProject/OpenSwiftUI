//
//  DerivedEnvironmentKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/25.
//  Lastest Version: iOS 15.5
//  Status: Complete

import Foundation

protocol DerivedEnvironmentKey {
    associatedtype Value: Equatable
    static func value(in: EnvironmentValues) -> Value
}
