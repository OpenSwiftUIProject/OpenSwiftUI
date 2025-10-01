//
//  ColorView.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Empty

package import Foundation

package struct ColorView: RendererLeafView, Animatable {
    package var color: Color.Resolved
    
    package init(_ color: Color.Resolved) {
        self.color = color
    }

    nonisolated package static func _makeView(view: _GraphValue<ColorView>, inputs: _ViewInputs) -> _ViewOutputs {
        let animatable = makeAnimatable(value: view, inputs: inputs.base)
        return makeLeafView(view: .init(animatable), inputs: inputs)
    }
    
    package var descriptionAttributes: [(name: String, value: String)] {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func contains(points: [PlatformPoint], size: CGSize) -> BitVector64 {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func content() -> DisplayList.Content.Value {
        .color(color)
    }
        
    package var animatableData: Color.Resolved.AnimatableData {
        get { color.animatableData  }
        set { color.animatableData = newValue }
    }
}
