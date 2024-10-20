//
//  DisplayList.ViewRenderer.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Blocked by ViewUpdater and ViewRasterizer
//  ID: 21FFA3C7D88AC65BB559906758271BFC

import Foundation

protocol ViewRendererBase {
    var platform: DisplayList.ViewUpdater.Platform { get }
    var exportedObject: AnyObject? { get }
    func render(rootView: AnyObject, from list: DisplayList, time: Time, version: DisplayList.Version, maxVersion: DisplayList.Version, environment: DisplayList.ViewRenderer.Environment) -> Time
    func renderAsync(to list: DisplayList, time: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time?
    func destroy(rootView: AnyObject)
    var viewCacheIsEmpty: Bool { get }
}

@_spi(ForOpenSwiftUIOnly)
extension DisplayList {
    final public class ViewRenderer {
        package struct Environment: Equatable {
            package var contentScale: CGFloat
            package static let invalid = Environment(contentScale: .zero)
            
            package init(contentScale: CGFloat) {
                self.contentScale = contentScale
            }
        }

        private enum State {
            case none
            case updating
            case rasterizing
        }
        
        let platform: DisplayList.ViewUpdater.Platform
        package var configuration: _RendererConfiguration = .init()
        package weak var host: ViewRendererHost? = nil
        private var state: State = .none
        var renderer: (any ViewRendererBase)? = nil
        var configChanged: Bool = true
        
        package init(platform: DisplayList.ViewUpdater.Platform) {
            self.platform = platform
        }
        
        private func updateRenderer(rootView: AnyObject) -> any ViewRendererBase {
            guard configChanged else {
                return renderer!
            }
            configChanged = false
            let renderStateMatchCheck = switch configuration.renderer {
            case .default: state == .updating
            case .rasterized: state == .rasterizing
            }
            if !renderStateMatchCheck {
                if let renderer {
                    renderer.destroy(rootView: rootView)
                }
                renderer = nil
                state = .none
            }
            if let renderer {
                switch configuration.renderer {
                case .default:
                    return renderer
                case .rasterized(let options):
                    fatalError("Blocked by ViewRasterizer")
                    return renderer
                }
            } else {
                switch configuration.renderer {
                case .default:
                    let updater = ViewUpdater()
                    // TODO: ViewUpdater
                    renderer = updater
                    state = .updating
                    return renderer!
                case .rasterized(let options):
                    fatalError("Blocked by ViewRasterizer")
                }
            }
        }
        
        package func exportedObject(rootView: AnyObject) -> AnyObject? {
            let renderer = updateRenderer(rootView: rootView)
            return renderer.exportedObject
        }
        
        package func render(rootView: AnyObject, from list: DisplayList, time: Time, nextTime: Time, version: DisplayList.Version, maxVersion: DisplayList.Version, environment: DisplayList.ViewRenderer.Environment) -> Time {
            let renderer = updateRenderer(rootView: rootView)
            let result = renderer.render(rootView: rootView, from: list, time: time, version: version, maxVersion: maxVersion, environment: environment)
            let interval = min(nextTime, result) - time
            let maxInterval = max(interval, configuration.minFrameInterval)
            return time + maxInterval
        }
        
        package func renderAsync(to list: DisplayList, time: Time, nextTime: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time? {
            guard !configChanged, let renderer else {
                return nil
            }
            let result = renderer.renderAsync(to: list, time: time, targetTimestamp: targetTimestamp, version: version, maxVersion: maxVersion)
            if let result {
                let interval = min(nextTime, result) - time
                let maxInterval = max(interval, configuration.minFrameInterval)
                return time + maxInterval
            } else {
                return nil
            }
        }
        
        package var viewCacheIsEmpty: Bool {
            renderer?.viewCacheIsEmpty ?? true
        }
    }
}
