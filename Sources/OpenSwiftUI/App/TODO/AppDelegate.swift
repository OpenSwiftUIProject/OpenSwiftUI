//
//  AppDelegate.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 4475FD12FD59DEBA453321BD91F6EA04

#if os(iOS)
import UIKit
class AppDelegate: UIResponder {
    var fallbackDelegate: UIApplicationDelegate?
    
    // WIP
    @objc override init() {
        fallbackDelegate = nil
        super.init()
        guard let delegateBox = AppGraph.delegateBox else {
            return
        }
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        let canDelegateRespond = fallbackDelegate?.responds(to: aSelector) ?? false
        let canSelfRespond = AppDelegate.instancesRespond(to: aSelector)
        return canDelegateRespond || canSelfRespond
    }
}
#elseif os(macOS)
import AppKit
class AppDelegate {
}
#endif
