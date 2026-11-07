//
//  IntelligenceLightSource.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 92AD8414A5A88FE2AC36477864AB44D8 (SwiftUICore)

#if os(iOS) || os(visionOS)
import OpenCoreGraphicsShims
import OpenSwiftUI_SPI

extension Material.ResolvedMaterial {
    package func visitIntelligenceLightSourceLayers<V: MaterialLayerVisitor>(_ visitor: inout V) {
        visitor.visit(layer: IntelligenceLightSourceLayer(
            colorScheme: colorScheme,
            prefersAudioReactivity: id == .intelligenceLightSource_AudioReactive
        ))
    }
}

private struct IntelligenceLightSourceLayer: MaterialLayer, PlatformViewFactory {
    var colorScheme: ColorScheme
    var prefersAudioReactivity: Bool

    var content: DisplayList.Content.Value {
        .platformView(self)
    }

    var viewType: any Any.Type {
        EmptyView.self
    }

    func makePlatformView() -> AnyObject? {
        CoreViewMakeIntelligenceLightSourceView(reactive: prefersAudioReactivity) as AnyObject?
    }

    func updatePlatformView(_ view: inout AnyObject) {
        CoreViewUpdateIntelligenceLightSourceView(view: view, reactive: prefersAudioReactivity)
    }

    func renderPlatformView(
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    ) {
        ctx.renderMissingPlatformView(size: size)
    }

    var features: DisplayList.Features {
        []
    }
}
#endif
