//
//  RendererEffect.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 49800242E3DD04CB91F7CE115272DDC3 (SwiftUICore)

package import Foundation

// MARK: - _RendererEffect [6.5.4] [WIP]

package protocol _RendererEffect: MultiViewModifier, PrimitiveViewModifier {
    func effectValue(size: CGSize) -> DisplayList.Effect

    static var isolatesChildPosition: Bool { get }

    static var disabledForFlattenedContent: Bool { get }

    static var preservesEmptyContent: Bool { get }

    static var isScrapeable: Bool { get }

    // var scrapeableContent: ScrapeableContent.Content? { get }
}

extension _RendererEffect {
    package static var isolatesChildPosition: Bool {
        false
    }

    package static var disabledForFlattenedContent: Bool {
        false
    }

    package static var preservesEmptyContent: Bool {
        false
    }

    package static var isScrapeable: Bool {
        false
    }

//    package var scrapeableContent: ScrapeableContent.Content? {
//        nil
//    }

    package static func _makeRendererEffect(
        effect: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        if isScrapeable {
            // TOOD: Handle scrapeable content
        }
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - RendererEffect [6.5.4]

package protocol RendererEffect: Animatable, _RendererEffect {}

@available(OpenSwiftUI_v1_0, *)
extension RendererEffect {
    package static func makeRendererEffect(
        effect: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        guard inputs.needsGeometry || inputs.preferences.requiresDisplayList else {
            return body(_Graph(), inputs)
        }
        var effect = effect
        _makeAnimatable(value: &effect, inputs: inputs.base)
        return _makeRendererEffect(effect: effect, inputs: inputs, body: body)
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeRendererEffect(effect: modifier, inputs: inputs, body: body)
    }

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }
}
