//
//  RendererLeafView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  ID: 65609C35608651F66D749EB1BD9D2226 (SwiftUICore?)
//  Status: WIP

package import Foundation
import OpenGraphShims

// MARK: - RendererLeafView [TODO]

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

// MARK: - LeafViewLayout

package protocol LeafViewLayout {
    func spacing() -> Spacing
    func sizeThatFits(in proposedSize: _ProposedSize) -> CGSize
}

extension LeafViewLayout {
    package func spacing() -> Spacing {
        Spacing()
    }

    package static func makeLeafLayout(_ outputs: inout _ViewOutputs, view: _GraphValue<Self>, inputs: _ViewInputs) {
        guard inputs.requestsLayoutComputer else {
            return
        }
        outputs.layoutComputer = Attribute(LeafLayoutComputer(view: view.value))
    }
}

// MARK: - LeafLayoutComputer

private struct LeafLayoutComputer<V>: StatefulRule, AsyncAttribute, CustomStringConvertible where V: LeafViewLayout {
    @Attribute
    package var view: V

    typealias Value = LayoutComputer

    mutating func updateValue() {
        let engine = LeafLayoutEngine(view)
        update(to: engine)
    }

    var description: String { "LeafLayoutComputer" }
}

// MARK: - LeafLayoutEngine

package struct LeafLayoutEngine<V>: LayoutEngine where V: LeafViewLayout {
    package let view: V

    private var cache: ViewSizeCache

    package init(_ view: V) {
        self.view = view
        self.cache = ViewSizeCache()
    }

    package func spacing() -> Spacing {
        view.spacing()
    }

    package mutating func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        let view = view
        return cache.get(proposedSize) {
            view.sizeThatFits(in: proposedSize)
        }
    }
}
