//
//  UIKitApp.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by OpenSwiftUIApplication
//  ID: ACC2C5639A7D76F611E170E831FCA491 (SwiftUI?)

#if os(iOS) || os(visionOS)
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore
import UIKit

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

// MARK: - runTestingApp [6.4.1]

func runTestingApp<V1, V2>(rootView: V1, comparisonView: V2, didLaunch: @escaping (any TestHost, any TestHost) -> ()) -> Never where V1: View, V2: View {
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

// MARK: - OpenSwiftUIApplication

private final class OpenSwiftUIApplication: PlatformApplication {
    @objc override init() {
        super.init()
    }

    override func _extendLaunchTest() -> String? {
        guard let graph = AppGraph.shared else {
            return nil
        }
        return Update.ensure {
            graph.preferenceValue(ExtendedLaunchTestNameKey.self)
        }
    }

    override func _supportsPrintCommand() -> Bool {
        _openSwiftUIUnimplementedFailure()
    }
}


// FIXME
private struct ExtendedLaunchTestNameKey: HostPreferenceKey {
    typealias Value = String?

    static func reduce(value: inout String?, nextValue: () -> String?) {
    }
}
#endif
