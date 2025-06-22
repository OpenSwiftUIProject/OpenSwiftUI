//
//  AppDelegate.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: 4475FD12FD59DEBA453321BD91F6EA04

#if os(iOS)
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

class AppDelegate: DelegateBaseClass {
    #if os(iOS)
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
    #endif
}
