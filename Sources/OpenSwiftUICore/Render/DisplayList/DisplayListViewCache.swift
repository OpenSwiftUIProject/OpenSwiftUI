//
//  DisplayListViewCache.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: A9949015C771FF99F7528BB7239FD006 (SwiftUICore)

import Foundation
import OpenQuartzCoreShims
import QuartzCore_Private

extension DisplayList.ViewUpdater {

    // MARK: - ViewCache [WIP]

    struct ViewCache {

        // MARK: - Tag

        enum Tag: UInt8 {
            case item
            case inherited
        }

        // MARK: - Key

        struct Key: Hashable {
            var id: DisplayList.Index.ID
            var tag: Tag
        }

        let platform: Platform

        var map: [Key: ViewInfo]

        var reverseMap: [OpaquePointer: Key]

        var removed: Set<Key>

        private struct AnimatorInfo {
            enum State {
                case idle
                case active(DisplayList.AnyEffectAnimator)
                case finished(DisplayList.Effect, DisplayList.Version)
            }

            var state: State
            var deadline: Time
        }

        private var animators: [Key: AnimatorInfo]

        private struct AsyncValues {
            var animations: Set<String>
            var modifiers: [String: CAPresentationModifier]
        }

        private var asyncValues: [ObjectIdentifier: AsyncValues]

        private struct PendingAsyncValue {
            var keyPath: String
            var value: NSObject
            var usesPresentationModifier: Bool
        }

        private var pendingAsyncValues: [ObjectIdentifier: [PendingAsyncValue]]

        var asyncModifierGroup: CAPresentationModifierGroup?

        var pendingAsyncUpdates: [() -> Void]

        var index: DisplayList.Index

        var cacheSeed: UInt32

        var currentList: DisplayList

        // MARK: - Init

        init(platform: Platform) {
            self.platform = platform
            self.map = [:]
            self.reverseMap = [:]
            self.removed = []
            self.animators = [:]
            self.asyncValues = [:]
            self.pendingAsyncValues = [:]
            self.pendingAsyncUpdates = []
            self.index = DisplayList.Index()
            self.cacheSeed = 0
            self.currentList = DisplayList()
        }

        mutating func clearAsyncValues() {
            _openSwiftUIUnimplementedFailure()
        }

        mutating func reclaim(time: Time) {
            _openSwiftUIUnimplementedFailure()
        }

        mutating func commitAsyncValues(targetTimestamp: Time?) {
            _openSwiftUIUnimplementedFailure()
        }

        mutating func prepare(
            item: inout DisplayList.Item,
            parentState: UnsafePointer<Model.State>
        ) -> Time {
            _openSwiftUIUnimplementedFailure()
        }

        struct Result {}

        mutating func update(
            item: DisplayList.Item,
            state: UnsafePointer<Model.State>,
            tag: Tag,
            in parentID: ViewInfo.ID,
            makeView: (DisplayList.Index, DisplayList.Item, UnsafePointer<Model.State>) -> DisplayList.ViewUpdater.ViewInfo,
            updateView: (inout ViewInfo, DisplayList.Index, DisplayList.Item, UnsafePointer<Model.State>) -> Void
        ) -> Result {
            _openSwiftUIUnimplementedFailure()
        }

        mutating func setNextUpdate(
            _ time: Time,
            in result: inout Result
        ) {
            _openSwiftUIUnimplementedFailure()
        }

        struct AsyncResult {}

        mutating func setNextUpdate(
            _ time: Time,
            in result: inout AsyncResult
        ) {
            _openSwiftUIUnimplementedFailure()
        }

        mutating func setAsyncValue(
            _ value: NSObject,
            for key: String,
            in layer: CALayer,
            usingPresentationModifier: Bool
        ) {
            _openSwiftUIUnimplementedFailure()
        }

        private mutating func prepareAnimation(
            _ animation: any DisplayList.AnyEffectAnimation,
            displayList: DisplayList,
            item: inout DisplayList.Item,
            parentState: UnsafePointer<Model.State>
        ) -> Time {
            _openSwiftUIUnimplementedFailure()
        }
    }
}
