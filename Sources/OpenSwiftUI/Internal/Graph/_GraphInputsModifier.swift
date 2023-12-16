//
//  _GraphInputsModifier.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/5.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol _GraphInputsModifier {
    static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs)
}
