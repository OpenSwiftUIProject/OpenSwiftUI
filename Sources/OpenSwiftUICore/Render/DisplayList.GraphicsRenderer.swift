//
//  DisplayList.GraphicsRenderer.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Blocked by RenderBox and GraphicsContext
//  ID: EFAEDE41CB8C85EF3A6A18DC05438A3C

import Foundation

extension DisplayList {
    final package class GraphicsRenderer {
        package enum PlatformViewMode {
            case ignored
            case unsupported
            case rendered(update: Bool)
        }
        
        private struct Cache {
            var callbacks: [CallbackKey: Void /* RBDisplayListContents */]
            var animators: [AnimatorKey: Void /* _DisplayList_AnyEffectAnimator */ ]
            
            struct CallbackKey: Hashable {
                var index: DisplayList.Index.ID
                var seed: DisplayList.Seed
                var scale: CGFloat
            }
            
            struct AnimatorKey: Hashable {
                var index: DisplayList.Index.ID
            }
        }
        
        private var oldCache: DisplayList.GraphicsRenderer.Cache
        private var newCache: DisplayList.GraphicsRenderer.Cache
        var index: DisplayList.Index
        var time: Time
        var nextTime: Time
        var stableIDs: _DisplayList_StableIdentityMap?
        var inTransitionGroup: Bool
        var stateHashes: [StrongHash]
        package var platformViewMode: DisplayList.GraphicsRenderer.PlatformViewMode
        
        package init(platformViewMode: DisplayList.GraphicsRenderer.PlatformViewMode) {
            fatalError("TODO")
        }
        
        package func render(at time: Time, do body: () -> Void) {
            fatalError("TODO")
        }
        
        package func renderDisplayList(_ list: DisplayList, at time: Time, in ctx: inout GraphicsContext) {
            fatalError("TODO")
        }
        
        package func render(list: DisplayList, in ctx: inout GraphicsContext) {
            fatalError("TODO")
        }
        
        package func render(item: DisplayList.Item, in ctx: inout GraphicsContext) {
            fatalError("TODO")
        }
        
        package func drawImplicitLayer(in ctx: inout GraphicsContext, content: (inout GraphicsContext) -> Void) {
            fatalError("TODO")
        }
        
        package func renderPlatformView(_ view: AnyObject?, in ctx: GraphicsContext, size: CGSize, viewType: any Any.Type) {
            fatalError("TODO")
        }
    }
}
