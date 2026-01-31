//
//  SceneBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A9714FE7FB47B9EE521B92A735A59E38 (SwiftUI)

#if canImport(Darwin)
#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif
@_spi(Private)
import OpenSwiftUICore

// MARK: - UserActivityTrackingInfo

var _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled = false

class UserActivityTrackingInfo: NSObject, NSUserActivityDelegate {
    var userActivity: NSUserActivity?
    var handlers: [ViewIdentity: (NSUserActivity) -> Bool] = [:]
    weak var sceneBridge: SceneBridge?
    let activityType: String

    init(_ sceneBridge: SceneBridge, activityType: String) {
        self.sceneBridge = sceneBridge
        self.activityType = activityType
        super.init()
    }

    override var description: String {
        "UserActivityTrackingInfo: sceneBridge: \(String(describing: sceneBridge)),\nhandlers count \(handlers.count),\nactivity type: \(String(describing: userActivity?.activityType)),\nactivity title \(String(describing: userActivity?.title))"
    }

    func userActivityWillSave(_ userActivity: NSUserActivity) {
        if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
            Log.log("userActivityWillSave called for \(description)")
        }
        if Thread.isMainThread {
            updateUserActivity(userActivity)
        } else {
            DispatchQueue.main.sync {
                updateUserActivity(userActivity)
            }
        }
    }

    func updateUserActivity(_ userActivity: NSUserActivity) {
        guard let currentActivity = self.userActivity,
              currentActivity == userActivity else {
            if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log("Mismatched UserActivity in tracking info, skipping update.")
            }
            return
        }
        guard let sceneBridge else { return }
        let failedIDs = handlers.compactMap { identity, handler in
            if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log("Invoking handler for \(identity)")
            }
            return handler(userActivity) ? nil : identity
        }
        for id in failedIDs {
            handlers[id] = nil
        }
        if handlers.isEmpty {
            sceneBridge.userActivityTrackingInfo = nil
            #if os(iOS) || os(visionOS)
            if let rootViewController = sceneBridge.rootViewController {
                rootViewController.userActivity = nil
            } else {
                sceneBridge.initialUserActivity = nil
            }
            #elseif os(macOS)
            if let window = sceneBridge.window {
                window.userActivity = nil
            } else {
                sceneBridge.initialUserActivity = nil
            }
            #else
            _openSwiftUIUnimplementedWarning()
            #endif
        } else if !failedIDs.isEmpty {
            sceneBridge.userActivityTrackingInfo = self
        }
        userActivity.needsSave = false
        if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
            Log.log(
                "updated user activity \(String(describing: userActivity.title)) "
                + "with userInfo \(String(describing: userActivity.userInfo))"
            )
        }
    }
}

// MARK: - SceneBridge

final class SceneBridge: CustomStringConvertible {
    private var sceneBridgePublishers: [AnyHashable: [AnyHashable: PassthroughSubject<Any, Never>]] = [:]
    var isAnimatingSceneResize: Bool = false
    #if os(iOS) || os(visionOS)
    weak var windowScene: UIWindowScene?
    weak var rootViewController: UIViewController?
    private var sceneDefinitionOptionsSeedTracker: VersionSeedTracker<ConnectionOptionPayloadStoragePreferenceKey> = .init()
    var sceneDefinitionOptions: ConnectionOptionPayloadStorage = .init()
    private var titleSeedTracker: VersionSeedTracker<NavigationTitleKey> = .init()
    private var colorSchemeSeed: VersionSeedTracker<PreferredColorSchemeKey> = .init()
    #elseif os(macOS)
    weak var window: NSWindow?
    #endif
    fileprivate var initialUserActivity: NSUserActivity?
    private weak var viewGraph: ViewGraph?
    private var sceneActivationConditions: (preferring: Set<String>, allowing: Set<String>)?
    fileprivate var userActivityTrackingInfo: UserActivityTrackingInfo? {
        didSet {
            _ = publishEvent(
                event: userActivityTrackingInfo as Any,
                type: UserActivityTrackingInfo?.self,
                identifier: "UserActivityTrackingInfo"
            )
        }
    }
    private var userActivityPreferenceSeed: VersionSeed?
    private var activationConditionsPreferenceSeed: VersionSeed?
    var initialSceneSizeState: InitialSceneSizeState = .none
    private var enqueuedEvents: [String: [Any]] = [:]

    private static var _devNullSceneBridge: SceneBridge?

    init() {
        _openSwiftUIEmptyStub()
    }

    var description: String {
        #if os(iOS) || os(visionOS)
        "SceneBridge: rootViewController = \(String(describing: rootViewController))"
        #elseif os(macOS)
        "SceneBridge: window = \(String(describing: window))"
        #endif
    }

    // MARK: - Event Publishing

    fileprivate func publishEvent(event: Any, type: Any.Type, identifier: String) -> Bool {
        guard Self._devNullSceneBridge == nil || Self._devNullSceneBridge !== self,
              let publishers = sceneBridgePublishers[AnyHashable(ObjectIdentifier(type))],
              let subject = publishers[AnyHashable(identifier)]
        else {
            enqueueUnpublishedEvent(event, for: identifier)
            return false
        }
        subject.send(event)
        return true
    }

    fileprivate func flushEnqueuedEvents(for identifier: String, type: Any.Type) {
        guard !enqueuedEvents.isEmpty,
              let events = enqueuedEvents[identifier],
              !events.isEmpty else {
            return
        }
        enqueuedEvents.removeValue(forKey: identifier)
        for event in events {
            _ = publishEvent(event: event, type: type, identifier: identifier)
        }
    }

    private func enqueueUnpublishedEvent(_ event: Any, for identifier: String) {
        var events = enqueuedEvents[identifier] ?? []
        events.append(event)
        enqueuedEvents[identifier] = events
    }

    // MARK: - Preference Changes

    struct UserActivityPreferenceKey: HostPreferenceKey {
        typealias Value = (activityType: String, handlers: [ViewIdentity: (NSUserActivity) -> Bool])?

        static var defaultValue: Value { nil }

        static func reduce(value: inout Value, nextValue: () -> Value) {
            if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log(
                    "Reducing UserActivityPreference " +
                    "\(String(describing: value)) " +
                    "with \(String(describing: nextValue()))"
                )
            }
            defer {
                if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                    Log.log(
                        "Reduced UserActivityPreference to " +
                        "\(String(describing: value))"
                    )
                }
            }
            guard let current = value else {
                value = nextValue()
                return
            }
            guard let next = nextValue() else {
                return
            }
            guard current.activityType == next.activityType else {
                return
            }
            value = (
                activityType: current.activityType,
                handlers: current.handlers.merging(next.handlers) {
                    old, _ in old // [Q]
                }
            )
        }
    }

    func userActivityPreferencesDidChange(_ preferences: PreferenceValues) {
        let preferenceValue = preferences[UserActivityPreferenceKey.self]
        if let userActivityPreferenceSeed,
           preferenceValue.seed.matches(userActivityPreferenceSeed) {
            if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log(
                    "UserActivity Preferences hasn't changed, skipping update for advertised NSUserActivities. " +
                    "Seed is \(preferenceValue.seed)"
                )
            }
        } else {
            if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log(
                    "UserActivityPreferences changed: " +
                    "\(preferenceValue)"
                )
            }
            userActivityPreferenceSeed = preferenceValue.seed
            guard let value = preferenceValue.value, !value.handlers.isEmpty else {
                userActivityTrackingInfo = nil
                #if os(iOS) || os(visionOS)
                if let rootViewController {
                    rootViewController.userActivity = nil
                } else {
                    initialUserActivity = nil
                }
                #elseif os(macOS)
                if let window {
                    window.userActivity = nil
                } else {
                    initialUserActivity = nil
                }
                #endif
                if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                    Log.log("Cleared AdvertiseUserActivity tracking info since UserActivity preferences are empty")
                }
                return
            }
            let trackingInfo = userActivityTrackingInfo ?? UserActivityTrackingInfo(
                self,
                activityType: value.activityType
            )
            if let existingActivity = trackingInfo.userActivity,
               existingActivity.activityType == value.activityType {
                trackingInfo.userActivity?.needsSave = true
            } else {
                let activity = NSUserActivity(activityType: value.activityType)
                activity.becomeCurrent()
                let oldActivity = trackingInfo.userActivity
                trackingInfo.userActivity = activity
                if activity !== oldActivity {
                    activity.delegate = trackingInfo
                }
                if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                    Log.log(
                        "Initializing advertised user activity: " +
                        "\(String(describing: trackingInfo.userActivity))"
                    )
                }
                userActivityTrackingInfo = trackingInfo
                #if os(iOS) || os(visionOS)
                if let rootViewController {
                    rootViewController.userActivity = trackingInfo.userActivity
                } else {
                    initialUserActivity = trackingInfo.userActivity
                }
                #elseif os(macOS)
                if let window {
                    window.userActivity = trackingInfo.userActivity
                } else {
                    initialUserActivity = trackingInfo.userActivity
                }
                #endif
                if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                    Log.log(
                        "View Advertising UserActivity, set rootViewController activity to " +
                        "\(String(describing: trackingInfo.userActivity))"
                    )
                }
            }
            trackingInfo.handlers = value.handlers
            if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log(
                    "Set up AdvertiseUserActivity tracking info from " +
                    "value in UserActivityPreferenceKey: \(trackingInfo.description)"
                )
            }
        }
    }

    struct ActivationConditionsPreferenceKey: HostPreferenceKey {
        typealias Value = (preferring: Set<String>, allowing: Set<String>)?

        static var defaultValue: Value { nil }

        static func reduce(value: inout Value, nextValue: () -> Value) {
            guard let current = value else {
                value = nextValue()
                return
            }
            guard let next = nextValue() else {
                return
            }
            value = Value((
                preferring: current.preferring.union(next.preferring),
                allowing: current.allowing.union(next.allowing)
            ))
        }
    }

    func activationConditionsPreferencesDidChange(_ preferences: PreferenceValues) {
        let preferenceValue = preferences[ActivationConditionsPreferenceKey.self]
        if let activationConditionsPreferenceSeed,
           preferenceValue.seed.matches(activationConditionsPreferenceSeed) {
            if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log(
                    "ActivationConditions Preferences hasn't changed, skipping update for Scene ActivationConditions. " +
                    "Seed is \(preferenceValue.seed)"
                )
            }
        } else {
            if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log(
                    "ActivationConditionPreferences changed: " +
                    "\(preferenceValue)"
                )
            }
            activationConditionsPreferenceSeed = preferenceValue.seed
            setActivationConditions(preferenceValue.value)
            if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log(
                    "Set Scene ActivationConditions to " +
                    "\(String(describing: sceneActivationConditions))"
                )
            }
        }
    }

    private func setActivationConditions(_ conditions: (preferring: Set<String>, allowing: Set<String>)?) {
        #if os(iOS) || os(visionOS)
        guard conditions != nil || sceneActivationConditions != nil else {
            return
        }
        guard let windowScene else { return }
        let existingConditions = windowScene.activationConditions
        guard let conditions else {
            windowScene.activationConditions = existingConditions
            return
        }
        let preferringChanged = sceneActivationConditions?.preferring != conditions.preferring
        if preferringChanged {
            existingConditions.prefersToActivateForTargetContentIdentifierPredicate = buildActivationConditions(conditions.preferring)
        }
        let allowingChanged = sceneActivationConditions?.allowing != conditions.allowing
        if allowingChanged {
            existingConditions.canActivateForTargetContentIdentifierPredicate = buildActivationConditions(conditions.allowing)
        }
        if preferringChanged || allowingChanged {
            let newConditions = UISceneActivationConditions()
            newConditions.prefersToActivateForTargetContentIdentifierPredicate = existingConditions.prefersToActivateForTargetContentIdentifierPredicate
            newConditions.canActivateForTargetContentIdentifierPredicate = existingConditions.canActivateForTargetContentIdentifierPredicate
            windowScene.activationConditions = newConditions
            if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log(
                    "Changed Scene ActivationConditions to " +
                    "\(windowScene.activationConditions.description)"
                )
            }
            sceneActivationConditions = conditions
        }
        #elseif os(macOS)
        sceneActivationConditions = conditions
        #endif
    }

    #if os(iOS) || os(visionOS)
    private func buildActivationConditions(_ identifiers: Set<String>?) -> NSPredicate {
        guard let identifiers else {
            return NSPredicate(value: false)
        }
        guard !identifiers.contains("*") else {
            return NSPredicate(value: true)
        }
        let predicates = identifiers.compactMap { identifier -> NSPredicate? in
            guard !identifier.isEmpty else { return nil }
            return NSPredicate(format: "self contains[cd] %@", identifier)
        }
        guard !predicates.isEmpty else {
            return NSPredicate(value: false)
        }
        guard predicates.count > 1 else {
            return predicates[0]
        }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    #endif

    // MARK: - Window Size Restrictions

    #if os(iOS) || os(visionOS)
    func updateWindowSizeRestrictions(min: CGSize?, max: CGSize?) {
        if let minSize = min, let scene = windowScene {
            scene.sizeRestrictions?.minimumSize = minSize
        }
        if let maxSize = max, let scene = windowScene {
            scene.sizeRestrictions?.maximumSize = maxSize
        }
    }
    #endif
}
#endif
