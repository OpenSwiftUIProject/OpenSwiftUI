//
//  PrimitiveView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol ViewInputPredicate {
    static func evaluate(inputs: _GraphInputs) -> Bool
}
