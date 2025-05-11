//
//  DisplayList.ViewUpdater.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: B86250B2E056EB47628ECF46032DFA4C (SwiftUICore)

private var printTree: Bool?

import Foundation
#if canImport(Darwin)
import QuartzCore
#endif

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
            preconditionFailure("TODO")
        }
        
        func render(rootView: AnyObject, from list: DisplayList, time: Time, version: DisplayList.Version, maxVersion: DisplayList.Version, environment: DisplayList.ViewRenderer.Environment) -> Time {
            // TODO
            if printTree == nil {
                printTree = ProcessEnvironment.bool(forKey: "OPENSWIFTUI_PRINT_TREE")
            }
            if let printTree, printTree {
                print("View \(Unmanaged.passUnretained(rootView).toOpaque()) at \(time):\n\(list.description)")
            }
            return .zero
        }
        
        func renderAsync(to list: DisplayList, time: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time? {
            nil
        }
        
        func destroy(rootView: AnyObject) {
        }
        
        var viewCacheIsEmpty: Bool {
            // TODO
            false
        }

        var platform: Platform {
            // TODO
            preconditionFailure("TODO")
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
        }

        struct ID {
            var value: Int
        }

        var view: AnyObject
        #if canImport(Darwin)
        var layer: CALayer
        #endif
        var container: AnyObject
        var state: DisplayList.ViewUpdater.Platform.State
        var id: ID
        var parentID: ID
        var seeds: Seeds
        var cacheSeed: UInt32
        var isRemoved: Bool
        var isInvalid: Bool
    }
}
