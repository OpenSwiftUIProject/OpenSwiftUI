//
//  TestApp.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP

public import OpenSwiftUICore
import Foundation

extension _TestApp {
    public func run() -> Never {
        let semanticsIndex = CommandLine.arguments.lastIndex(of: "--semantics")
        if let semanticsIndex,
           semanticsIndex + 1 != CommandLine.arguments.count {
            setSemantics(CommandLine.arguments[semanticsIndex + 1])
        } else {
            setSemantics("lastest")
        }
        #if canImport(Darwin)
        CFPreferencesSetAppValue("AppleLanguages" as NSString, ["en"] as NSArray, kCFPreferencesCurrentApplication)
        // CTClearFontFallbacksCache()
        #endif
        Color.Resolved.legacyInterpolation = true
        let rootView = RootView()
        preconditionFailure("TODO")
    }
}

extension _TestApp {
    public func runBenchmarks(_ benchmarks: [_Benchmark]) -> Never {
        let _ = RootView()
        preconditionFailure("TODO")
    }
}

extension _TestApp {
    public func runPerformanceTests(_ tests: [_PerformanceTest]) -> Never {
        preconditionFailure("TODO")
    }
}
