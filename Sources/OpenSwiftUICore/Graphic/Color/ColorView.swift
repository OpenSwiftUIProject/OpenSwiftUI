//
//  ColorView.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

package struct ColorView: RendererLeafView, Animatable {
    package var color: Color.Resolved

    package init(_ color: Color.Resolved) {
        self.color = color
    }

    nonisolated package static func _makeView(
        view: _GraphValue<ColorView>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let animatable = makeAnimatable(value: view, inputs: inputs.base)
        return makeLeafView(view: .init(animatable), inputs: inputs)
    }

    package var descriptionAttributes: [(name: String, value: String)] {
        guard color != .clear else { return [] }
        return [(name: "color", value: "\((color.red, color.green, color.blue, color.opacity))")]
    }

    package func contains(points: UnsafeBufferPointer<PlatformPoint>, size: CGSize) -> BitVector64 {
        guard color.opacity > 0 else { return BitVector64() }
        return points.mapBool {
            min($0.x, $0.y) >= 0 && $0.x < size.width && $0.y < size.height
        }
    }

    package func content() -> DisplayList.Content.Value {
        .color(color)
    }

    package var animatableData: Color.Resolved.AnimatableData {
        get { color.animatableData }
        set { color.animatableData = newValue }
    }
}
