//
//  DisplayList.ViewUpdater.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: A9949015C771FF99F7528BB7239FD006

import Foundation
import QuartzCore

extension DisplayList {
    // FIXME
    final package class ViewUpdater: ViewRendererBase {
        weak var host: ViewRendererHost?
        var viewCache: DisplayList.ViewUpdater.ViewCache
        var seed: DisplayList.Seed
        var asyncSeed: DisplayList.Seed
        var nextUpdate: Time
        var lastEnv: DisplayList.ViewRenderer.Environment
        var lastList: DisplayList
        var lastTime: Time
        var isValid: Bool
        var wasValid: Bool
        
        init() {
            preconditionFailure("")
        }
        
        init(platform: Platform, exportedObject: AnyObject? = nil, viewCacheIsEmpty: Bool) {
//            self.platform = platform
//            self.exportedObject = exportedObject
//            self.viewCacheIsEmpty = viewCacheIsEmpty
            fatalError()
        }
        
        var platform: Platform
        
        var exportedObject: AnyObject?
        
        func render(rootView: AnyObject, from list: DisplayList, time: Time, version: DisplayList.Version, maxVersion: DisplayList.Version, environment: DisplayList.ViewRenderer.Environment) -> Time {
            .zero
        }
        
        func renderAsync(to list: DisplayList, time: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time? {
            nil
        }
        
        func destroy(rootView: AnyObject) {
        }
        
        var viewCacheIsEmpty: Bool {
            fatalError("TODO")
        }
    }
}


extension DisplayList.ViewUpdater {
    struct ViewCache {
        enum Tag {
            case item
            case inherited
        }
        
        struct Key {
            var id: DisplayList.Index.ID
            var tag: Tag
        }
        
        private struct AsyncValues {
            var animations: Set<String>
            var modifiers: [String: Void /*CAPresentationModifier*/]
        }
        
        private struct PendingAsyncValue {
            var keyPath: String
            var value: NSObject
            var usesPresentationModifier: Bool
        }
        
        private struct AnimatorInfo {
            enum State {
                // case active(_DisplayList_AnyEffectAnimator)
                case finished(DisplayList.Effect, DisplayList.Version)
                case idle
            }
            
            var state: State
            var deadline: Time
        }
        
        
        let platform: Platform
//        var map: [DisplayList.ViewUpdater.ViewCache.Key : DisplayList.ViewUpdater.ViewInfo]
//            var reverseMap: [Swift.OpaquePointer : DisplayList.ViewUpdater.DisplayCache.Key]
//            var removed: Swift.Set<DisplayList.ViewUpdater.ViewCache.Key>
//        var animators: [DisplayList.ViewUpdater.ViewCache.Key : DisplayList.ViewUpdater.ViewCache.(AnimatorInfo in _A9949015C771FF99F7528BB7239FD006)]
//        var asyncValues: [Swift.ObjectIdentifier : DisplayList.ViewUpdater.ViewCache.(AsyncValues in _A9949015C771FF99F7528BB7239FD006)]
//        var pendingAsyncValues: [Swift.ObjectIdentifier : [DisplayList.ViewUpdater.ViewCache.(PendingAsyncValue in _A9949015C771FF99F7528BB7239FD006)]]
//        var asyncModifierGroup: __C.CAPresentationModifierGroup?
        var pendingAsyncUpdates: [() -> ()]
        var index: DisplayList.Index
        var cacheSeed: Swift.UInt32
        var currentList: DisplayList
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
        }
        
        struct ID {
            var value: Int
        }
        
        var view: AnyObject
        var layer: CALayer
        var container: AnyObject
        var state: Platform.State
        var id: ID
        var parentID: ID
        var seeds: Seeds
        var cacheSeed: UInt32
        var isRemoved: Bool
        var isInvalid: Bool
    }
}

// ViewUpdater.ViewInfo

