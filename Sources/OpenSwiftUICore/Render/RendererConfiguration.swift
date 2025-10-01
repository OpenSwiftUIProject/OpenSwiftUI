//
//  RendererConfiguration.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

public struct _RendererConfiguration {
    public enum Renderer {
        case `default`
        indirect case rasterized(_ options: _RendererConfiguration.RasterizationOptions = .init())
    }
    
    public var renderer: _RendererConfiguration.Renderer
    public var minFrameInterval: Double
    public init(renderer: _RendererConfiguration.Renderer = .default) {
        self.renderer = renderer
        self.minFrameInterval = .zero
    }
    
    public static func rasterized(_ options: _RendererConfiguration.RasterizationOptions = .init()) -> _RendererConfiguration {
        _RendererConfiguration(renderer: .rasterized(options))
    }
    
    public struct RasterizationOptions {
        public var colorMode: ColorRenderingMode = .nonLinear
        public var rbColorMode: Int32? = nil
        public var rendersAsynchronously: Bool = false
        public var isOpaque: Bool = true
        public var drawsPlatformViews: Bool = true
        public var prefersDisplayCompositing: Bool = false
        public var maxDrawableCount: Int = 3
        public init() {}
    }
}

@available(*, unavailable)
extension _RendererConfiguration: Sendable {}

@available(*, unavailable)
extension _RendererConfiguration.Renderer: Sendable {}

@available(*, unavailable)
extension _RendererConfiguration.RasterizationOptions: Sendable {}
