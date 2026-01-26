//
//  SceneBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
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
import OpenSwiftUICore

// MARK: - UserActivityTrackingInfo

var _defaultSwiftUIActivityEnvironmentLoggingEnabled = false

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
        if _defaultSwiftUIActivityEnvironmentLoggingEnabled {
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
            if _defaultSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log("Mismatched UserActivity in tracking info, skipping update.")
            }
            return
        }
        guard let sceneBridge else { return }
        let failedIDs = handlers.compactMap { identity, handler in
            if _defaultSwiftUIActivityEnvironmentLoggingEnabled {
                Log.log("Invoking handler for \(identity)")
            }
            return handler(userActivity) ? nil : identity
        }
        for id in failedIDs {
            handlers[id] = nil
        }
        if handlers.isEmpty {
            sceneBridge.userActivityTrackingInfo = nil
            _ = sceneBridge.publishEvent(
                event: sceneBridge.userActivityTrackingInfo as Any,
                type: UserActivityTrackingInfo?.self,
                identifier: "UserActivityTrackingInfo"
            )
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
            _ = sceneBridge.publishEvent(
                event: sceneBridge.userActivityTrackingInfo as Any,
                type: UserActivityTrackingInfo?.self,
                identifier: "UserActivityTrackingInfo"
            )
        }
        userActivity.needsSave = false
        if _defaultSwiftUIActivityEnvironmentLoggingEnabled {
            Log.log(
                "updated user activity \(String(describing: userActivity.title)) "
                + "with userInfo \(String(describing: userActivity.userInfo))"
            )
        }
    }
}

class SceneBridge {}

#endif

