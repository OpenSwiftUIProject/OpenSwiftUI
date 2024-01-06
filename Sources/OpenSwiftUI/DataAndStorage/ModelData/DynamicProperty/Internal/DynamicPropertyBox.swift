//
//  DynamicPropertyBox.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/3.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol DynamicPropertyBox<Property>: DynamicProperty {
    associatedtype Property: DynamicProperty
    func destroy()
    func reset()
    func update(property: inout Property, phase: _GraphInputs.Phase) -> Bool
    func getState<Value>(type: Value.Type) -> Binding<Value>?
}

extension DynamicPropertyBox {
    func getState<Value>(type _: Value.Type) -> Binding<Value>? { nil }
}
