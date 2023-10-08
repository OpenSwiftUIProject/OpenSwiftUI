//
//  OpenSwiftUIApplication.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: ACC2C5639A7D76F611E170E831FCA491

#if os(iOS)
import UIKit
fileprivate final class OpenSwiftUIApplicationp: UIApplication {
    @objc override init() {
        super.init()
    }
}

#elseif os(macOS)
import AppKit
private final class OpenSwiftUIApplicationp: NSApplication {
    @objc override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif

func runApp(_ app: some App) -> Never {
    let graph = AppGraph(app: app)
    graph.startProfilingIfNecessary()
//    graph.instantiate()
    AppGraph.shared = graph
    KitRendererCommon()
}

private func KitRendererCommon() -> Never {
    let argc = CommandLine.argc
    let argv = CommandLine.unsafeArgv
    let principalClassName = NSStringFromClass(OpenSwiftUIApplicationp.self)
    let delegateClassName = NSStringFromClass(AppDelegate.self)
    #if os(iOS)
    let code = UIApplicationMain(argc, argv, principalClassName, delegateClassName)
    #elseif os(macOS)
    // FIXME
    let code = NSApplicationMain(argc, argv)
    #endif
    exit(code)
}

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
