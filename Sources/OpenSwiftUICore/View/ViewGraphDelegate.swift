//
//  ViewGraphDelegate.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

package protocol ViewGraphDelegate: GraphDelegate {
    func modifyViewInputs(_ inputs: inout _ViewInputs)
    func updateViewGraph<Value>(body: (ViewGraph) -> Value) -> Value
    func outputsDidChange(outputs: ViewGraph.Outputs) -> ()
    func focusDidChange()
    func rootTransform() -> ViewTransform
}

extension ViewGraphDelegate {
    public func updateGraph<V>(body: (GraphHost) -> V) -> V {
        updateViewGraph(body: body)
    }
    
    public func rootTransform() -> ViewTransform {
        ViewTransform()
    }
}
