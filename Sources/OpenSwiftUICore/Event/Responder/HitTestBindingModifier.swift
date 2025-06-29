//
//  HitTestBindingModifier.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: D16C83991EAE21A87411739F6DC01498 (SwiftUICore)

package import Foundation

package typealias PlatformHitTestableEvent = HitTestableEvent

package struct HitTestBindingModifier: ViewModifier, MultiViewModifier, PrimitiveViewModifier {
    nonisolated package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        openSwiftUIUnimplementedWarning()
        return body(_Graph(), inputs)
    }

    package typealias Body = Never
}

extension ViewResponder {
    package static var hitTestKey: UInt32 { preconditionFailure("TODO") }

    package static let minOpacityForHitTest: Double = 0.0

    package func hitTest(
        globalPoint: PlatformPoint,
        radius: CGFloat,
        cacheKey: UInt32? = nil,
        options: ContainsPointsOptions = .platformDefault
    ) -> ViewResponder? {
        openSwiftUIUnimplementedFailure()
    }

    private func hitTest(
        globalPoints: [PlatformPoint],
        weights: [Double],
        mask: BitVector64,
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ViewResponder? {
        openSwiftUIUnimplementedFailure()
    }
}

private func hitPoints(point: PlatformPoint, radius: CGFloat) -> ([PlatformPoint], [Double]) {
    openSwiftUIUnimplementedFailure()
}
