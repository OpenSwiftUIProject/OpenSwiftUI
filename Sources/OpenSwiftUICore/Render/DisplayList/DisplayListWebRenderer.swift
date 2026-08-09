//
//  DisplayListWebRenderer.swift
//  OpenSwiftUICore
//
//  Status: WIP

#if !OPENSWIFTUI_SWIFTUI_RENDERER
public import Foundation
public import OpenCoreGraphicsShims
import OpenSwiftUI_SPI

// MARK: - Web render frame

/// A platform-neutral command emitted by the OpenSwiftUI web renderer.
@_spi(WebRenderer)
public enum _WebRenderCommand {
    /// Fill a rectangle using a CSS color value.
    case fill(frame: CGRect, transform: CGAffineTransform, cssColor: String)
}

/// A complete static frame emitted by the OpenSwiftUI web renderer.
@_spi(WebRenderer)
public struct _WebRenderFrame {
    public let surface: CGSize
    public let version: Int
    public let commands: [_WebRenderCommand]

    package init(
        surface: CGSize,
        version: Int,
        commands: [_WebRenderCommand]
    ) {
        self.surface = surface
        self.version = version
        self.commands = commands
    }
}

extension DisplayList {
    package func webRenderFrame(
        surface: CGSize,
        version: DisplayList.Version
    ) -> _WebRenderFrame {
        let commands = staticRenderCommands().map { command in
            switch command {
            case let .fill(frame, transform, color):
                _WebRenderCommand.fill(
                    frame: frame,
                    transform: transform,
                    cssColor: color.webCSSColor
                )
            }
        }
        return _WebRenderFrame(
            surface: surface,
            version: version.value,
            commands: commands
        )
    }
}

private extension Color.Resolved {
    var webCSSColor: String {
        func byte(_ component: Float) -> Int {
            guard component.isFinite else { return 0 }
            return Int(min(max(component, 0.0), 1.0) * 255.0 + 0.5)
        }
        return String(
            format: "#%02X%02X%02X%02X",
            byte(red),
            byte(green),
            byte(blue),
            byte(opacity)
        )
    }
}

// MARK: - WebDisplayListRenderer

final class WebDisplayListRenderer: ViewRendererBase {
    let platform: DisplayList.ViewUpdater.Platform
    weak var host: (any ViewRendererHost)?
    var options: _RendererConfiguration.WebOptions
    private var seed: DisplayList.Seed = .init()
    private var hasRendered = false

    init(
        platform: DisplayList.ViewUpdater.Platform,
        host: (any ViewRendererHost)?,
        options: _RendererConfiguration.WebOptions
    ) {
        self.platform = platform
        self.host = host
        self.options = options
    }

    var exportedObject: AnyObject? {
        nil
    }

    func render(
        rootView: AnyObject,
        from list: DisplayList,
        time: Time,
        version: DisplayList.Version,
        maxVersion: DisplayList.Version,
        environment: DisplayList.ViewRenderer.Environment
    ) -> Time {
        let nextSeed = DisplayList.Seed(version)
        guard !hasRendered || nextSeed != seed else {
            return .infinity
        }
        hasRendered = true
        seed = nextSeed
        options.onRender(list.webRenderFrame(surface: options.surface, version: version))
        if let host, let observer = host.as(ViewGraphRenderObserver.self) {
            observer.didRender()
        }
        return .infinity
    }

    func renderAsync(
        to list: DisplayList,
        time: Time,
        targetTimestamp: Time?,
        version: DisplayList.Version,
        maxVersion: DisplayList.Version
    ) -> Time? {
        nil
    }

    func destroy(rootView: AnyObject) {}

    var viewCacheIsEmpty: Bool {
        true
    }
}
#endif
