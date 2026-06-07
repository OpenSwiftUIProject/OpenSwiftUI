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
        for command in stdoutRenderCommands() {
            lines.append("  - \(command.description)")
        }
        return lines.joined(separator: "\n")
    }

    private func stdoutRenderCommands() -> [StdoutRenderCommand] {
        var visitor = StdoutRenderCommandVisitor()
        visitor.append(list: self)
        return visitor.commands
    }
}

private enum StdoutRenderCommand {
    case fill(frame: CGRect, color: Color.Resolved)

    var description: String {
        switch self {
        case let .fill(frame, color):
            "fill x:\(stdoutFormat(frame.minX)) y:\(stdoutFormat(frame.minY)) w:\(stdoutFormat(frame.width)) h:\(stdoutFormat(frame.height)) \(color.description)"
        }
    }
}

private struct StdoutRenderCommandVisitor {
    var commands: [StdoutRenderCommand] = []

    mutating func append(
        list: DisplayList,
        transform: CGAffineTransform = .identity,
        opacity: Float = 1.0
    ) {
        for item in list.items {
            append(item: item, transform: transform, opacity: opacity)
        }
    }

    private mutating func append(
        item: DisplayList.Item,
        transform: CGAffineTransform,
        opacity: Float
    ) {
        switch item.value {
        case let .content(content):
            append(
                content: content,
                frame: item.frame.applying(transform),
                transform: transform,
                opacity: opacity
            )
        case let .effect(effect, list):
            append(effect: effect, list: list, transform: transform, opacity: opacity)
        case let .states(states):
            for (_, list) in states {
                append(list: list, transform: transform, opacity: opacity)
            }
        case .empty:
            break
        }
    }

    private mutating func append(
        content: DisplayList.Content,
        frame: CGRect,
        transform: CGAffineTransform,
        opacity: Float
    ) {
        switch content.value {
        case let .color(color):
            commands.append(.fill(frame: frame, color: color.multiplyingOpacity(by: opacity)))
        case let .shape(_, paint, _):
            if let color = paint.stdoutResolvedColor {
                commands.append(.fill(frame: frame, color: color.multiplyingOpacity(by: opacity)))
            }
        case let .flattened(list, offset, _):
            append(
                list: list,
                transform: transform.concatenating(
                    CGAffineTransform(translationX: frame.minX + offset.x, y: frame.minY + offset.y)
                ),
                opacity: opacity
            )
        default:
            break
        }
    }

    private mutating func append(
        effect: DisplayList.Effect,
        list: DisplayList,
        transform: CGAffineTransform,
        opacity: Float
    ) {
        switch effect {
        case let .opacity(alpha):
            append(list: list, transform: transform, opacity: opacity * alpha)
        case let .transform(.affine(affine)):
            append(list: list, transform: transform.concatenating(affine), opacity: opacity)
        default:
            append(list: list, transform: transform, opacity: opacity)
        }
    }
}

private struct StdoutColorPaintVisitor: ResolvedPaintVisitor {
    var color: Color.Resolved?

    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
        color = paint as? Color.Resolved
    }
}

private extension AnyResolvedPaint {
    var stdoutResolvedColor: Color.Resolved? {
        var visitor = StdoutColorPaintVisitor()
        visit(&visitor)
        return visitor.color
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
