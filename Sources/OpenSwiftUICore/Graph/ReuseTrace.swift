//
//  ReuseTrace.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

package import OpenGraphShims

package struct ReuseTrace {
    package static func register(graph: Graph) {
        recorder = Recorder(graph: graph)
    }
    
    @inline(__always)
    package static var isEnabled: Bool { recorder != nil }
    
    package static var recorder: ReuseTrace.Recorder?
    
    @inline(__always)
    package static func traceReuseFailure(_ name: UnsafePointer<CChar>) {
        // TODO
        // guard let recorder else { return }
        // OGGraphAddTraceEvent
        // recorder.graph.addTraceEvent(name)
    }
    
    @inline(__always)
    package static func traceReuseInternalFailure() {
        traceReuseFailure("resuse_internal")
    }
    
    @inline(__always)
    package static func traceReuseViewInputsDifferentFailure() {
        traceReuseFailure("reuse_inputsDifferent")
    }

    @inline(__always)
    package static func traceReuseUnaryElementExpectedFailure(_ elementType: any Any.Type) {
        traceReuseFailure("reuse_unaryElement")
    }

    @inline(__always)
    package static func traceReuseInvalidSubgraphFailure(_ typeFoundInvalid: any Any.Type) {
        // FIXME: ReuseTraceInternal.InvalidSubgraphFailure
        traceReuseFailure("reuse_invalidSubgraph")
    }

    @inline(__always)
    package static func traceReuseBodyMismatchedFailure() {
        traceReuseFailure("reuse_bodyMismatched")
    }

    // TODO
    
    final package class Recorder {
        var graph: Graph
        var frameActive: Bool = false

        @inline(__always)
        init(graph: Graph) {
            self.graph = graph
        }
    }
}
