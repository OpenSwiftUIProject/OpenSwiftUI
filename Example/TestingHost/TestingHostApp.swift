//
//  TestingHostApp.swift
//  TestingHost

import SwiftUI

@main
struct TestingHostApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#if os(iOS)
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

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let vc = UIViewController()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        return true
    }
}
#endif
