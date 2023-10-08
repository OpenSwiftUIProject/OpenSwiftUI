//
//  PrimitiveView.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/24.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol ViewInputPredicate {
    static func evaluate(inputs: _GraphInputs) -> Bool
}
