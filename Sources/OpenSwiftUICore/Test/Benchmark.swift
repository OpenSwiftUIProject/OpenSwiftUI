//
//  Benchmark.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 3E629D505F0A70F29ACFC010AA42C6E0 (SwiftUI)
//  ID: 5BCCF82F8606CD0B3127FDEEA7C13601 (SwiftUICore)

public import Foundation
#if canImport(QuartzCore)
import QuartzCore
#endif

public protocol _BenchmarkHost: AnyObject {
    func _renderForTest(interval: Double)
    func _renderAsyncForTest(interval: Double) -> Bool
    func _performScrollTest(startOffset: CGFloat, iterations: Int, delta: CGFloat, length: CGFloat, completion: (() -> Void)?)
}

public protocol _Benchmark: _Test {
    func measure(host: _BenchmarkHost) -> [Double]
}

package var enableProfiler = EnvironmentHelper.bool(for: "OPENSWIFTUI_PROFILE_BENCHMARKS")

package var enableTracer = EnvironmentHelper.bool(for: "OPENSWIFTUI_TRACE_BENCHMARKS")

extension _BenchmarkHost {
    public func _renderAsyncForTest(interval _: Double) -> Bool {
        false
    }

    public func _performScrollTest(startOffset _: CGFloat, iterations _: Int, delta _: CGFloat, length _: CGFloat, completion _: (() -> Void)?) {}

    public func measureAction(action: () -> Void) -> Double {
        // WIP: trace support
        #if canImport(QuartzCore)
        let begin = CACurrentMediaTime()
        if enableProfiler,
           let renderHost = self as? ViewRendererHost {
            renderHost.startProfiling()
        }
        action()
        let end = CACurrentMediaTime()
        if enableProfiler,
           let renderHost = self as? ViewRendererHost {
            renderHost.stopProfiling()
        }
        return end - begin
        #else
        preconditionFailure("Unsupported Platfrom")
        #endif
    }

    public func measureRender(interval: Double = 1.0 / 60.0) -> Double {
        measureAction {
            _renderForTest(interval: interval)
        }
    }

    public func measureRenders(seconds: Double) -> [Double] {
        measureRenders(duration: seconds)
    }

    public func measureRenders(duration: Double) -> [Double] {
        let minutes = duration / 60.0
        let value = Int(minutes.rounded(.towardZero)) + 1
        let count = max(value, 0)
        var results: [Double] = []
        for _ in 0 ..< count {
            results.append(measureRender())
        }
        return results
    }
}

package func summarize(_ measurements: [(any _Benchmark, [Double])]) -> String {
    preconditionFailure("TODO")
}

package func write(_ measurements: [(any _Benchmark, [Double])], to path: String) throws {
    preconditionFailure("TODO")
}

package func log(_ measurements: [(any _Benchmark, [Double])]) {
    preconditionFailure("TODO")
}
