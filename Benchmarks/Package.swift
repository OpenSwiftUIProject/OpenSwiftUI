// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let package = Package(
    name: "OpenSwiftUIBenchmark",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "OpenSwiftUIBenchmark", targets: ["OpenSwiftUIBenchmark"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.20.0"),
        .package(path: "../"),
    ],
    targets: [
        .executableTarget(
              name: "OpenSwiftUIBenchmark",
              dependencies: [
                  .product(name: "Benchmark", package: "package-benchmark"),
              ],
              path: "OpenSwiftUIBenchmark",
              plugins: [
                  .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
              ]
        )
    ]
)
