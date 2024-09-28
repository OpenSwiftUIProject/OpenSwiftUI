//
//  _GraphInputsModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2024
//  Status: Complete

/// Protocol for modifiers that only modify their children's inputs.
public protocol _GraphInputsModifier {
    static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs)
}
