//
//  DisplayListViewUpdater.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: B86250B2E056EB47628ECF46032DFA4C (SwiftUICore)

import Foundation
import OpenSwiftUI_SPI
import OpenQuartzCoreShims
import QuartzCore_Private

// MARK: - DisplayList.ViewUpdater [WIP]

private var printTree: Bool?

extension DisplayList {
    final package class ViewUpdater: ViewRendererBase {
        weak var host: (any ViewRendererHost)?
        var viewCache: DisplayList.ViewUpdater.ViewCache
        var seed: DisplayList.Seed
        var asyncSeed: DisplayList.Seed
        var nextUpdate: Time
        var lastEnv: DisplayList.ViewRenderer.Environment
        var lastList: DisplayList
        var lastTime: Time
        var isValid: Bool
        var wasValid: Bool

        init(platform: Platform, host: (any ViewRendererHost)?){
            self.host = host
            self.viewCache = ViewCache(platform: platform)
            self.seed = DisplayList.Seed()
            self.asyncSeed = DisplayList.Seed()
            self.nextUpdate = .infinity
            self.lastEnv = .invalid
            self.lastList = DisplayList()
            self.lastTime = .zero
            self.isValid = false
            self.wasValid = false
        }
        
        var platform: Platform {
            viewCache.platform
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
            if environment != lastEnv {
                lastEnv = environment
                isValid = false
                viewCache.invalidateAll()
                seed = .init()
            }
            if isValid, DisplayList.Seed(version) == seed, nextUpdate >= time {
                return nextUpdate
            }
            #if canImport(QuartzCore)
            if lastTime == .zero {
                let layer = platform.viewLayer(rootView)
                layer.allowsGroupOpacity = false
                layer.allowsGroupBlending = false
            }
            #endif
            let newSeed = DisplayList.Seed(version)
            seed = newSeed
            asyncSeed = newSeed
            wasValid = isValid
            isValid = true
            lastList = list
            lastTime = time
            if printTree == nil {
                printTree = ProcessEnvironment.bool(forKey: "OPENSWIFTUI_PRINT_TREE")
            }
            if let printTree, printTree {
                print("View \(Unmanaged.passUnretained(rootView).toOpaque()) at \(time):\n\(list.description)")
            }
            let globals = Model.State.Globals(
                updater: self,
                time: time,
                maxVersion: maxVersion,
                environment: lastEnv
            )
            return withUnsafePointer(to: globals) { globalsPtr in
                let parentState = Model.State(globals: globalsPtr)
                viewCache.index = .init()
                viewCache.currentList = list
                viewCache.clearAsyncValues()
                #if canImport(QuartzCore)
                let layer = platform.viewLayer(rootView)
                let needsLayoutOnGeometryChange = layer.needsLayoutOnGeometryChange
                layer.needsLayoutOnGeometryChange = false
                #endif
                var container = Container(rootView: rootView, platform: viewCache.platform)
                withUnsafePointer(to: parentState) { parentStatePtr in
                    update(
                        container: &container,
                        from: list,
                        parentState: parentStatePtr
                    )
                }
                container.removeRemaining(viewCache: &viewCache)
                viewCache.reclaim(time: time)
                viewCache.currentList = DisplayList()
                if !isValid {
                    container.nextTime = time
                }
                if let host, let observer = host.as(ViewGraphRenderObserver.self) {
                    observer.didRender()
                }
                let nextTime = container.nextTime
                nextUpdate = nextTime
                #if canImport(QuartzCore)
                layer.needsLayoutOnGeometryChange = needsLayoutOnGeometryChange
                #endif
                return nextTime
            }
        }
        
        func renderAsync(
            to list: DisplayList,
            time: Time,
            targetTimestamp: Time?,
            version: DisplayList.Version,
            maxVersion: DisplayList.Version
        ) -> Time? {
            if isValid, DisplayList.Seed(version) == asyncSeed, nextUpdate >= time {
                return nextUpdate
            }
            if printTree == nil {
                printTree = ProcessEnvironment.bool(forKey: "OPENSWIFTUI_PRINT_TREE")
            }
            if let printTree, printTree {
                print("Async view at \(time):\n\(list.description)")
            }
            let newGlobals = Model.State.Globals(
                updater: self,
                time: time,
                maxVersion: maxVersion,
                environment: lastEnv
            )
            let oldGlobals = Model.State.Globals(
                updater: self,
                time: lastTime,
                maxVersion: maxVersion,
                environment: lastEnv
            )
            return withUnsafePointer(to: newGlobals) { newGlobalsPtr in
                withUnsafePointer(to: oldGlobals) { oldGlobalsPtr in
                    let oldParentState = Model.State(globals: oldGlobalsPtr)
                    let newParentState = Model.State(globals: newGlobalsPtr)
                    viewCache.index = .init()
                    wasValid = isValid
                    isValid = true
                    let oldList = lastList
                    let resultTime = withUnsafePointer(to: oldParentState) { oldParentStatePtr in
                        withUnsafePointer(to: newParentState) { newParentStatePtr in
                            updateAsync(
                                oldList: oldList,
                                oldParentState: oldParentStatePtr,
                                newList: list,
                                newParentState: newParentStatePtr
                            )
                        }
                    }
                    guard let resultTime else {
                        viewCache.clearPendingAsyncValues()
                        isValid = wasValid
                        return nil
                    }
                    viewCache.commitAsyncValues(targetTimestamp: targetTimestamp)
                    lastList = list
                    lastTime = time
                    asyncSeed = seed
                    nextUpdate = resultTime
                    return resultTime
                }
            }
        }
        
        func destroy(rootView: AnyObject) {
            var container = Container(rootView: rootView, platform: viewCache.platform)
            container.removeRemaining(viewCache: &viewCache)
            viewCache.reclaim(time: .infinity)
        }
        
        var viewCacheIsEmpty: Bool {
            viewCache.map.isEmpty
        }
        
        private func update(
            container: inout Container,
            from list: DisplayList,
            parentState: UnsafePointer<Model.State>
        ) {
            guard !list.items.isEmpty else {
                return
            }
            for var item in list.items {
                let savedIndex = viewCache.index.enter(identity: item.identity)
                defer { viewCache.index.leave(index: savedIndex) }
                let nextTime = viewCache.prepare(item: &item, parentState: parentState)
                container.nextTime = min(container.nextTime, nextTime)
                updateInheritedView(
                    container: &container,
                    from: item,
                    parentState: parentState
                )
            }
        }
        
        private func updateAsync(
            oldList: DisplayList,
            oldParentState: UnsafePointer<Model.State>,
            newList: DisplayList,
            newParentState: UnsafePointer<Model.State>
        ) -> Time? {
            _openSwiftUIUnimplementedWarning()
            return nil
        }
    }
}

// MARK: - DisplayList.ViewUpdater.Container

extension DisplayList.ViewUpdater {
    private struct Container {
        var rootView: AnyObject
        var platform: Platform
        var id: ViewInfo.ID // FIXME
        var nextTime: Time
        var count: Int

        init(rootView: AnyObject, platform: Platform) {
            self.rootView = rootView
            self.platform = platform
            self.id = .init(value: 0)
            self.nextTime = .infinity
            self.count = 0
        }

        mutating func removeRemaining(viewCache: inout ViewCache) {
            let subviews = platform.subviews(rootView)
            guard count < subviews.count else {
                return
            }
            for index in (count..<subviews.count).reversed() {
                let view = subviews[index]
                let pointer = unsafeBitCast(view, to: OpaquePointer.self)
                guard let key = viewCache.reverseMap[pointer] else {
                    continue
                }
                var info = viewCache.map[key]!
                if !info.isRemoved {
                    info.isRemoved = true
                    viewCache.map[key] = info
                    viewCache.removed.insert(key)
                }
                platform.removeFromSuperview(view)
            }
        }
    }
}

// MARK: - DisplayList.ViewUpdater.ViewInfo

extension DisplayList.ViewUpdater {
    struct ViewInfo {
        struct Seeds {
            var item: DisplayList.Seed
            var content: DisplayList.Seed
            var opacity: DisplayList.Seed
            var blend: DisplayList.Seed
            var transform: DisplayList.Seed
            var clips: DisplayList.Seed
            var filters: DisplayList.Seed
            var shadow: DisplayList.Seed
            var properties: DisplayList.Seed
            var platformSeeds: DisplayList.ViewUpdater.PlatformViewInfo.Seeds

            init(_ seed: DisplayList.Seed = .init()) {
                item = seed
                content = seed
                opacity = seed
                blend = seed
                transform = seed
                clips = seed
                filters = seed
                shadow = seed
                properties = .init()
                platformSeeds = .init()
            }

            @inline(__always)
            init(kind: PlatformViewDefinition.ViewKind) {
                let seed: DisplayList.Seed = switch kind {
                case .platformView, .platformGroup:
                    .undefined
                default:
                    .init()
                }
                self.init(seed)
            }

            mutating func invalidate() {
                item.invalidate()
                content.invalidate()
                opacity.invalidate()
                blend.invalidate()
                transform.invalidate()
                clips.invalidate()
                filters.invalidate()
                shadow.invalidate()
                properties.invalidate()
            }
            
            @inline(__always)
            mutating func reset() {
                self = .init()
            }
        }

        struct ID: Equatable {
            var value: Int
        }

        var view: AnyObject
        var layer: CALayer
        var container: AnyObject
        var state: DisplayList.ViewUpdater.Platform.State
        var id: ID
        var parentID: ID
        var seeds: Seeds
        var cacheSeed: UInt32
        var isRemoved: Bool
        var isInvalid: Bool
        var nextUpdate: Time

        init(
            view: AnyObject,
            layer: CALayer,
            container: AnyObject,
            state: Platform.State
        ) {
            self.view = view
            self.layer = layer
            self.container = container
            self.state = state
            self.id = ID(value: UniqueID().value)
            self.parentID = ID(value: -1)
            self.seeds = Seeds(kind: state.kind)
            self.cacheSeed = 0
            self.isRemoved = false
            self.isInvalid = false
            self.nextUpdate = .infinity
        }

        init(
            platform: Platform,
            kind: PlatformViewDefinition.ViewKind
        ) {
            let view = platform.definition.makeView(kind: kind)
            let layer = platform.viewLayer(view)
            let state = Platform.State(kind: kind)
            self.init(view: view, layer: layer, container: view, state: state)
        }

        mutating func reset(platform: Platform) {
            layer = platform.viewLayer(view)
            seeds.reset()
            state.reset()
            nextUpdate = .infinity
        }
    }
}
