//
//  DynamicPropertyBox.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol DynamicPropertyBox<Property>: DynamicProperty {
    associatedtype Property: DynamicProperty
    func destroy()
    func reset()
    mutating func update(property: inout Property, phase: _GraphInputs.Phase) -> Bool
    func getState<Value>(type: Value.Type) -> Binding<Value>?
}

extension DynamicPropertyBox {
    func getState<Value>(type _: Value.Type) -> Binding<Value>? { nil }
}
