//
//  ObservableExampleApp.swift
//  Example
//
//  Created by Kyle on 2/23/26.
//

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import OpenObservation

struct ObservableExampleApp: App {
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #else
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            ContentViewWrapper()
        }
    }
}

private struct ContentViewWrapper: View {
    @Environment(AppDelegate.self) private var appDelegate

    var body: some View {
        ContentView()
            .onAppear {
                print("appDelegate instance: \(appDelegate)")
            }
    }
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
// Avoid AppKit export Foundation and Foundation export Observation issue.
// Then Observation's Observable macro will conflict with OpenObservation's Observable macro.
import class AppKit.NSResponder
import class AppKit.NSWindow
import protocol AppKit.NSApplicationDelegate
import struct Foundation.Notification
@Observable
private class AppDelegate: NSResponder, NSApplicationDelegate {
    var window: NSWindow?

    func applicationWillFinishLaunching(_ notification: Notification) {
        return
    }
}
#else
// Avoid UIKit export Foundation and Foundation export Observation issue.
// Then Observation's Observable macro will conflict with OpenObservation's Observable macro.
import class UIKit.UIApplication
import class UIKit.UIResponder
import class UIKit.UIWindow
import protocol UIKit.UIApplicationDelegate
@Observable
private class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}
#endif
