//
//  ViewGraphDelegate.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol ViewGraphDelegate: GraphDelegate {
    func modifyViewInputs(_ inputs: inout _ViewInputs)
    func updateViewGraph<Value>(body: (ViewGraph) -> Value) -> Value
    func outputsDidChange(outputs: ViewGraph.Outputs) -> ()
    func focusDidChange()
    func rootTransform() -> ViewTransform
}
