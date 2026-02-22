//
//  EntryPoint.swift
//  Example
//
//  Created by Kyle on 2/23/26.
//

@main
struct EntryPoint {
    static func main() {
        let runBenchmark = CommandLine.arguments.contains("benchmark")
        if runBenchmark {
            BenchmarkApp.main()
        } else {
            ExampleApp.main()
//            ObservableExampleApp.main()
//            ObservableObjectExampleApp.main()
        }
    }
}
