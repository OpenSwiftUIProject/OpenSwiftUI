//
//  OpenSwiftUIApplication.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: ACC2C5639A7D76F611E170E831FCA491

@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

#if os(iOS) || os(visionOS) || os(tvOS)
import UIKit
private final class OpenSwiftUIApplication: UIApplication {
    @objc override init() {
        super.init()
    }
}
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
private final class OpenSwiftUIApplication: NSApplication {
    @objc override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
}
#else
import Foundation
#endif

func runApp(_ app: some App) -> Never {
//    let graph = AppGraph(app: app)
//    graph.startProfilingIfNecessary()
//    graph.instantiate()
//    AppGraph.shared = graph
    Update.ensure {
        KitRendererCommon(AppDelegate.self)
    }
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


private func KitRendererCommon(_ delegateType: AnyObject.Type) -> Never {
    let closure = { (argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>) in
        let argc = CommandLine.argc
        #if canImport(Darwin)
        #if os(iOS) || os(visionOS) || os(tvOS) || os(macOS)
        let principalClassName = NSStringFromClass(OpenSwiftUIApplication.self)
        #endif
        let delegateClassName = NSStringFromClass(delegateType)
        #endif

        #if os(iOS) || os(visionOS) || os(tvOS)
        let code = UIApplicationMain(argc, argv, principalClassName, delegateClassName)
        #elseif os(watchOS)
        let code = WKApplicationMain(argc, argv, delegateClassName)
        #elseif os(macOS)
        // FIXME
        let code = NSApplicationMain(argc, argv)
        #else
        let code: Int32 = 1
        #endif
        return exit(code)
    }
    return closure(CommandLine.unsafeArgv)
}

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
    func localizedValue(for key: String) -> String? {
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
