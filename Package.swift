// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenSwiftUI",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "OpenSwiftUI",
            targets: ["OpenSwiftUI"]),
    ],
    targets: [
        .target(
            name: "OpenSwiftUI"),
        .testTarget(
            name: "OpenSwiftUITests",
            dependencies: ["OpenSwiftUI"]),
    ]
)
