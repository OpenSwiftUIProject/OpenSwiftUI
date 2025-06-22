//
//  PerformanceTest.swift
//  OpenSwiftUI
//
//  Status: Complete

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import OpenSwiftUI_SPI

// MARK: - _PerformanceTest [6.4.41]

@available(OpenSwiftUI_v1_0, *)
public protocol _PerformanceTest: _Test {
    var name: String { get }
    func runTest(host: any _BenchmarkHost, options: [AnyHashable: Any])
}

@available(OpenSwiftUI_v1_0, *)
extension __App {
    public static func _registerPerformanceTests(_ tests: [_PerformanceTest]) {
        TestingAppDelegate.performanceTests = tests
    }
}

@available(OpenSwiftUI_v1_0, *)
extension _BenchmarkHost {
    public func _started(test: _PerformanceTest) {
        #if os(iOS)
        UIApplication.shared.startedTest(test.name)
        #elseif os(macOS)
        NSApplication.shared.startedTest(test.name)
        #else
        #endif
    }

    public func _finished(test: _PerformanceTest) {
        #if os(iOS)
        UIApplication.shared.finishedTest(test.name)
        #elseif os(macOS)
        NSApplication.shared.finishedTest(test.name)
        #else
        #endif
    }

    public func _failed(test: _PerformanceTest) {
        #if os(iOS)
        UIApplication.shared.failedTest(test.name, withFailure: nil)
        #elseif os(macOS)
        NSApplication.shared.failedTest(test.name, withFailure: nil)
        #else
        #endif
    }
}
