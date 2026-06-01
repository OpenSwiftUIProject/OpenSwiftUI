@_spi(StdoutRenderer) import OpenSwiftUI

@main
struct ExampleApp: App {
    static var _rendererConfiguration: _RendererConfiguration? { .stdout() }

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 10.0) {
                Color.red
                Color.blue
            }
        }
    }
}
