//
//  EnvironmentModifier.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: TODO

package import OpenGraphShims

package protocol EnvironmentModifier: _GraphInputsModifier {
    static func makeEnvironment(modifier: Attribute<Self>, environment: inout EnvironmentValues)
}

extension EnvironmentModifier {
    package static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        preconditionFailure("TODO")
    }
}
