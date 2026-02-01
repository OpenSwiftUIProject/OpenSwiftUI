//
//  SceneBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A9714FE7FB47B9EE521B92A735A59E38 (SwiftUI)
//  TODO: Add test case and verify [Q]

#if canImport(Darwin)
#if os(iOS) || os(visionOS)
public import UIKit
#elseif os(macOS)
public import AppKit
#endif
#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif
@_spi(Private)
import OpenSwiftUICore

// MARK: - Logging

@available(OpenSwiftUI_v2_0, *)
public var _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled = false

@_transparent
private func activityEnvironmentLog(_ message: @autoclosure () -> String) {
    if _defaultOpenSwiftUIActivityEnvironmentLoggingEnabled {
        Log.log(message())
    }
}

// MARK: - UserActivityTrackingInfo

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
        activityEnvironmentLog("userActivityWillSave called for \(description)")
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
            activityEnvironmentLog("Mismatched UserActivity in tracking info, skipping update.")
            return
        }
        guard let sceneBridge else { return }
        let failedIDs = handlers.compactMap { identity, handler in
            activityEnvironmentLog("Invoking handler for \(identity)")
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
        activityEnvironmentLog(
            "updated user activity \(String(describing: userActivity.title)) "
            + "with userInfo \(String(describing: userActivity.userInfo))"
        )
    }
}

// MARK: - SceneBridge

final class SceneBridge: ObservableObject, CustomStringConvertible {
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

    fileprivate static var _devNullSceneBridge: SceneBridge?

    fileprivate static func sceneBridgePublisher(
        _ type: Any.Type,
        identifier: String,
        sceneBridge: SceneBridge
    ) -> PassthroughSubject<Any, Never> {
        let publishers = sceneBridge.sceneBridgePublishers[AnyHashable(ObjectIdentifier(type))]
        guard let publishers,
              let subject = publishers[AnyHashable(identifier)] else {
            let subject = PassthroughSubject<Any, Never>()
            let newPublishers: [AnyHashable: PassthroughSubject<Any, Never>]
            if var publishers {
                publishers[AnyHashable(identifier)] = subject
                newPublishers = publishers
            } else {
                newPublishers = [AnyHashable(identifier): subject]
            }
            sceneBridge.sceneBridgePublishers[AnyHashable(ObjectIdentifier(type))] = newPublishers
            DispatchQueue.main.async {
                sceneBridge.flushEnqueuedEvents(for: identifier, type: type)
            }
            return subject
        }
        return subject
    }

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
            activityEnvironmentLog(
                "Reducing UserActivityPreference " +
                "\(String(describing: value)) " +
                "with \(String(describing: nextValue()))"
            )
            defer {
                activityEnvironmentLog(
                    "Reduced UserActivityPreference to " +
                    "\(String(describing: value))"
                )
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
            activityEnvironmentLog(
                "UserActivity Preferences hasn't changed, skipping update for advertised NSUserActivities. " +
                "Seed is \(preferenceValue.seed)"
            )
        } else {
            activityEnvironmentLog(
                "UserActivityPreferences changed: " +
                "\(preferenceValue)"
            )
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
                activityEnvironmentLog("Cleared AdvertiseUserActivity tracking info since UserActivity preferences are empty")
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
                activityEnvironmentLog(
                    "Initializing advertised user activity: " +
                    "\(String(describing: trackingInfo.userActivity))"
                )
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
                activityEnvironmentLog(
                    "View Advertising UserActivity, set rootViewController activity to " +
                    "\(String(describing: trackingInfo.userActivity))"
                )
            }
            trackingInfo.handlers = value.handlers
            activityEnvironmentLog(
                "Set up AdvertiseUserActivity tracking info from " +
                "value in UserActivityPreferenceKey: \(trackingInfo.description)"
            )
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
            activityEnvironmentLog(
                "ActivationConditions Preferences hasn't changed, skipping update for Scene ActivationConditions. " +
                "Seed is \(preferenceValue.seed)"
            )
        } else {
            activityEnvironmentLog(
                "ActivationConditionPreferences changed: " +
                "\(preferenceValue)"
            )
            activationConditionsPreferenceSeed = preferenceValue.seed
            setActivationConditions(preferenceValue.value)
            activityEnvironmentLog(
                "Set Scene ActivationConditions to " +
                "\(String(describing: sceneActivationConditions))"
            )
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
            activityEnvironmentLog(
                "Changed Scene ActivationConditions to " +
                "\(windowScene.activationConditions.description)"
            )
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

// MARK: - SceneBridgeReader

private struct SceneBridgeReader<V>: View where V: View {
    @Environment private var sceneBridge: SceneBridge?
    var handler: (SceneBridge) -> V

    init(
        sceneBridge: Environment<SceneBridge?> = .init(SceneBridge.environmentStore),
        handler: @escaping (SceneBridge) -> V
    ) {
        self._sceneBridge = sceneBridge
        self.handler = handler
    }

    var body: some View {
        let sceneBridge = sceneBridge
        let bridge: SceneBridge
        if let sceneBridge {
            bridge = sceneBridge
        } else {
            Log.externalWarning("Cannot use Scene methods for URL, NSUserActivity, and other External Events without using OpenSwiftUI Lifecycle. Without OpenSwiftUI Lifecycle, advertising and handling External Events wastes resources, and will have unpredictable results.")
            if SceneBridge._devNullSceneBridge == nil {
                SceneBridge._devNullSceneBridge = SceneBridge()
            }
            bridge = SceneBridge._devNullSceneBridge!
        }
        return handler(bridge)
    }
}

// MARK: - UserActivityModifier

struct UserActivityModifier: ViewModifier {
    let activityType: String
    let isActive: Bool
    let update: (NSUserActivity) -> ()
    @State private var info: UserActivityTrackingInfo?

    var scrapeableAttachment: ScrapeableContent.Content? {
        guard isActive else {
            return nil
        }
        let activity: NSUserActivity
        if let info,
           info.activityType == activityType,
           let userActivity = info.userActivity {
            activity = userActivity
        } else {
            activity = NSUserActivity(activityType: activityType)
        }
        return .userActivity(activity)
    }

    func body(content: Content) -> some View {
        SceneBridgeReader { bridge in
            content
                .advertiseUserActivity(activityType, isActive: isActive, sceneBridge: bridge) { activity in
                    guard isActive else {
                        activityEnvironmentLog("Skipping inactive advertiseUserActivity handler")
                        return false
                    }
                    update(activity)
                    return true
                }
                .onReceive(
                    SceneBridge.sceneBridgePublisher(
                        UserActivityTrackingInfo?.self,
                        identifier: "UserActivityTrackingInfo",
                        sceneBridge: bridge
                    )
                ) { output in
                    guard let output = output as? UserActivityTrackingInfo? else {
                        return
                    }
                    info = output
                }
                .scrapeableAttachment(scrapeableAttachment)
        }
    }
}

@available(OpenSwiftUI_v2_0, *)
extension View {
    fileprivate func advertiseUserActivity(
        _ activityType: String,
        isActive: Bool,
        sceneBridge: SceneBridge?,
        handler: @escaping (NSUserActivity) -> Bool
    ) -> some View {
        transformIdentifiedPreference(SceneBridge.UserActivityPreferenceKey.self) { value, identity in
            activityEnvironmentLog(
                "TransformIdentifiedPreference closure for UserActivity " +
                "called with value \(String(describing: value))"
            )
            guard isActive, let sceneBridge else {
                activityEnvironmentLog("TransformIdentifiedPreference closure for UserActivity:  inactive, leaving value alone")
                return
            }
            var handlers: [ViewIdentity: (NSUserActivity) -> Bool]
            if let value, value.activityType == activityType {
                handlers = value.handlers
                handlers[identity] = handler
            } else {
                handlers = [identity: handler]
            }
            value = .init((activityType: activityType, handlers: handlers))
            activityEnvironmentLog(
                "TransformIdentifiedPreference for UserActivity setting value " +
                "to \(String(describing: value))"
            )
        }
    }

    /// Advertises a user activity type.
    ///
    /// You can use `userActivity(_:isActive:_:)` to start, stop, or modify the
    /// advertisement of a specific type of user activity.
    ///
    /// The scope of the activity applies only to the scene or window the
    /// view is in.
    ///
    /// - Parameters:
    ///   - activityType: The type of activity to advertise.
    ///   - isActive: When `false`, avoids advertising the activity. Defaults
    ///     to `true`.
    ///   - update: A function that modifies the passed-in activity for
    ///     advertisement.
    nonisolated public func userActivity(
        _ activityType: String,
        isActive: Bool = true,
        _ update: @escaping (NSUserActivity) -> ()
    ) -> some View {
        modifier(
            UserActivityModifier(
                activityType: activityType,
                isActive: isActive,
                update: update
            )
        )
    }

    /// Advertises a user activity type.
    ///
    /// The scope of the activity applies only to the scene or window the
    /// view is in.
    ///
    /// - Parameters:
    ///   - activityType: The type of activity to advertise.
    ///   - element: If the element is `nil`, the handler will not be
    ///     associated with the activity (and if there are no handlers, no
    ///     activity is advertised). The method passes the non-`nil` element to
    ///     the handler as a convenience so the handlers don't all need to
    ///     implement an early exit with
    ///     `guard let element = element else { return }`.
    ///    - update: A function that modifies the passed-in activity for
    ///    advertisement.
    nonisolated public func userActivity<P>(
        _ activityType: String,
        element: P?,
        _ update: @escaping (P, NSUserActivity) -> ()
    ) -> some View {
        userActivity(
            activityType,
            isActive: element == nil
        ) { activity in
            guard let element else { return }
            update(element, activity)
        }
    }

    /// Registers a handler to invoke in response to a user activity that your
    /// app receives.
    ///
    /// Use this view modifier to receive
    /// [NSUserActivity](https://developer.apple.com/documentation/foundation/nsuseractivity)
    /// instances in a particular scene within your app. The scene that OpenSwiftUI
    /// routes the incoming user activity to depends on the structure of your
    /// app, what scenes are active, and other configuration. For more
    /// information, see ``Scene/handlesExternalEvents(matching:)``.
    ///
    /// UI frameworks traditionally pass Universal Links to your app using a
    /// user activity. However, OpenSwiftUI passes a Universal Link to your app
    /// directly as a URL. To receive a Universal Link, use the
    /// ``View/onOpenURL(perform:)`` modifier instead.
    ///
    /// - Parameters:
    ///   - activityType: The type of activity that the `action` closure
    ///     handles. Be sure that this string matches one of the values that
    ///     you list in the
    ///     [NSUserActivityTypes](https://developer.apple.com/documentation/bundleresources/information_property_list/nsuseractivitytypes)
    ///     array in your app's Information Property List.
    ///   - action: A closure that OpenSwiftUI calls when your app receives a user
    ///     activity of the specified type. The closure takes the activity as
    ///     an input parameter.
    ///
    /// - Returns: A view that handles incoming user activities.
    nonisolated public func onContinueUserActivity(
        _ activityType: String,
        perform action: @escaping (NSUserActivity) -> ()
    ) -> some View {
        SceneBridgeReader { bridge in
            let publisher = SceneBridge.sceneBridgePublisher(
                NSUserActivity.self,
                identifier: activityType,
                sceneBridge: bridge
            )
            return self.onReceive(publisher) { output in
                guard let activity = output as? NSUserActivity else {
                    activityEnvironmentLog(
                        "onUserActivity skipping event with " +
                        "identifier \(activityType), published object is not " +
                        "a NSUserActivity: \(output)"
                    )
                    return
                }
                action(activity)
            }
        }
    }

    /// Registers a handler to invoke in response to a URL that your app
    /// receives.
    ///
    /// Use this view modifier to receive URLs in a particular scene within your
    /// app. The scene that OpenSwiftUI routes the incoming URL to depends on the
    /// structure of your app, what scenes are active, and other configuration.
    /// For more information, see ``Scene/handlesExternalEvents(matching:)``.
    ///
    /// UI frameworks traditionally pass Universal Links to your app using an
    /// [NSUserActivity](https://developer.apple.com/documentation/foundation/nsuseractivity).
    /// However, OpenSwiftUI passes a Universal Link to your app directly as a URL,
    /// which you receive using this modifier. To receive other user activities,
    /// like when your app participates in Handoff, use the
    /// ``View/onContinueUserActivity(_:perform:)`` modifier instead.
    ///
    /// For more information about linking into your app, see
    /// [Allowing Apps and Websites to Link to Your Content](https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content).
    ///
    /// - Parameter action: A closure that OpenSwiftUI calls when your app receives
    ///   a Universal Link or a custom
    ///   [URL](https://developer.apple.com/documentation/foundation/url).
    ///   The closure takes the URL as an input parameter.
    ///
    /// - Returns: A view that handles incoming URLs.
    nonisolated public func onOpenURL(perform action: @escaping (URL) -> ()) -> some View {
        SceneBridgeReader { bridge in
            let publisher = SceneBridge.sceneBridgePublisher(
                OpenURLContext.self,
                identifier: "OpenURLContext",
                sceneBridge: bridge
            )
            return self.onReceive(publisher) { output in
                guard let context = output as? OpenURLContext else {
                    activityEnvironmentLog(
                        "onURL skipping event for OpenURLContext, " +
                        "published object is not a OpenURLContext: \(output)"
                    )
                    return
                }
                action(context.url)
            }
        }
    }

    #if os(iOS) || os(visionOS)
    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    nonisolated public func onOpenURL(perform action: @escaping (URL, OpenURLOptions?) -> ()) -> some View {
        SceneBridgeReader { bridge in
            let publisher = SceneBridge.sceneBridgePublisher(
                OpenURLContext.self,
                identifier: "OpenURLContext",
                sceneBridge: bridge
            )
            return self.onReceive(publisher) { output in
                guard let context = output as? OpenURLContext else {
                    activityEnvironmentLog(
                        "onURL skipping event for OpenURLContext, " +
                        "published object is not a OpenURLContext: \(output)"
                    )
                    return
                }
                action(context.url, context.options)
            }
        }
    }
    #endif
}

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {

    /// Specifies the external events that the view's scene handles
    /// if the scene is already open.
    ///
    /// Apply this modifier to a view to indicate whether an open scene that
    /// contains the view handles specified user activities or URLs that your
    /// app receives. Specify two sets of string identifiers to distinguish
    /// between the kinds of events that the scene _prefers_ to handle
    /// and those that it _can_ handle. You can dynamically update the
    /// identifiers in each set to reflect changing app state.
    ///
    /// When your app receives an event on a platform that supports multiple
    /// simultaneous scenes, OpenSwiftUI sends the event to the first
    /// open scene it finds that prefers to handle the event. Otherwise,
    /// it sends the event to the first open scene it finds that can handle
    /// the event. If it finds neither --- including when you don't add
    /// this view modifier --- OpenSwiftUI creates a new scene for the event.
    ///
    /// > Important: Don't confuse this view modifier with the
    ///   ``Scene/handlesExternalEvents(matching:)`` _scene_ modifier. You use
    ///   the view modifier to indicate that an open scene handles certain
    ///   events, whereas you use the scene modifier to help OpenSwiftUI choose a
    ///   new scene to open when no open scene handles the event.
    ///
    /// On platforms that support only a single scene, OpenSwiftUI ignores this
    /// modifier and sends all external events to the one open scene.
    ///
    /// ### Matching an event
    ///
    /// To find an open scene that handles a particular external event, OpenSwiftUI
    /// compares a property of the event against the strings that you specify
    /// in the `preferring` and `allowing` sets. OpenSwiftUI examines the
    /// following event properties to perform the comparison:
    ///
    /// * For an
    ///   [NSUserActivity](https://developer.apple.com/documentation/foundation/nsuseractivity),
    ///   like when your app handles Handoff, OpenSwiftUI uses the activity's
    ///   [targetContentIdentifier](https://developer.apple.com/documentation/foundation/nsuseractivity/3238062-targetcontentidentifier)
    ///   property, or if that's `nil`, its
    ///   [webpageURL](https://developer.apple.com/documentation/foundation/nsuseractivity/1418086-webpageurl)
    ///   property rendered as an
    ///   [absoluteString](https://developer.apple.com/documentation/foundation/url/1779984-absolutestring).
    /// * For a
    ///   [URL](https://developer.apple.com/documentation/foundation/url),
    ///   like when another process opens a URL that your app handles,
    ///   OpenSwiftUI uses the URL's
    ///   [absoluteString](https://developer.apple.com/documentation/foundation/url/1779984-absolutestring).
    ///
    /// For both parameter sets, an empty set of strings never matches.
    /// Similarly, empty strings never match. Conversely, as a special case,
    /// the string that contains only an asterisk (`*`) matches anything.
    /// The modifier performs string comparisons that are case and
    /// diacritic insensitive.
    ///
    /// If you specify multiple instances of this view modifier inside a single
    /// scene, the scene uses the union of the respective `preferring` and
    /// `allowing` sets from all the modifiers.
    ///
    /// ### Handling a user activity in an open scene
    ///
    /// As an example, the following view --- which participates in Handoff
    /// through the ``View/userActivity(_:isActive:_:)`` and
    /// ``View/onContinueUserActivity(_:perform:)`` methods --- updates its
    /// `preferring` set according to the current selection. The enclosing
    /// scene prefers to handle an event for a contact that's already selected,
    /// but doesn't volunteer itself as a preferred scene when no contact is
    /// selected:
    ///
    ///     private struct ContactList: View {
    ///         var store: ContactStore
    ///         @State private var selectedContact: UUID?
    ///
    ///         var body: some View {
    ///             NavigationSplitView {
    ///                 List(store.contacts, selection: $selectedContact) { contact in
    ///                     NavigationLink(contact.name) {
    ///                         Text(contact.name)
    ///                     }
    ///                 }
    ///             } detail: {
    ///                 Text("Select a contact")
    ///             }
    ///             .handlesExternalEvents(
    ///                 preferring: selectedContact == nil
    ///                     ? []
    ///                     : [selectedContact!.uuidString],
    ///                 allowing: selectedContact == nil
    ///                     ? ["*"]
    ///                     : []
    ///             )
    ///             .onContinueUserActivity(Contact.userActivityType) { activity in
    ///                 if let identifier = activity.targetContentIdentifier {
    ///                     selectedContact = UUID(uuidString: identifier)
    ///                 }
    ///             }
    ///             .userActivity(
    ///                 Contact.userActivityType,
    ///                 isActive: selectedContact != nil
    ///             ) { activity in
    ///                 activity.title = "Contact"
    ///                 activity.targetContentIdentifier = selectedContact?.uuidString
    ///                 activity.isEligibleForHandoff = true
    ///             }
    ///         }
    ///     }
    ///
    /// The above code also updates the `allowing` set to indicate that the
    /// scene can handle any incoming event when there's no current selection,
    /// but that it can't handle any event if the view already displays a
    /// contact. The `preferring` set takes precedence in the special case
    /// where the incoming event exactly matches the currently selected contact.
    ///
    /// - Parameters:
    ///   - preferring: A set of strings that OpenSwiftUI compares against the
    ///     incoming user activity or URL to see if the view's
    ///     scene prefers to handle the external event.
    ///   - allowing: A set of strings that OpenSwiftUI compares against the
    ///     incoming user activity or URL to see if the view's
    ///     scene can handle the exernal event.
    ///
    /// - Returns: A view whose enclosing scene --- if already open ---
    ///   handles incoming external events.
    nonisolated public func handlesExternalEvents(
        preferring: Set<String>,
        allowing: Set<String>
    ) -> some View {
        transformPreference(
            SceneBridge.ActivationConditionsPreferenceKey.self
        ) { value in
            activityEnvironmentLog(
                "TransformPreference closure for activation conditions called " +
                "\(String(describing: value))"
            )
            value = .init((
                preferring: value?.preferring.union(preferring) ?? preferring,
                allowing: value?.allowing.union(allowing) ?? allowing,
            ))
            activityEnvironmentLog(
                "TransformPreference setting value for activation conditions" +
                "\(String(describing: value))"
            )
        }
    }
}

// MARK: - OpenURLOptions

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
public struct OpenURLOptions {
    #if os(iOS) || os(visionOS)
    public var uiSceneOpenURLOptions: UIScene.OpenURLOptions
    #endif
}

@_spi(Private)
@available(*, unavailable)
extension OpenURLOptions: Sendable {}

// MARK: - OpenURLContext

struct OpenURLContext {
    var url: URL
    #if os(iOS) || os(visionOS)
    var options: OpenURLOptions?
    #endif
}
#endif
