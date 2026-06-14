//
//  PerformanceTest.swift
//  OpenSwiftUI
//
//  Status: Complete

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import OpenSwiftUI_SPI

// MARK: - _PerformanceTest [6.4.41]

/// A performance test that will be executed by PPT.
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
    /// Notifies the `_BenchmarkHost` when you started a test
    ///
    /// - Parameter test: The test that was started
    public func _started(test: _PerformanceTest) {
        #if os(iOS) || os(visionOS)
        UIApplication.shared.startedTest(test.name)
        #elseif os(macOS)
        NSApplication.shared.startedTest(test.name)
        #else
        #endif
    }

    /// Notify the `_BenchmarkHost` when you finished a test
    ///
    /// - Parameter test: The test that was finished
    public func _finished(test: _PerformanceTest) {
        #if os(iOS) || os(visionOS)
        UIApplication.shared.finishedTest(test.name)
        #elseif os(macOS)
        NSApplication.shared.finishedTest(test.name, extraResults: nil)
        #else
        #endif
    }

    /// Notify the `_BenchmarkHost` when you failed a test
    ///
    /// - Parameter test: The test that failed
    public func _failed(test: _PerformanceTest) {
        #if os(iOS) || os(visionOS)
        UIApplication.shared.failedTest(test.name, withFailure: nil)
        #elseif os(macOS)
        NSApplication.shared.failedTest(test.name, withFailure: nil)
        #else
        #endif
    }
}
