//
//  UIKitAppDelegate.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: WIP
//  ID: 4475FD12FD59DEBA453321BD91F6EA04 (SwiftUI)

#if os(iOS) || os(visionOS)
import UIKit
typealias DelegateBaseClass = UIResponder
typealias PlatformApplication = UIApplication
typealias PlatformApplicationDelegate = UIApplicationDelegate
#elseif os(macOS)
import AppKit
typealias DelegateBaseClass = NSResponder
typealias PlatformApplication = NSApplication
typealias PlatformApplicationDelegate = NSApplicationDelegate
#else
import Foundation
// FIXME: Temporarily use NSObject as a placeholder
typealias DelegateBaseClass = NSObject
typealias PlatformApplication = NSObject
typealias PlatformApplicationDelegate = AnyObject
#endif

class AppDelegate: DelegateBaseClass, PlatformApplicationDelegate {
    #if os(iOS) || os(visionOS)
    var fallbackDelegate: UIApplicationDelegate?
    
    // WIP
    @objc override init() {
        fallbackDelegate = nil
        super.init()
        guard let _ = AppGraph.delegateBox else {
            return
        }
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        let canDelegateRespond = fallbackDelegate?.responds(to: aSelector) ?? false
        let canSelfRespond = AppDelegate.instancesRespond(to: aSelector)
        return canDelegateRespond || canSelfRespond
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // TODO
        return true
    }

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        let items: [SceneList.Item]? = Update.ensure {
//            guard let appGraph = AppGraph.shared else {
//                return nil
//            }
//            return appGraph.rootSceneList ?? []
//        }
//
//    }
    #elseif os(macOS)
    init(appGraph: AppGraph) {
        _openSwiftUIUnimplementedFailure()
    }

    required init?(coder: NSCoder) {
        _openSwiftUIUnimplementedFailure()
    }
    #endif
}
