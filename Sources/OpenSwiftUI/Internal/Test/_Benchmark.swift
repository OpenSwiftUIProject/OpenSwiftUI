public protocol _Benchmark: _Test {
    func measure(host: _BenchmarkHost) -> [Double]
}
