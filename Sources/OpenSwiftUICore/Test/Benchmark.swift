//
//  Benchmark.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 3E629D505F0A70F29ACFC010AA42C6E0 (SwiftUI)
//  ID: 5BCCF82F8606CD0B3127FDEEA7C13601 (SwiftUICore)

public import Foundation
#if canImport(QuartzCore)
import QuartzCore
#endif
import OpenGraphShims

// MARK: - Benchmark [6.4.41]

@available(OpenSwiftUI_v1_0, *)
public protocol _BenchmarkHost: AnyObject {
    func _renderForTest(interval: Double)

    @available(OpenSwiftUI_v3_0, *)
    func _renderAsyncForTest(interval: Double) -> Bool

    func _performScrollTest(startOffset: CGFloat, iterations: Int, delta: CGFloat, length: CGFloat, completion: (() -> Void)?)
}

@available(OpenSwiftUI_v1_0, *)
public protocol _Benchmark: _Test {
    func measure(host: _BenchmarkHost) -> [Double]
}

package var enableProfiler = EnvironmentHelper.bool(for: "OPENSWIFTUI_PROFILE_BENCHMARKS")

package var enableTracer = EnvironmentHelper.bool(for: "OPENSWIFTUI_TRACE_BENCHMARKS")

@available(OpenSwiftUI_v1_0, *)
extension _BenchmarkHost {
    @available(OpenSwiftUI_v1_0, *)
    public func _renderAsyncForTest(interval _: Double) -> Bool {
        false
    }

    public func _performScrollTest(startOffset _: CGFloat, iterations _: Int, delta _: CGFloat, length _: CGFloat, completion _: (() -> Void)?) {}

    public func measureAction(action: () -> Void) -> Double {
        let begin = Time.systemUptime
        if enableTracer {
            Graph.startTracing(options: nil)
        } else if enableProfiler {
            (self as? ViewRendererHost)?.startProfiling()
        }
        action()
        let end = Time.systemUptime
        if enableTracer {
            Graph.stopTracing()
        } else if enableProfiler {
            (self as? ViewRendererHost)?.stopProfiling()
        }
        return end - begin
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
    let benchmarkData = measurements.map { (String(describing: type(of: $0.0)), $0.1) }
    let maxNameLength = benchmarkData.map { $0.0.count }.max() ?? 0
    let results: [String] = benchmarkData.map { (name, values) in
        let total = values.reduce(0, +)
        let padding = maxNameLength - name.count + 1
        let paddingString = String(repeating: " ", count: padding)
        let milliseconds = total * 1000.0
        return "\(name):\(paddingString)\(String(format: "%.3f ms", milliseconds))"
    }
    return results.joined(separator: "\n")
}

package func write(_ measurements: [(any _Benchmark, [Double])], to path: String) throws {
    let dictionary = Dictionary(uniqueKeysWithValues: measurements.map { (String(describing: $0), $1) })
    let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
    let manager = FileManager.default
    let directory = (path as NSString).deletingLastPathComponent
    try manager.createDirectory(atPath: directory, withIntermediateDirectories: true)
    try data.write(to: URL(fileURLWithPath: path))
}

package func log(_ measurements: [(any _Benchmark, [Double])]) {
    print(summarize(measurements))
    let path: String
    if CommandLine.arguments.count < 2 {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        path = "/tmp/org.OpenSwiftUIProject.OpenSwiftUI/Benchmarks/\(formatter.string(from: Date())).json"
    } else {
        path = CommandLine.arguments[1]
    }
    print(path)
    do {
        try write(measurements, to: path)
    } catch {
        Log.internalError(error.localizedDescription)
    }
}
