//
//  TestApp+Test.swift
//  OpenSwiftUI
//
//  Status: Complete

@_spi(Testing)
public import OpenSwiftUICore
import Foundation

// MARK: - TestApp + Test [6.4.41]

extension _TestApp {
    public func runBenchmarks(_ benchmarks: [any _Benchmark]) -> Never {
        runTestingApp(
            rootView: _TestApp.RootView().testID(_TestApp.rootViewIdentifier),
            comparisonView: EmptyView()
        ) { host, comparisonHost in
            DispatchQueue.main.async {
                 performBenchmarks(benchmarks, with: host)
            }
        }
    }

    func performBenchmarks(_ benchmarks: [any _Benchmark], with host: any TestHost) {
        _TestApp.host = host
        host.environmentOverride = _TestApp.defaultEnvironment
        #if canImport(Darwin)
        CFRunLoopPerformBlock(
            CFRunLoopGetCurrent(),
            CFRunLoopMode.commonModes.rawValue
        ) {
            var results: [(_Benchmark, [Double])] = []
            for benchmark in benchmarks {
                benchmark.setUpTest()
                results.append((benchmark, benchmark.measure(host: host)))
                if enableProfiler,
                   let rendererhost = host as? ViewRendererHost {
                    rendererhost.archiveJSON(name: "\(type(of: benchmark))")
                    rendererhost.resetProfile()
                }
                benchmark.tearDownTest()
            }
            log(results)
            exit(0)
        }
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }
}

extension _TestApp {
    public func runPerformanceTests(_ tests: [any _PerformanceTest]) -> Never {
        TestingAppDelegate.performanceTests = tests
        runTestingApp(
            rootView: _TestApp.RootView().testID(_TestApp.rootViewIdentifier),
            comparisonView: EmptyView()
        ) { host, comparisonHost in
            _TestApp.host = host
        }
    }
}

