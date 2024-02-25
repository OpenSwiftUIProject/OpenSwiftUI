//
//  OpenSwiftUIApplication.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: ACC2C5639A7D76F611E170E831FCA491

#if os(iOS) || os(tvOS)
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
        fatalError("init(coder:) has not been implemented")
    }
}
#else
import Foundation
#endif

func runApp(_ app: some App) -> Never {
    let graph = AppGraph(app: app)
    graph.startProfilingIfNecessary()
    graph.instantiate()
    AppGraph.shared = graph
    KitRendererCommon()
}

private func KitRendererCommon() -> Never {
    let argc = CommandLine.argc
    let argv = CommandLine.unsafeArgv

    #if canImport(Darwin)
    #if os(iOS) || os(tvOS) || os(macOS)
    let principalClassName = NSStringFromClass(OpenSwiftUIApplication.self)
    #endif
    let delegateClassName = NSStringFromClass(AppDelegate.self)
    #endif

    #if os(iOS) || os(tvOS)
    let code = UIApplicationMain(argc, argv, principalClassName, delegateClassName)
    #elseif os(watchOS)
    let code = WKApplicationMain(argc, argv, delegateClassName)
    #elseif os(macOS)
    // FIXME
    let code = NSApplicationMain(argc, argv)
    #else
    let code: Int32 = 1
    #endif
    exit(code)
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
