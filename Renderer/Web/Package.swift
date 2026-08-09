// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "WebRenderer",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "ExampleApp", targets: ["ExampleApp"]),
    ],
    dependencies: [
        .package(path: "../.."),
        .package(
            url: "https://github.com/swiftwasm/JavaScriptKit.git",
            exact: "0.57.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "ExampleApp",
            dependencies: [
                .product(name: "OpenSwiftUI", package: "OpenSwiftUI"),
                .product(name: "JavaScriptKit", package: "JavaScriptKit"),
                .product(name: "JavaScriptEventLoop", package: "JavaScriptKit"),
            ],
            path: "ExampleApp",
            cSettings: [
                .define("_WASI_EMULATED_SIGNAL", .when(platforms: [.wasi])),
                .define("_WASI_EMULATED_MMAN", .when(platforms: [.wasi])),
            ],
            linkerSettings: [
                .linkedLibrary("wasi-emulated-signal", .when(platforms: [.wasi])),
                .linkedLibrary("wasi-emulated-mman", .when(platforms: [.wasi])),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
