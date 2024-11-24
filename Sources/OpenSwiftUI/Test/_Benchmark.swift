public protocol _Benchmark: _Test {
    func measure(host: _BenchmarkHost) -> [Double]
}

extension _TestApp {
    public func runBenchmarks(_ benchmarks: [_Benchmark]) -> Never {
        let _ = RootView()
        preconditionFailure("TODO")
    }
}
