//
//  ViewInputFlag.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

protocol ViewInputFlag: PrimitiveViewModifier, ViewInputPredicate, _GraphInputsModifier {
    associatedtype Input: ViewInput where Input.Value: Equatable
    static var value: Input.Value { get }
    init()
}

extension ViewInputFlag {
    static func _makeInputs(modifier _: _GraphValue<Self>, inputs: inout _GraphInputs) {
        inputs[Input.self] = value
    }

    static func evaluate(inputs: _GraphInputs) -> Bool {
        inputs[Input.self] == value
    }
}
