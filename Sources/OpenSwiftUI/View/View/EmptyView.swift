//
//  EmptyView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

public struct EmptyView: PrimitiveView {
    public init() {}
    
    public static func _makeView(view: _GraphValue<EmptyView>, inputs: _ViewInputs) -> _ViewOutputs {
        _ViewOutputs()
    }
}
