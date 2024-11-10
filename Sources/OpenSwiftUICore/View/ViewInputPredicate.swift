//
//  ViewInputPredicate.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

protocol ViewInputPredicate {
    static func evaluate(inputs: _GraphInputs) -> Bool
}
