//
//  CALayerView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenQuartzCoreShims
public import OpenSwiftUICore

@available(OpenSwiftUI_v2_0, *)
public struct _CALayerView<LayerType>: View where LayerType: CALayer {
    /// The function used to update the layer instance.
    public var update: (LayerType) -> Void
}

@available(*, unavailable)
extension _CALayerView: Sendable {}

@available(OpenSwiftUI_v2_0, *)
extension _CALayerView: RendererLeafView, PlatformLayerFactory {
    /// Initializes with a layer type, and a function to update the
    /// layer whenever the view value changes.
    nonisolated public init(type: LayerType.Type, onUpdate update: @escaping (LayerType) -> Void) {
        self.update = update
    }

    nonisolated public static func _makeView(
        view: _GraphValue<_CALayerView<LayerType>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        makeLeafView(view: view, inputs: inputs)
    }

    package static var requiresMainThread: Bool {
        true
    }

    package func content() -> DisplayList.Content.Value {
        .platformLayer(self)
    }

    package var platformLayerType: CALayer.Type {
        LayerType.self
    }

    package func updatePlatformLayer(_ layer: CALayer) {
        update(layer as! LayerType)
    }
}

@available(OpenSwiftUI_v2_0, *)
extension _CALayerView where LayerType == CALayer {
    /// Initializes with a function to update the layer whenever the
    /// view value changes.
    nonisolated public init(onUpdate update: @escaping (LayerType) -> Void) {
        self.update = update
    }
}
