//
//  AppKitApp.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID:  (SwiftUI?)

#if os(macOS)
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import AppKit

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
    // FIXME
    KitRendererCommon(TestingAppDelegate.self)
}

// MARK: - KitRendererCommon

private func KitRendererCommon(_ delegateType: AnyObject.Type) -> Never {
    let closure = { (argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>) in
        let argc = CommandLine.argc
        // FIXME
        let principalClassName = NSStringFromClass(OpenSwiftUIApplication.self)
        let delegateClassName = NSStringFromClass(delegateType)
        let code = NSApplicationMain(argc, argv)
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

// MARK: - OpenSwiftUIApplication [WIP]

private final class OpenSwiftUIApplication: PlatformApplication {
    @objc override init() {
        super.init()
    }
}
#endif
