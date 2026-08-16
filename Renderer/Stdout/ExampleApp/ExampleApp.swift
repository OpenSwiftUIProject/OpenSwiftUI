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
                Text("OpenSwiftUI stdout renderer")
                    .foregroundStyle(.green)
                Color.red
                Color.blue
            }
        }
    }
}
