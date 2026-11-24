//
//  DisplayListWebRenderer.swift
//  OpenSwiftUICore
//
//  Status: WIP

#if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
public import Foundation
public import OpenCoreGraphicsShims
import OpenSwiftUI_SPI

// MARK: - Web render frame

/// A platform-neutral command emitted by the OpenSwiftUI web renderer.
@_spi(WebRenderer)
public enum _WebRenderCommand {
    public enum FillShape {
        case rectangle
        case ellipse
        case roundedRectangle(radius: CGFloat)
    }

    public enum GradientGeometry {
        case linear(start: CGPoint, end: CGPoint)
        case radial(center: CGPoint, startRadius: CGFloat, endRadius: CGFloat)
        case elliptical(center: CGPoint, size: CGSize, startRadiusFraction: CGFloat, endRadiusFraction: CGFloat)
        case angular(center: CGPoint, angle: Double)
    }

    public struct GradientStop {
        public let location: Double
        public let cssColor: String
    }

    /// Fill a primitive shape using a CSS color value.
    case fill(frame: CGRect, transform: CGAffineTransform, cssColor: String, shape: FillShape = .rectangle)

    /// Fill a primitive with sampled stops in the shape's local coordinate space.
    case gradient(frame: CGRect, transform: CGAffineTransform, stops: [GradientStop], geometry: GradientGeometry, shape: FillShape)

    /// Draw a single-line text run using an alphabetic baseline.
    case text(
        frame: CGRect,
        transform: CGAffineTransform,
        text: String,
        style: _WebTextStyle,
        cssColor: String,
        firstBaseline: CGFloat
    )

    /// Push a Canvas clip region for subsequent commands.
    case pushClip(frame: CGRect, transform: CGAffineTransform, shape: FillShape = .rectangle)

    /// Restore the Canvas state pushed by `pushClip`.
    case popClip

    /// Draw a system symbol icon inside `frame`.
    case symbol(
        frame: CGRect,
        transform: CGAffineTransform,
        name: String,
        style: _WebTextStyle,
        cssColor: String
    )
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
        let commands = staticRenderCommands().map { command -> _WebRenderCommand in
            switch command {
            case let .fill(frame, transform, color, shape):
                let cssColor = color.webCSSColor
                switch shape {
                case .rectangle:
                    return .fill(frame: frame, transform: transform, cssColor: cssColor)
                case let .ellipse(bounds):
                    return .fill(frame: bounds, transform: transform, cssColor: cssColor, shape: .ellipse)
                case let .roundedRectangle(bounds, radius):
                    return .fill(frame: bounds, transform: transform, cssColor: cssColor, shape: .roundedRectangle(radius: radius))
                }
            case let .gradient(frame, transform, gradient, shape):
                let geometry: _WebRenderCommand.GradientGeometry
                switch gradient.geometry {
                case let .linear(start, end):
                    geometry = .linear(start: start, end: end)
                case let .radial(center, startRadius, endRadius):
                    geometry = .radial(center: center, startRadius: startRadius, endRadius: endRadius)
                case let .elliptical(center, size, startRadiusFraction, endRadiusFraction):
                    geometry = .elliptical(
                        center: center,
                        size: size,
                        startRadiusFraction: startRadiusFraction,
                        endRadiusFraction: endRadiusFraction
                    )
                case let .angular(center, angle):
                    geometry = .angular(center: center, angle: angle)
                }
                let fillShape: _WebRenderCommand.FillShape
                switch shape {
                case .rectangle: fillShape = .rectangle
                case .ellipse: fillShape = .ellipse
                case let .roundedRectangle(_, radius): fillShape = .roundedRectangle(radius: radius)
                }
                return .gradient(
                    frame: frame,
                    transform: transform,
                    stops: gradient.stops.map {
                        .init(location: Double($0.location), cssColor: $0.color.webCSSColor)
                    },
                    geometry: geometry,
                    shape: fillShape
                )
            case let .text(frame, transform, text, style, color, firstBaseline):
                return .text(
                    frame: frame,
                    transform: transform,
                    text: text,
                    style: _WebTextStyle(style),
                    cssColor: color.webCSSColor,
                    firstBaseline: firstBaseline
                )
            case let .pushClip(frame, transform, shape):
                let fillShape: _WebRenderCommand.FillShape = switch shape {
                case .rectangle: .rectangle
                case .ellipse: .ellipse
                case let .roundedRectangle(_, radius): .roundedRectangle(radius: radius)
                }
                return .pushClip(frame: frame, transform: transform, shape: fillShape)
            case .popClip:
                return .popClip
            case let .symbol(frame, transform, name, style, color):
                return .symbol(
                    frame: frame,
                    transform: transform,
                    name: name,
                    style: _WebTextStyle(style),
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
    private var lastSurface: CGSize = .zero
    private var hasRendered = false
    private let printTree = ProcessEnvironment.bool(forKey: "OPENSWIFTUI_PRINT_TREE") ?? false

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
        guard !hasRendered || nextSeed != seed || lastSurface != options.surface else {
            return .infinity
        }
        hasRendered = true
        seed = nextSeed
        lastSurface = options.surface
        if printTree {
            print("Web view at \(time):\n\(list.description)")
        }
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
