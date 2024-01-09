//
//  _PerformanceTest.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/1/9.
//  Lastest Version: iOS 15.5
//  Status: WIP

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

internal import OpenSwiftUIShims

public protocol _PerformanceTest: _Test {
    var name: String { get }
    func runTest(host: _BenchmarkHost, options: [AnyHashable: Any])
}

extension __App {
    public static func _registerPerformanceTests(_ tests: [_PerformanceTest]) {
        TestingAppDelegate.performanceTests = tests
    }
}

extension _TestApp {
    public func runPerformanceTests(_ tests: [_PerformanceTest]) -> Never {
        fatalError("TODO")
    }
}

extension _BenchmarkHost {
    public func _started(test: _PerformanceTest) {
        #if os(iOS)
        UIApplication.shared.startedTest(test.name)
        #else
        fatalError("TODO")
        #endif
    }

    public func _finished(test: _PerformanceTest) {
        #if os(iOS)
        UIApplication.shared.finishedTest(test.name)
        #else
        fatalError("TODO")
        #endif
    }

    public func _failed(test: _PerformanceTest) {
        #if os(iOS)
        UIApplication.shared.failedTest(test.name, withFailure: nil)
        #else
        fatalError("TODO")
        #endif
    }
}
