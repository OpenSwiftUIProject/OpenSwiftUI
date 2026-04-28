//
//  DisplayListViewUpdater.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: B86250B2E056EB47628ECF46032DFA4C (SwiftUICore)

private var printTree: Bool?

import Foundation
import OpenQuartzCoreShims

extension DisplayList {
    // FIXME
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
        
        func render(
            rootView: AnyObject,
            from list: DisplayList,
            time: Time,
            version: DisplayList.Version,
            maxVersion: DisplayList.Version,
            environment: DisplayList.ViewRenderer.Environment
        ) -> Time {
            viewCache.clearAsyncValues()
            if printTree == nil {
                printTree = ProcessEnvironment.bool(forKey: "OPENSWIFTUI_PRINT_TREE")
            }
            if let printTree, printTree {
                print("View \(Unmanaged.passUnretained(rootView).toOpaque()) at \(time):\n\(list.description)")
            }

            let newSeed = DisplayList.Seed(version)
            let seedChanged = newSeed != seed
            let envChanged = environment != lastEnv

            wasValid = isValid

            if seedChanged || envChanged || !isValid {
                // TODO: Walk display list items and create/update platform views
                viewCache.currentList = list
                seed = newSeed
                lastEnv = environment
                isValid = true
            }

            lastList = list
            lastTime = time
            nextUpdate = .infinity

            return nextUpdate
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
        
        private func updateAsync(
            oldList: DisplayList,
            oldParentState: UnsafePointer<Model.State>,
            newList: DisplayList,
            newParentState: UnsafePointer<Model.State>
        ) -> Time? {
            // FIXME
            return nil
        }
        
        func destroy(rootView: AnyObject) {
            isValid = false
            wasValid = false
            lastList = DisplayList()
            lastEnv = .invalid
            seed = DisplayList.Seed()
            asyncSeed = DisplayList.Seed()
            nextUpdate = .infinity
            viewCache.currentList = DisplayList()
            viewCache.pendingAsyncUpdates.removeAll()
        }
        
        var viewCacheIsEmpty: Bool {
            viewCache.map.isEmpty
        }

        var platform: Platform {
            viewCache.platform
        }

        var exportedObject: AnyObject? {
            // TODO
            nil
        }
    }
}

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
            self.id = ID(value: 0)
            self.parentID = ID(value: 0)
            self.seeds = Seeds(
                item: .init(), content: .init(), opacity: .init(),
                blend: .init(), transform: .init(), clips: .init(),
                filters: .init(), shadow: .init(), properties: .init(),
                platformSeeds: .init()
            )
            self.cacheSeed = 0
            self.isRemoved = false
            self.isInvalid = false
            self.nextUpdate = .infinity
        }

        init(
            platform: Platform,
            kind: PlatformViewDefinition.ViewKind
        ) {
            _openSwiftUIUnimplementedFailure()
        }

        func reset() {
            _openSwiftUIUnimplementedFailure()
        }
    }
}
