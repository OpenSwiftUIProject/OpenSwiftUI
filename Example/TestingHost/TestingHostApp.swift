//
//  TestingHostApp.swift
//  TestingHost

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#else
import UIKit
#endif

@main
struct TestingHostApp: App {
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #else
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            Color.red
        }
    }
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
class AppDelegate: NSResponder, NSApplicationDelegate {
    var window: NSWindow?

    func applicationWillFinishLaunching(_ notification: Notification) {
        return
    }
}
#else
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if targetEnvironment(simulator)
        // Disable hardware keyboards
        let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
        UITextInputMode.activeInputModes
            .filter { $0.responds(to: setHardwareLayout) }
            .forEach { $0.perform(setHardwareLayout, with: nil) }
        #endif
        return true
    }
}
#endif
