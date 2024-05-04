//
//  _GraphInputsModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

public protocol _GraphInputsModifier {
    static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs)
}
