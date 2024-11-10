//
//  ViewGraphFeature.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package protocol ViewGraphFeature {
    mutating func modifyViewInputs(inputs: inout _ViewInputs, graph: ViewGraph)
    mutating func modifyViewOutputs(outputs: inout _ViewOutputs, inputs: _ViewInputs, graph: ViewGraph)
    mutating func uninstantiate(graph: ViewGraph)
    mutating func isHiddenForReuseDidChange(graph: ViewGraph)
    mutating func allowsAsyncUpdate(graph: ViewGraph) -> Bool?
    mutating func needsUpdate(graph: ViewGraph) -> Bool
    mutating func update(graph: ViewGraph)
}

extension ViewGraphFeature {
    package mutating func modifyViewInputs(inputs: inout _ViewInputs, graph: ViewGraph) {}
    package mutating func modifyViewOutputs(outputs: inout _ViewOutputs, inputs: _ViewInputs, graph: ViewGraph) {}
    package mutating func uninstantiate(graph: ViewGraph) {}
    package mutating func isHiddenForReuseDidChange(graph: ViewGraph) {}
    package mutating func allowsAsyncUpdate(graph: ViewGraph) -> Bool? { true }
    package mutating func needsUpdate(graph: ViewGraph) -> Bool { false }
    package mutating func update(graph: ViewGraph) {}
}
