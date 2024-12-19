//
//  ViewGraphFeature.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 8A0FC0E1EA10CEEE185C2315B618A95C (SwiftUICore)

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

struct ViewGraphFeatureBuffer/*: Collection*/ {
//    subscript(position: UnsafeHeterogeneousBuffer.Index) -> Element {
//        _read {
//            <#code#>
//        }
//    }
//    
//    var startIndex: UnsafeHeterogeneousBuffer.Index { contents.startIndex }
//    var endIndex: UnsafeHeterogeneousBuffer.Index { contents.endIndex }
//    
//    
    var contents: UnsafeHeterogeneousBuffer
    
    typealias Index = UnsafeHeterogeneousBuffer.Index
    
    struct Element {
        var base: UnsafeHeterogeneousBuffer.Element
    }
    
    mutating func append<Feature>(_ feature: Feature) -> UnsafeHeterogeneousBuffer.Index where Feature: ViewGraphFeature {
        contents.append(feature, vtable: _VTable<Feature>.self)
    }
    
    subscript<Feature>(index: UnsafeHeterogeneousBuffer.Index) -> UnsafeMutablePointer<Feature>? {
        // TODO
        nil
    }
    
    private class VTable: _UnsafeHeterogeneousBuffer_VTable {
        class func modifyViewInputs(elt: UnsafeHeterogeneousBuffer.Element, inputs: inout _ViewInputs, graph: ViewGraph) {}
        class func modifyViewOutputs(elt: UnsafeHeterogeneousBuffer.Element, outputs: inout _ViewOutputs, inputs: _ViewInputs, graph: ViewGraph) {}
        class func uninstantiate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {}
        class func isHiddenForReuseDidChange(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {}
        class func needsUpdate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) -> Bool { false }
        class func allowsAsyncUpdate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) -> Bool? { nil }
        class func update(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {}
    }
    
    private final class _VTable<Feature>: VTable where Feature: ViewGraphFeature{
        override class func hasType<T>(_ type: T.Type) -> Bool {
            Feature.self == T.self
        }
        
        override class func moveInitialize(elt: UnsafeHeterogeneousBuffer.Element, from: _UnsafeHeterogeneousBuffer_Element) {
            let dest = elt.body(as: Feature.self)
            let source = from.body(as: Feature.self)
            dest.initialize(to: source.move())
        }
        
        override class func deinitialize(elt: UnsafeHeterogeneousBuffer.Element) {
            elt.body(as: Feature.self).deinitialize(count: 1)
        }
        
        override class func modifyViewInputs(elt: UnsafeHeterogeneousBuffer.Element, inputs: inout _ViewInputs, graph: ViewGraph) {
            elt.body(as: Feature.self).pointee.modifyViewInputs(inputs: &inputs, graph: graph)
        }
        
        override class func modifyViewOutputs(elt: UnsafeHeterogeneousBuffer.Element, outputs: inout _ViewOutputs, inputs: _ViewInputs, graph: ViewGraph) {
            elt.body(as: Feature.self).pointee.modifyViewOutputs(outputs: &outputs, inputs: inputs, graph: graph)
        }
        
        override class func uninstantiate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {
            elt.body(as: Feature.self).pointee.uninstantiate(graph: graph)
        }
        
        override class func isHiddenForReuseDidChange(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {
            elt.body(as: Feature.self).pointee.isHiddenForReuseDidChange(graph: graph)
        }
        
        override class func needsUpdate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) -> Bool {
            elt.body(as: Feature.self).pointee.needsUpdate(graph: graph)
        }
        
        override class func allowsAsyncUpdate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) -> Bool? {
            elt.body(as: Feature.self).pointee.allowsAsyncUpdate(graph: graph)
        }
        
        override class func update(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {
            elt.body(as: Feature.self).pointee.update(graph: graph)
        }
    }
}
