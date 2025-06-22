//
//  ExampleApp.swift
//  Example
//
//  Created by Kyle on 2023/11/9.
//

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

@main
struct EntryPoint {
    static func main() {
        let runBenchmark = CommandLine.arguments.contains("benchmark")
        if runBenchmark {
            BenchmarkApp.main()
        } else {
            ExampleApp.main()
        }
    }
}

struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
