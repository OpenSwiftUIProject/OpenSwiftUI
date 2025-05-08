//
//  ColorView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Empty

package import Foundation

package struct ColorView: RendererLeafView, Animatable {
    package var color: Color.Resolved
    
    package init(_ color: Color.Resolved) {
        self.color = color
    }

    nonisolated package static func _makeView(view: _GraphValue<ColorView>, inputs: _ViewInputs) -> _ViewOutputs {
        var inputs = inputs
        if inputs.base.options.isEmpty {
            // TODO: AnimatableAttribute
        }
        return makeLeafView(view: view, inputs: inputs)
    }
    
    package var descriptionAttributes: [(name: String, value: String)] {
        preconditionFailure("TODO")
    }
    
    package func contains(points: [PlatformPoint], size: CGSize) -> BitVector64 {
        preconditionFailure("TODO")
    }
    
    package func content() -> DisplayList.Content.Value {
        .color(color)
    }
        
    package var animatableData: Color.Resolved.AnimatableData {
        get { color.animatableData  }
        set { color.animatableData = newValue }
    }
}
