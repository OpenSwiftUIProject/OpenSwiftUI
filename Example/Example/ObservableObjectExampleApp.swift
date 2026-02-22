//
//  ObservableObjectExampleApp.swift
//  Example
//
//  Created by Kyle on 2/23/26.
//

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif

struct ObservableObjectExampleApp: App {
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #else
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            ContentViewWrapper()
        }
    }
}

private struct ContentViewWrapper: View {
    @EnvironmentObject private var appDelegate: AppDelegate

    var body: some View {
        ContentView()
            .onAppear {
                print("appDelegate instance: \(appDelegate)")
            }
    }
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
private class AppDelegate: NSResponder, NSApplicationDelegate, ObservableObject {
    var window: NSWindow?

    func applicationWillFinishLaunching(_ notification: Notification) {
        return
    }
}
#else
import UIKit
private class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}
#endif
