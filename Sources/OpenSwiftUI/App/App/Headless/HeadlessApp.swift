//
//  HeadlessApp.swift
//  OpenSwiftUI
//

#if !OPENSWIFTUI_SWIFTUI_RENDERER
import Foundation
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

// MARK: - renderHeadlessApp

func renderHeadlessApp(
    _ app: some App,
    surface: CGSize,
    configuration: _RendererConfiguration
) {
    Update.dispatchImmediately(reason: nil) {
        let graph = AppGraph(app: app)
        graph.instantiate()
        AppGraph.shared = graph
        guard let item = graph.rootSceneList?.items.first else {
            print("OpenSwiftUI headless renderer: no scene to render")
            return
        }
        #if os(macOS) || os(iOS) || os(visionOS)
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
        host.renderOnce()
    }
}
#endif
