//
//  RendererLeafView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

package import Foundation

package protocol RendererLeafView: /*ContentResponder,*/ PrimitiveView, UnaryView {
    static var requiresMainThread: Bool { get }
    func content() -> DisplayList.Content.Value
}

extension RendererLeafView {
    package static var requiresMainThread: Swift.Bool {
        false
    }
    
    func contains(points: [PlatformPoint], size: CGSize) -> BitVector64 {
        preconditionFailure("TODO")
    }
    
    package static func makeLeafView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        // preconditionFailure("TODO")
        _ViewOutputs()
    }
}

package protocol LeafViewLayout {
    func spacing() -> Spacing
    func sizeThatFits(in proposedSize: _ProposedSize) -> CGSize
}

extension LeafViewLayout {
    package func spacing() -> Spacing {
        preconditionFailure("")
    }

    package static func makeLeafLayout(_ outputs: inout _ViewOutputs, view: _GraphValue<Self>, inputs: _ViewInputs) {
        preconditionFailure("TODO")
    }
}
