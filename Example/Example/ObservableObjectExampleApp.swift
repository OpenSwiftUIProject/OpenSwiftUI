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
    #if canImport(UIKit)
    @EnvironmentObject private var sceneDelegate: SceneDelegate
    #endif

    var body: some View {
        ContentView()
            .onAppear {
                print("appDelegate instance: \(appDelegate)")
                #if canImport(UIKit)
                print("sceneDelegate instance: \(sceneDelegate)")
                #endif
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

    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
                                name: nil,
                                sessionRole: connectingSceneSession.role)
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
    }
}

private class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate will connect to scene: \(scene), session: \(session), options: \(connectionOptions)")
    }
}
#endif
