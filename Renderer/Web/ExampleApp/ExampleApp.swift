@_spi(WebRenderer) import OpenSwiftUI
import Foundation
import JavaScriptEventLoop
import JavaScriptKit

@main
struct ExampleApp: App {
    private static let installEventLoop: Void = JavaScriptEventLoop.installGlobalExecutor()

    static var rendererConfiguration: _RendererConfiguration? {
        _ = installEventLoop
        return .web(.init(
            surface: CGSize(width: 720.0, height: 480.0),
            onRender: CanvasRenderer.render
        ))
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black
                VStack(spacing: 24.0) {
                    HStack(spacing: 24.0) {
                        Color.blue
                            .frame(width: 240.0, height: 176.0)
                        Color.purple
                            .frame(width: 360.0, height: 176.0)
                            .opacity(0.82)
                    }
                    HStack(spacing: 24.0) {
                        Color.orange
                            .frame(width: 360.0, height: 176.0)
                        Color.green
                            .frame(width: 240.0, height: 176.0)
                            .opacity(0.72)
                    }
                }
                .padding(32.0)
            }
        }
    }
}

private enum CanvasRenderer {
    static func render(_ frame: _WebRenderFrame) {
        let document = JSObject.global.document
        let canvas: JSObject
        if let existingCanvas = document.getElementById("canvas").object {
            canvas = existingCanvas
        } else {
            canvas = document.createElement("canvas").object!
            canvas.id = .string("canvas")
            _ = document.body.appendChild(canvas)
        }

        let width = Double(frame.surface.width)
        let height = Double(frame.surface.height)
        let devicePixelRatio = JSObject.global.devicePixelRatio.number ?? 1.0
        canvas.width = .number(width * devicePixelRatio)
        canvas.height = .number(height * devicePixelRatio)

        let style = canvas.style.object!
        style.width = .string("\(width)px")
        style.height = .string("\(height)px")
        style.display = .string("block")

        guard let context = canvas.getContext!("2d").object else {
            fatalError("CanvasRenderingContext2D is unavailable")
        }
        _ = context.setTransform!(
            devicePixelRatio,
            0.0,
            0.0,
            devicePixelRatio,
            0.0,
            0.0
        )
        _ = context.clearRect!(0.0, 0.0, width, height)

        for command in frame.commands {
            switch command {
            case let .fill(rect, transform, cssColor):
                _ = context.save!()
                _ = context.transform!(
                    Double(transform.a),
                    Double(transform.b),
                    Double(transform.c),
                    Double(transform.d),
                    Double(transform.tx),
                    Double(transform.ty)
                )
                context.fillStyle = .string(cssColor)
                _ = context.fillRect!(
                    Double(rect.minX),
                    Double(rect.minY),
                    Double(rect.width),
                    Double(rect.height)
                )
                _ = context.restore!()
            }
        }

        canvas.setAttribute!("data-display-list-version", String(frame.version))
        canvas.setAttribute!("data-render-command-count", String(frame.commands.count))
    }
}
