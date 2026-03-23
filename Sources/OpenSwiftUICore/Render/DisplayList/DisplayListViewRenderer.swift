//
//  DisplayListViewRenderer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 21FFA3C7D88AC65BB559906758271BFC (SwiftUICore)

import OpenSwiftUI_SPI
package import Foundation

protocol ViewRendererBase: AnyObject {
    var platform: DisplayList.ViewUpdater.Platform { get }

    var exportedObject: AnyObject? { get }

    func render(
        rootView: AnyObject,
        from list: DisplayList,
        time: Time,
        version: DisplayList.Version,
        maxVersion: DisplayList.Version,
        environment: DisplayList.ViewRenderer.Environment
    ) -> Time

    func renderAsync(
        to list: DisplayList,
        time: Time,
        targetTimestamp: Time?,
        version: DisplayList.Version,
        maxVersion: DisplayList.Version
    ) -> Time?

    func destroy(rootView: AnyObject)

    var viewCacheIsEmpty: Bool { get }
}

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
extension DisplayList {
    final public class ViewRenderer {
        package struct Environment: Equatable {
            package var contentsScale: CGFloat
            #if os(macOS)
            package var opaqueBackground: Bool = false
            #endif

            package static let invalid = Environment(contentsScale: .zero)

            package init(contentsScale: CGFloat) {
                self.contentsScale = contentsScale
            }

            #if os(macOS)
            package init(contentsScale: CGFloat, opaqueBackground: Bool) {
                self.contentsScale = contentsScale
                self.opaqueBackground = opaqueBackground
            }
            #endif
        }

        let platform: DisplayList.ViewUpdater.Platform

        package var configuration: _RendererConfiguration = .init()

        package weak var host: (any ViewRendererHost)? = nil {
            didSet {
                configChanged = true
            }
        }

        private enum State {
            case none
            case updating
            case rasterizing
        }

        private var state: State = .none

        private var renderer: (any ViewRendererBase)?

        private var configChanged: Bool = true

        package init(platform: DisplayList.ViewUpdater.Platform) {
            self.platform = platform
        }

        private func updateRenderer(rootView: AnyObject) -> any ViewRendererBase {
            guard configChanged else {
                return renderer!
            }
            configChanged = false
            let isValid = switch configuration.renderer {
            case .default: state == .updating
            case .rasterized: state == .rasterizing
            }
            if !isValid {
                if let renderer {
                    renderer.destroy(rootView: rootView)
                }
                renderer = nil
                state = .none
            }
            if let renderer {
                switch configuration.renderer {
                case .default: break
                case let .rasterized(options):
                    let rasterizer = renderer as! ViewRasterizer
                    rasterizer.options = options
                    rasterizer.renderer.platformViewMode = options.drawsPlatformViews ? .rendered(update: true) : .unsupported
                    rasterizer.host = host
                }
            } else {
                switch configuration.renderer {
                case .default:
                    let updater = ViewUpdater(platform: platform, host: host)
                    renderer = updater
                    state = .updating
                case let .rasterized(options):
                    let rasterizer = ViewRasterizer(
                        platform: platform,
                        host: host,
                        rootView: rootView,
                        options: options
                    )
                    renderer = rasterizer
                    state = .rasterizing
                }
            }
            return renderer!
        }

        package func exportedObject(rootView: AnyObject) -> AnyObject? {
            let renderer = updateRenderer(rootView: rootView)
            return renderer.exportedObject
        }

        #if canImport(SwiftUI, _underlyingVersion: 6.5.4) && _OPENSWIFTUI_SWIFTUI_RENDER
        @_silgen_name("OpenSwiftUITestStub_DisplayListViewRendererRenderRootView")
        private func swiftUI_render(
            rootView: AnyObject,
            from list: DisplayList,
            time: Time,
            nextTime: Time,
            version: DisplayList.Version,
            maxVersion: DisplayList.Version,
            environment: DisplayList.ViewRenderer.Environment
        ) -> Time
        #endif

        package func render(
            rootView: AnyObject,
            from list: DisplayList,
            time: Time,
            nextTime: Time,
            version: DisplayList.Version,
            maxVersion: DisplayList.Version,
            environment: DisplayList.ViewRenderer.Environment
        ) -> Time {
            #if canImport(SwiftUI, _underlyingVersion: 6.5.4) && _OPENSWIFTUI_SWIFTUI_RENDER
            swiftUI_render(
                rootView: rootView,
                from: list,
                time: time,
                nextTime: nextTime,
                version: version,
                maxVersion: maxVersion,
                environment: environment
            )
            #else
            let renderer = updateRenderer(rootView: rootView)
            let nextUpdate = renderer.render(
                rootView: rootView,
                from: list,
                time: time,
                version: version,
                maxVersion: maxVersion,
                environment: environment
            )
            let interval = max(min(nextTime, nextUpdate) - time, configuration.minFrameInterval)
            return time + interval
            #endif
        }

        #if canImport(SwiftUI, _underlyingVersion: 6.5.4) && _OPENSWIFTUI_SWIFTUI_RENDER
        @_silgen_name("OpenSwiftUITestStub_DisplayListViewRendererRenderAsync")
        private func swiftUI_renderAsync(
            to list: DisplayList,
            time: Time,
            nextTime: Time,
            targetTimestamp: Time?,
            version: DisplayList.Version,
            maxVersion: DisplayList.Version
        ) -> Time?
        #endif

        package func renderAsync(
            to list: DisplayList,
            time: Time,
            nextTime: Time,
            targetTimestamp: Time?,
            version: DisplayList.Version,
            maxVersion: DisplayList.Version
        ) -> Time? {
            #if canImport(SwiftUI, _underlyingVersion: 6.5.4) && _OPENSWIFTUI_SWIFTUI_RENDER
            swiftUI_renderAsync(
                to: list,
                time: time,
                nextTime: nextTime,
                targetTimestamp: targetTimestamp,
                version: version,
                maxVersion: maxVersion
            )
            #else
            guard !configChanged, let renderer else {
                return nil
            }
            let nextUpdate = renderer.renderAsync(to: list, time: time, targetTimestamp: targetTimestamp, version: version, maxVersion: maxVersion)
            guard let nextUpdate else {
                return nextUpdate
            }
            let interval = max(min(nextTime, result) - time, configuration.minFrameInterval)
            return time + interval
            #endif
        }

        package var viewCacheIsEmpty: Bool {
            renderer?.viewCacheIsEmpty ?? true
        }
    }
}

// MARK: - DisplayList.ViewRasterizer

private var printTree: Bool?

extension DisplayList {
    private final class ViewRasterizer: ViewRendererBase {
        let platform: DisplayList.ViewUpdater.Platform
        weak var host: (any ViewRendererHost)? = nil
        var drawingView: AnyObject? = nil
        var options: _RendererConfiguration.RasterizationOptions
        let renderer: DisplayList.GraphicsRenderer
        var seed: DisplayList.Seed = .init()
        var lastContentsScale: CGFloat = .zero

        init(
            platform: DisplayList.ViewUpdater.Platform,
            host: (any ViewRendererHost)?,
            rootView: AnyObject,
            options: _RendererConfiguration.RasterizationOptions
        ) {
            self.platform = platform
            self.host = host
            self.options = options
            self.renderer = DisplayList.GraphicsRenderer(platformViewMode: options.drawsPlatformViews ? .rendered(update: true) : .unsupported)
            self.drawingView = platform.definition.makeDrawingView(options: .init(base: .init(options)))
            #if canImport(Darwin)
            CoreViewAddSubview(
                system: platform.viewSystem,
                parent: rootView,
                child: drawingView!,
                index: 0
            )
            #else
            _openSwiftUIPlatformUnimplementedWarning()
            #endif
        }

        var exportedObject: AnyObject? {
            let drawingView = drawingView!
            let rbLayer = platform.definition
                .getRBLayer(drawingView: drawingView)
            return rbLayer
        }

        func render(
            rootView: AnyObject,
            from list: DisplayList,
            time: Time,
            version: DisplayList.Version,
            maxVersion: DisplayList.Version,
            environment: DisplayList.ViewRenderer.Environment
        ) -> Time {
            let contentsScale = environment.contentsScale
            if contentsScale != lastContentsScale {
                lastContentsScale = contentsScale
                seed = .init()
            }
            #if canImport(Darwin)
            let drawingViewFrame = drawingView!.frame
            if let rootViewBounds = rootView.bounds, drawingViewFrame != rootViewBounds {
                CoreViewSetFrame(
                    system: platform.viewSystem,
                    view: drawingView!,
                    frame: rootView.bounds!
                )
                seed = .init()
            }
            #endif
            let newSeed = DisplayList.Seed(version)
            if newSeed == seed, renderer.nextTime >= time {
                return renderer.nextTime
            }
            let drawable = platform.updateDrawingView(
                &drawingView!,
                options: .init(options),
                contentsScale: lastContentsScale
            )
            let content = drawingContent(list: list, time: time)
            var result = time
            let updated = drawable.update(content: content, required: false)
            if updated {
                result = .infinity
            }
            if let host, let observer = host.as(ViewGraphRenderObserver.self) {
                observer.didRender()
            }
            return result
        }

        private func drawingContent(list: DisplayList, time: Time) -> PlatformDrawableContent {
            var content = PlatformDrawableContent()
            content.storage = .graphicsCallback { [weak host, renderer] ctx, size in
                if printTree == nil {
                    printTree = ProcessEnvironment.bool(forKey: "OPENSWIFTUI_PRINT_TREE")
                }
                if let printTree, printTree {
                    print("View \(Unmanaged.passUnretained(self).toOpaque()) at \(time):\n\(list.description)")
                }
                renderer.renderDisplayList(list, at: time, in: &ctx)
                let duration = renderer.nextTime - time
                let delay = max(duration, 1e-6)
                if delay != .infinity {
                    DispatchQueue.main.async { [weak host] in
                        host?.requestUpdate(after: delay)
                    }
                }
            }
            return content
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

        func destroy(rootView: AnyObject) {
            #if canImport(Darwin)
            CoreViewRemoveFromSuperview(
                system: platform.viewSystem,
                view: drawingView!
            )
            #else
            _openSwiftUIPlatformUnimplementedWarning()
            #endif
        }

        var viewCacheIsEmpty: Bool {
            true
        }
    }
}
