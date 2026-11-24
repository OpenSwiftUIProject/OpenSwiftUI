#if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
@_spi(WebRenderer) import OpenSwiftUI
import Foundation
import JavaScriptEventLoop

@main
struct ExampleApp: App {
    private static let installEventLoop: Void = JavaScriptEventLoop.installGlobalExecutor()

    static var rendererConfiguration: _RendererConfiguration? {
        _ = installEventLoop
        return .web(.init(
            surface: CGSize(width: 720.0, height: 480.0),
            eventBridge: CanvasRenderer.eventBridge,
            measureText: CanvasRenderer.measureText,
            onRender: CanvasRenderer.render
        ))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
#endif
