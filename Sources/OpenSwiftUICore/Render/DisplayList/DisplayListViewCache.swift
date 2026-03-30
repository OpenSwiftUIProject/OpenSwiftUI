//
//  DisplayListViewCache.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A9949015C771FF99F7528BB7239FD006 (SwiftUICore)

import Foundation
import OpenSwiftUI_SPI
import OpenQuartzCoreShims
import QuartzCore_Private

extension DisplayList.ViewUpdater {

    // MARK: - ViewCache

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

        var map: [Key: ViewInfo] = [:]

        var reverseMap: [OpaquePointer: Key] = [:]

        var removed: Set<Key> = []

        private struct AnimatorInfo {
            enum State {
                case idle
                case active(any DisplayList.AnyEffectAnimator)
                case finished(DisplayList.Effect, DisplayList.Version)
            }

            var state: State
            var deadline: Time
        }

        private var animators: [Key: AnimatorInfo] = [:]

        private struct AsyncValues {
            var animations: Set<String>
            var modifiers: [String: CAPresentationModifier]
        }

        private var asyncValues: [ObjectIdentifier: AsyncValues] = [:]

        private struct PendingAsyncValue {
            var keyPath: String
            var value: NSObject
            var usesPresentationModifier: Bool
        }

        private var pendingAsyncValues: [ObjectIdentifier: [PendingAsyncValue]] = [:]

        var asyncModifierGroup: CAPresentationModifierGroup?

        var pendingAsyncUpdates: [() -> Void] = []

        var index: DisplayList.Index = .init()

        var cacheSeed: UInt32 = .zero

        var currentList: DisplayList = .init()

        init(platform: Platform) {
            self.platform = platform
        }

        mutating func clearAsyncValues() {
            #if canImport(QuartzCore)
            for (layerID, asyncValueArray) in asyncValues {
                // Recover CALayer from ObjectIdentifier — the layer must still be alive
                // since ViewCache holds strong refs to views containing these layers.
                let layer = unsafeBitCast(layerID, to: CALayer.self)
                for animation in asyncValueArray.animations {
                    layer.removeAnimation(forKey: animation)
                }
                for modifier in asyncValueArray.modifiers.values {
                    layer.remove(modifier)
                }
            }
            #endif
            asyncValues = [:]
            asyncModifierGroup = nil
        }

        mutating func reclaim(time: Time) {
            removed.forEach { key in
                guard let info = map[key], info.isRemoved else { return }
                removeRecursively(info as AnyObject)
            }
            removed.removeAll()
            animators = animators.filter { $0.value.deadline >= time }
            cacheSeed &+= 1
        }

        /// Removes a managed subview from the cache and recursively
        /// cleans up its container children from the view hierarchy.
        private mutating func removeRecursively(_ object: AnyObject) {
            let info = object as! ViewInfo
            platform.forEachChild(of: info) { view in
                let pointer = unsafeBitCast(view, to: OpaquePointer.self)
                if let key = reverseMap.removeValue(forKey: pointer),
                   let newInfo = map.removeValue(forKey: key) {
                    removeRecursively(newInfo as AnyObject)
                }
                #if canImport(Darwin)
                CoreViewRemoveFromSuperview(system: platform.viewSystem, view: view)
                #endif
            }
        }

        mutating func commitAsyncValues(targetTimestamp: Time?) {
            #if canImport(QuartzCore)
            guard !pendingAsyncValues.isEmpty || !pendingAsyncUpdates.isEmpty else {
                return
            }
            // Activate background CA context if not on main thread
            if !Thread.isMainThread {
                CATransaction.activateBackground(true)
            }
            // Suppress implicit animations during commit
            let savedDisableActions = CATransaction.disableActions()
            if !savedDisableActions {
                CATransaction.setDisableActions(true)
            }
            // Track which modifier groups need flushing
            var modifiedGroups: Set<ObjectIdentifier> = []
            // Apply each pending async value to its layer
            for (layerID, pendingAsyncValueArray) in pendingAsyncValues {
                let layer = unsafeBitCast(layerID, to: CALayer.self)
                var asyncValueArray = asyncValues[layerID, default: .init(animations: [], modifiers: [:])]
                for pending in pendingAsyncValueArray {
                    if pending.usesPresentationModifier {
                        if let existing = asyncValueArray.modifiers[pending.keyPath] {
                            existing.value = pending.value
                            modifiedGroups.insert(ObjectIdentifier(existing.group!))
                        } else {
                            let group: CAPresentationModifierGroup
                            if let existingGroup = asyncModifierGroup,
                               existingGroup.count < existingGroup.capacity {
                                group = existingGroup
                            } else {
                                group = CAPresentationModifierGroup(capacity: 100)
                                group.updatesAsynchronously = false
                                asyncModifierGroup = group
                            }
                            let modifier = CAPresentationModifier(
                                keyPath: pending.keyPath,
                                initialValue: pending.value,
                                additive: false,
                                group: group
                            )
                            layer.add(modifier)
                            asyncValueArray.modifiers[pending.keyPath] = modifier
                            modifiedGroups.insert(ObjectIdentifier(group))
                        }
                    } else {
                        let animation = CABasicAnimation(keyPath: pending.keyPath)
                        animation.beginTime = -1
                        animation.duration = 1
                        animation.fillMode = .forwards
                        animation.toValue = pending.value
                        animation.isRemovedOnCompletion = false
                        layer.add(animation, forKey: pending.keyPath)
                        asyncValueArray.animations.insert(pending.keyPath)
                    }
                }
                asyncValues[layerID] = asyncValueArray
            }
            // Restore disableActions
            if !savedDisableActions {
                CATransaction.setDisableActions(false)
            }
            // Flush modified presentation modifier groups
            for groupID in modifiedGroups {
                let group = unsafeBitCast(groupID, to: CAPresentationModifierGroup.self)
                group.flushWithTransaction()
            }
            // Execute all completion closures
            for update in pendingAsyncUpdates {
                update()
            }
            // Reset state
            pendingAsyncValues = [:]
            pendingAsyncUpdates = []
            #else
            _openSwiftUIPlatformUnimplementedWarning()
            #endif
        }

        mutating func prepare(
            item: inout DisplayList.Item,
            parentState: UnsafePointer<Model.State>
        ) -> Time {
            switch item.value {
            case let .content(content):
                if case let .shape(_, paint, _) = content.value, !paint.isCALayerCompatible {
                    item.addDrawingGroup(contentSeed: .init(item.version))
                }
                return .infinity
            case let .effect(effect, displayList):
                switch effect {
                case let .archive(archiveIDs):
                    index.updateArchive(entering: archiveIDs != nil)
                    return .infinity
                case let .filter(filter):
                    if case .shader = filter {
                        item.addDrawingGroup(contentSeed: .init(item.version))
                    }
                    return .infinity
                case let .animation(animation):
                    return prepareAnimation(
                        animation,
                        displayList: displayList,
                        item: &item,
                        parentState: parentState,
                    )
                default:
                    return .infinity
                }
            default:
                return .infinity
            }
        }

        mutating func update(
            item: DisplayList.Item,
            state: UnsafePointer<Model.State>,
            tag: Tag,
            in parentID: ViewInfo.ID,
            makeView: (DisplayList.Index, DisplayList.Item, UnsafePointer<Model.State>) -> ViewInfo,
            updateView: (inout ViewInfo, DisplayList.Index, DisplayList.Item, UnsafePointer<Model.State>) -> Void
        ) -> Result {
            let key = Key(id: index.id, tag: tag)
            let version = item.version
            if let existingInfo = map[key] {
                var info = existingInfo
                guard info.cacheSeed != cacheSeed else {
                    let description = currentList.description
                    Log.internalError(
                        "repeated view: %u, %u, %u, %u, %s, %s",
                        key.id.identity.value,
                        key.id.serial,
                        key.id.archiveIdentity.value,
                        key.id.archiveSerial,
                        String(describing: info.state.kind),
                        description
                    )
                    preconditionFailure("repeated view: #\(key.id.identity.value), \(key.id.serial), \(key.id.archiveIdentity.value), \(key.id.archiveSerial), \(info.state.kind), \(description)")
                }
                defer { map[key] = info }
                // Update isRemoved
                if info.isRemoved {
                    info.isRemoved = false
                    removed.remove(key)
                }
                // Update cacheSeed
                info.cacheSeed = cacheSeed
                // Update nextUpdate
                let newSeed = DisplayList.Seed(version)
                var isInserted = info.seeds.item != newSeed || state.pointee.globals.pointee.time >= info.nextUpdate
                info.nextUpdate = .infinity
                // Update parentID
                let oldParentID = info.parentID
                if oldParentID != parentID {
                    info.parentID = parentID
                    info.seeds.invalidate()
                }
                // Update view
                let oldView = info.view
                updateView(&info, index, item, state)
                if !info.isInvalid {
                    info.seeds.item = DisplayList.Seed(version)
                }
                if info.view !== oldView {
                    reverseMap.removeValue(forKey: unsafeBitCast(oldView, to: OpaquePointer.self))
                    #if canImport(Darwin)
                    CoreViewRemoveFromSuperview(system: platform.viewSystem, view: oldView)
                    #endif
                    reverseMap[unsafeBitCast(info.view, to: OpaquePointer.self)] = key
                    #if canImport(QuartzCore)
                    if index.archiveIdentity == .none, item.identity != .none {
                        info.layer.displayListID = item.identity
                    }
                    #endif
                    isInserted = true
                }
                return Result(
                    view: info.view,
                    container: info.container,
                    id: info.id,
                    key: key,
                    isInserted: isInserted,
                    isValid: !info.isInvalid,
                    nextUpdate: info.nextUpdate
                )
            } else {
                var info = makeView(index, item, state)
                info.parentID = parentID
                info.cacheSeed = cacheSeed
                info.seeds.item = DisplayList.Seed(version)
                map[key] = info
                // If this view was previously cached under a different key,
                // remove the stale map entry for that old key.
                let viewPointer = unsafeBitCast(info.view, to: OpaquePointer.self)
                if let oldKey = reverseMap[viewPointer] {
                    map.removeValue(forKey: oldKey)
                }
                reverseMap[viewPointer] = key
                #if canImport(QuartzCore)
                if index.archiveIdentity == .none, item.identity != .none {
                    info.layer.displayListID = item.identity
                }
                #endif
                return Result(
                    view: info.view,
                    container: info.container,
                    id: info.id,
                    key: key,
                    isInserted: true,
                    isValid: !info.isInvalid,
                    nextUpdate: info.nextUpdate
                )
            }
        }

        struct Result {
            var view: AnyObject
            var container: AnyObject
            var id: ViewInfo.ID
            var key: Key
            var isInserted: Bool
            var isValid: Bool
            var nextUpdate: Time
        }

        mutating func setNextUpdate(
            _ time: Time,
            in result: inout Result
        ) {
            guard time < result.nextUpdate else { return }
            result.nextUpdate = time
            map[result.key]!.nextUpdate = time
        }

        struct AsyncResult {
            var unknown: AnyObject // FIXME
            var key: Key
            var nextUpdate: Time
        }

        mutating func setNextUpdate(
            _ time: Time,
            in result: inout AsyncResult
        ) {
            guard time < result.nextUpdate else { return }
            result.nextUpdate = time
            map[result.key]!.nextUpdate = time
        }

        mutating func setAsyncValue(
            _ value: NSObject,
            for key: String,
            in layer: CALayer,
            usingPresentationModifier: Bool
        ) {
            let layerID = ObjectIdentifier(layer)
            pendingAsyncValues[layerID, default: []].append(
                PendingAsyncValue(
                    keyPath: key,
                    value: value,
                    usesPresentationModifier: usingPresentationModifier
                )
            )
        }

        private mutating func prepareAnimation(
            _ animation: any DisplayList.AnyEffectAnimation,
            displayList: DisplayList,
            item: inout DisplayList.Item,
            parentState: UnsafePointer<Model.State>
        ) -> Time {
            let key = Key(id: index.id, tag: .item)
            let time = parentState.pointee.globals.pointee.time
            var animatorInfo = animators[key, default: .init(state: .idle, deadline: .zero)]
            if case .idle = animatorInfo.state {
                // If idle, initialize by creating an animator from the animation
                animatorInfo.state = .active(animation.makeAnimator())
            }
            switch animatorInfo.state {
            case let .active(animator):
                // Reset to idle before evaluation
                animatorInfo.state = .idle
                // Evaluate the animation effect
                let (effect, finished) = animator.evaluate(
                    animation,
                    at: time,
                    size: item.size,
                )
                // Swap item value with the animation effect
                item.value = .effect(effect, displayList)
                let maxVersion = parentState.pointee.globals.pointee.maxVersion
                item.version = maxVersion
                if finished {
                    animatorInfo.state = .finished(effect, maxVersion)
                } else {
                    animatorInfo.state = .active(animator)
                }
                animatorInfo.deadline = time
                animators[key] = animatorInfo
                return finished ? .infinity : time
            case let .finished(effect, version):
                // Re-apply the stored final effect
                item.value = .effect(effect, displayList)
                item.version = version
                animatorInfo.deadline = time
                animators[key] = animatorInfo
                return .infinity
            case .idle:
                _openSwiftUIUnreachableCode()
            }
        }
    }
}

#if canImport(QuartzCore)
import OpenSwiftUI_SPI
package import QuartzCore

extension CALayer {
    package var displayListID: DisplayList.Identity {
        get { DisplayList.Identity(value: .init(openSwiftUI_displayListID)) }
        set { openSwiftUI_displayListID = .init(newValue.value) }
    }
}
#endif
