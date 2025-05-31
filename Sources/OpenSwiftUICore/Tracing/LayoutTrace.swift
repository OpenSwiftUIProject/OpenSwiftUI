//
//  LayoutTrace.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

package import Foundation
package import OpenGraphShims

//extension Graph.NamedTraceEvent {
//    package static let update: Graph.NamedTraceEvent
//    package static let sizeThatFits: Graph.NamedTraceEvent
//    package static let lengthThatFits: Graph.NamedTraceEvent
//    package static let childGeometries: Graph.NamedTraceEvent
//    package static let contentDescription: Graph.NamedTraceEvent
//}

package struct LayoutTrace {
    package static func register(graph: Graph) {
        // TODO: OGGraphRegisterNamedTraceEvent
        recorder = Recorder(graph: graph)
    }

    @inline(__always)
    package static var isEnabled: Bool { recorder != nil }

    package static var recorder: LayoutTrace.Recorder?

    final package class Recorder {
        package var graph: Graph
        package var frameActive: Bool
        package var cacheLookup: (proposal: _ProposedSize, hit: Bool)?

        init(graph: Graph) {
            self.graph = graph
            self.frameActive = false
            self.cacheLookup = nil
        }

        func activateFrameIfNeeded() {
            guard !frameActive else { return }
            // TODO
        }

        func traceSizeThatFits(_ attribute: AnyAttribute?, proposal: _ProposedSize, _ block: () -> CGSize) -> CGSize {
            preconditionFailure("TODO")
        }

        func traceLengthThatFits(_ attribute: AnyAttribute?, proposal: _ProposedSize, in axis: Axis, _ block: () -> CGFloat) -> CGFloat {
            preconditionFailure("TODO")
        }

        func traceCacheLookup(_ proposal: _ProposedSize, _ hit: Bool) {
            guard let recorder else {
                return
            }
            recorder.cacheLookup = (proposal, hit)
        }

        func traceCacheLookup(_ proposal: CGSize, _ hit: Bool) {
            guard let recorder else {
                return
            }
            recorder.cacheLookup = (.init(proposal), hit)
        }

        func traceChildGeometries(_ attribute: AnyAttribute?, at parentSize: ViewSize, origin: CGPoint, _ block: () -> [ViewGeometry]) -> [ViewGeometry] {
            preconditionFailure("TODO")
        }

        func traceContentDescription(_ attribute: AnyAttribute?, _ description: String) {
            preconditionFailure("TODO")
        }
    }
}

extension LayoutTrace {
    @inline(__always)
    package static func traceSizeThatFits(_ attribute: AnyAttribute?, proposal: _ProposedSize, _ block: () -> CGSize) -> CGSize {
        recorder!.traceSizeThatFits(attribute, proposal: proposal, block)
    }

    @inline(__always)
    package static func traceLengthThatFits(_ attribute: AnyAttribute?, proposal: _ProposedSize, in axis: Axis, _ block: () -> CGFloat) -> CGFloat {
        recorder!.traceLengthThatFits(attribute, proposal: proposal, in: axis, block)
    }

    @inline(__always)
    package static func traceCacheLookup(_ proposal: _ProposedSize, _ hit: Bool) {
        recorder!.traceCacheLookup(proposal, hit)
    }

    @inline(__always)
    package static func traceCacheLookup(_ proposal: CGSize, _ hit: Bool) {
        recorder!.traceCacheLookup(proposal, hit)
    }

    @inline(__always)
    package static func traceChildGeometries(_ attribute: AnyAttribute?, at parentSize: ViewSize, origin: CGPoint, _ block: () -> [ViewGeometry]) -> [ViewGeometry] {
        recorder!.traceChildGeometries(attribute, at: parentSize, origin: origin, block)
    }

    @inline(__always)
    package static func traceContentDescription(_ attribute: AnyAttribute?, _ description: String) {
        recorder!.traceContentDescription(attribute, description)
    }
}
