@_spi(StdoutRenderer) import OpenSwiftUI

@main
struct ExampleApp: App {
    static var rendererConfiguration: _RendererConfiguration? {
        var options = _RendererConfiguration.StdoutOptions()
        options.viewMode = .terminal
        options.terminalSize = .init(columns: 48, rows: 16)
        return .stdout(options)
    }

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 10.0) {
                #if canImport(Darwin)
                Text("OpenSwiftUI stdout renderer")
                    .foregroundStyle(.green)
                #endif
                Color.red
                Color.blue
            }
        }
    }
}
