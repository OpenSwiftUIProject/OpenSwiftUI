//
//  TestingHostApp.swift
//  TestingHost

// FIXME: OpenSwiftUI does not set up key window correctly
// -> use HostingExample as OpenSwiftUIUITests's host temporary to add drawHierarchyInKeyWindow support

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

@main
struct TestingHostApp: App {
    // FIXME: OpenSwiftUI does not support ApplicationDelegateAdaptor yet
    #if !OPENSWIFTUI
    #if canImport(AppKit)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #else
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    #endif

    var body: some Scene {
        WindowGroup {
            Color.red
        }
    }
}

#if canImport(AppKit)
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
