//
//  OpenSwiftUIApplication.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by OpenSwiftUIApplication
//  ID: ACC2C5639A7D76F611E170E831FCA491 (SwiftUI?)

@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

#if os(iOS) || os(visionOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#else
import Foundation
#endif

// MARK: - runApp

func runApp(_ app: some App) -> Never {
    Update.dispatchImmediately(reason: nil) {
        let graph = AppGraph(app: app)
        graph.startProfilingIfNecessary()
        graph.instantiate()
        AppGraph.shared = graph
    }
    KitRendererCommon(AppDelegate.self)
}

// MARK: - runTestingApp [6.4.41] [iOS]

func runTestingApp<V1, V2>(rootView: V1, comparisonView: V2, didLaunch: @escaping (any TestHost, any TestHost) -> ()) -> Never where V1: View, V2: View {
    #if os(iOS) || os(visionOS)
    TestingSceneDelegate.connectCallback = { (window: UIWindow, comparisonWindow: UIWindow) in
        CoreTesting.isRunning = true
        let rootVC = UIHostingController(rootView: rootView)
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        let host = rootVC.host
        TestingAppDelegate.testHost = host
        let comparisonVC = UIHostingController(rootView: comparisonView)
        comparisonWindow.rootViewController = comparisonVC
        comparisonWindow.makeKeyAndVisible()
        comparisonWindow.isHidden = false
        comparisonWindow.isHidden = true
        let comparisonHost = comparisonVC.host
        TestingAppDelegate.comparisonHost = comparisonHost
        didLaunch(host, comparisonHost)
    }
    #endif
    KitRendererCommon(TestingAppDelegate.self)
}

// MARK: - KitRendererCommon

private func KitRendererCommon(_ delegateType: AnyObject.Type) -> Never {
    let closure = { (argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>) in
        let argc = CommandLine.argc
        #if os(iOS) || os(visionOS)
        let principalClassName = NSStringFromClass(OpenSwiftUIApplication.self)
        let delegateClassName = NSStringFromClass(delegateType)
        let code = UIApplicationMain(argc, argv, principalClassName, delegateClassName)
        #elseif os(macOS)
        let principalClassName = NSStringFromClass(OpenSwiftUIApplication.self)
        let delegateClassName = NSStringFromClass(delegateType)
        let code = NSApplicationMain(argc, argv)
        #elseif os(watchOS)
        let delegateClassName = NSStringFromClass(delegateType)
        let code = WKApplicationMain(argc, argv, delegateClassName)
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        let code = 1
        #endif
        return exit(code)
    }
    return closure(CommandLine.unsafeArgv)
}

// MARK: - App Utils

#if canImport(Darwin)
func currentAppName() -> String {
    if let name = Bundle.main.localizedValue(for: "CFBundleDisplayName") {
        return name
    } else if let name = Bundle.main.localizedValue(for: "CFBundleName") {
        return name
    } else {
        return ProcessInfo.processInfo.processName
    }
}

extension Bundle {
    fileprivate func localizedValue(for key: String) -> String? {
        if let localizedInfoDictionary,
           let value = localizedInfoDictionary[key] as? String {
            return value
        } else if let infoDictionary,
                  let value = infoDictionary[key] as? String {
            return value
        } else {
            return nil
        }
    }
}
#endif

// MARK: - OpenSwiftUIApplication [WIP]

private final class OpenSwiftUIApplication: PlatformApplication {
    @objc override init() {
        super.init()
    }
}
