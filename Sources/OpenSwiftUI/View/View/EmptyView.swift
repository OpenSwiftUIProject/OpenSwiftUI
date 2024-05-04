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
    
    public static func _makeViewList(view: _GraphValue<EmptyView>, inputs: _ViewListInputs) -> _ViewListOutputs {
        fatalError("TODO")
    }
    
    public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        0
    }
}
