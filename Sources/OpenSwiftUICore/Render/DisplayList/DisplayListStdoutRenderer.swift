//
//  DisplayListStdoutRenderer.swift
//  OpenSwiftUICore
//
//  Status: WIP

package import Foundation
package import OpenCoreGraphicsShims
import OpenSwiftUI_SPI

// MARK: - DisplayList + stdout rendering

extension DisplayList {
    package func stdoutDescription(
        surface: CGSize,
        version: DisplayList.Version
    ) -> String {
        var lines = [
            "OpenSwiftUI backend: stdout",
            "surface: \(stdoutFormat(surface.width))x\(stdoutFormat(surface.height))",
            "display-list-version: \(version.value)",
            "rendered:",
        ]
        for command in staticRenderCommands() {
            lines.append("  - \(command.stdoutDescription)")
        }
        return lines.joined(separator: "\n")
    }
}

private extension DisplayList.StaticRenderCommand {
    var stdoutDescription: String {
        switch self {
        case let .fill(frame, transform, color):
            let renderedFrame = frame.applying(transform)
            return "fill x:\(stdoutFormat(renderedFrame.minX)) y:\(stdoutFormat(renderedFrame.minY)) w:\(stdoutFormat(renderedFrame.width)) h:\(stdoutFormat(renderedFrame.height)) \(color.description)"
        }
    }
}

private func stdoutFormat(_ value: CGFloat) -> String {
    let number = Double(value)
    return String(format: "%.1f", number == -0.0 ? 0.0 : number)
}

// MARK: - StdoutDisplayListRenderer

final class StdoutDisplayListRenderer: ViewRendererBase {
    let platform: DisplayList.ViewUpdater.Platform
    weak var host: (any ViewRendererHost)?
    var options: _RendererConfiguration.StdoutOptions
    private var seed: DisplayList.Seed = .init()
    private var hasRendered = false

    init(
        platform: DisplayList.ViewUpdater.Platform,
        host: (any ViewRendererHost)?,
        options: _RendererConfiguration.StdoutOptions
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
        print(list.stdoutDescription(surface: options.surface, version: version))
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
