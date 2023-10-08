// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let isXcodeEnv = ProcessInfo.processInfo.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode"
// Xcode use clang as linker which supports "-iframework" while SwiftPM use swiftc as linker which supports "-Fsystem"
let systemFrameworkSearchFlag = isXcodeEnv ? "-iframework" : "-Fsystem"

let package = Package(
    name: "OpenSwiftUI",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)],
    products: [
        .library(name: "OpenGraph", targets: ["OpenGraph", "_OpenGraph"]),
        .library(name: "OpenSwiftUI", targets: ["OpenSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.14.0"),
    ],
    targets: [
        // TODO: Add a xcframework of all Apple OS's system AttributeGraph binary or add OpenAttributeGraph source implementation
        // .binaryTarget(name: "AttributeGraph", path: "Sources/AttributeGraph.xcframework"),
        // FIXME: Merge into one target
        // OpenGraph is a C++ & Swift mix target.
        // The SwiftPM support for such usage is still in progress.
        .target(name: "_OpenGraph"),
        .target(name: "OpenGraph", dependencies: ["_OpenGraph"]),
        // TODO: Add SwiftGTK as an backend alternative for UIKit/AppKit on Linux and macOS
        .systemLibrary(
            name: "CGTK",
            pkgConfig: "gtk4",
            providers: [
                .brew(["gtk4"]),
                .apt(["libgtk-4-dev clang"]),
            ]
        ),
        .target(name: "OpenSwiftUIShims"),
        .target(
            name: "OpenSwiftUI",
            dependencies: [
                "OpenSwiftUIShims",
                // "AttributeGraph",
                "OpenGraph",
                .product(name: "OpenCombine", package: "OpenCombine")
            ]
        ),
        .testTarget(
            name: "OpenSwiftUITests",
            dependencies: ["OpenSwiftUI"]),
    ]
)
