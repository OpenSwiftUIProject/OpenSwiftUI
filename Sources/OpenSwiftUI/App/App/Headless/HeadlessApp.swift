//
//  HeadlessApp.swift
//  OpenSwiftUI
//

#if !OPENSWIFTUI_SWIFTUI_RENDERER
import Foundation
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

// MARK: - renderHeadlessApp

@discardableResult
func renderHeadlessApp(
    _ app: some App,
    surface: CGSize,
    configuration: _RendererConfiguration
) -> AnyObject? {
    Update.dispatchImmediately(reason: nil) {
        let graph = AppGraph(app: app)
        graph.instantiate()
        AppGraph.shared = graph
        guard let item = graph.rootSceneList?.items.first else {
            print("OpenSwiftUI headless renderer: no scene to render")
            return nil
        }
        #if canImport(Darwin)
        let rootView = item.value.view
            .frame(width: surface.width, height: surface.height)
            .rootEnvironment(scenePhase: .active, sceneID: item.id)
        #else
        let rootView = item.value.view
            .frame(width: surface.width, height: surface.height)
        #endif
        let host = HeadlessRendererHost(
            rootView: rootView,
            environment: item.environment,
            surface: surface,
            configuration: configuration
        )
        #if os(WASI)
        let baseView = item.value.view
        host.rootViewForSurface = { updatedSurface in
            baseView.frame(width: updatedSurface.width, height: updatedSurface.height)
        }
        #endif
        host.renderOnce()
        return host
    }
}
#endif
