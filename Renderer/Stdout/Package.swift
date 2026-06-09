// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "StdoutRenderer",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "ExampleApp", targets: ["ExampleApp"]),
    ],
    dependencies: [
        .package(path: "../.."),
    ],
    targets: [
        .executableTarget(
            name: "ExampleApp",
            dependencies: [
                .product(name: "OpenSwiftUI", package: "OpenSwiftUI"),
            ],
            path: "ExampleApp"
        ),
    ]
)
