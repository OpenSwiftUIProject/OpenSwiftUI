//
//  EnvironmentalView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

package protocol EnvironmentalView: PrimitiveView, UnaryView {
    associatedtype EnvironmentBody: View
    func body(environment: EnvironmentValues) -> EnvironmentBody
}

extension EnvironmentalView {
    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        preconditionFailure("")
    }
}
