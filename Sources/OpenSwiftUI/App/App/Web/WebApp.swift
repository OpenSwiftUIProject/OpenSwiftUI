//
//  WebApp.swift
//  OpenSwiftUI
//

#if !OPENSWIFTUI_SWIFTUI_RENDERER
@_spi(WebRenderer) import OpenSwiftUICore

// MARK: - runWebApp

func runWebApp(
    _ app: some App,
    options: _RendererConfiguration.WebOptions
) {
    renderHeadlessApp(
        app,
        surface: options.surface,
        configuration: .web(options)
    )
}
#endif
