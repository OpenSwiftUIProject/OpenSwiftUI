//
//  TestingSceneDelegate.swift
//  OpenSwiftUI
//
//  Status: Complete for iOS

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - TestingAppDelegate [6.4.41] [iOS]

class TestingAppDelegate: DelegateBaseClass, PlatformApplicationDelegate {
    static var testHost: (PlatformView & TestHost)?

    static var comparisonHost: (PlatformView & TestHost)?

    static var performanceTests: [_PerformanceTest]?

    static var application: PlatformApplication?

    #if os(iOS) || os(visionOS)
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = TestingSceneDelegate.self
        return configuration
    }

    // WIP
    @objc
    func application(_ application: UIApplication, runTest name: String, options: [AnyHashable: Any]) -> Bool {
        guard let performanceTests = TestingAppDelegate.performanceTests,
              let performanceTest = performanceTests.first(where: { $0.name == name }),
              let host = TestingAppDelegate.testHost else {
            return false
        }
        performanceTest.runTest(host: host, options: options)
        return true
    }
    #endif
}
