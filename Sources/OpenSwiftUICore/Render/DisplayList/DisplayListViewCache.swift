//
//  DisplayListViewCache.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: A9949015C771FF99F7528BB7239FD006 (SwiftUICore)

import Foundation

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
        // TODO
        var pendingAsyncUpdates: [() -> ()]
        var index: DisplayList.Index
        var cacheSeed: Swift.UInt32
        var currentList: DisplayList
    }
}
