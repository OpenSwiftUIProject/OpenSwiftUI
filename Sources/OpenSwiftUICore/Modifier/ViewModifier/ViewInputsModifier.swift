//
//  ViewInputsModifier.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

package protocol ViewInputsModifier: ViewModifier where Body == Never {
    static var graphInputsSemantics: Semantics? { get }
    nonisolated static func _makeViewInputs(modifier: _GraphValue<Self>, inputs: inout _ViewInputs)
}
