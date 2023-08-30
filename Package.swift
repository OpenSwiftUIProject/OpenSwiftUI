// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let isXcodeEnv = ProcessInfo.processInfo.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode"
// Xcode use clang as linker which supports "-iframework" while SwiftPM use swiftc as linker which supports "-Fsystem"
let systemFrameworkSearchFlag = isXcodeEnv ? "-iframework" : "-Fsystem"

let package = Package(
    name: "OpenSwiftUI",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "OpenSwiftUI",
            targets: ["OpenSwiftUI"]),
    ],
    targets: [
        .target(name: "AttributeGraph"),
        .target(
            name: "OpenSwiftUI",
            dependencies: ["AttributeGraph"],
            linkerSettings: [
                // TODO: Add a xcframework of all OS's system AttributeGraph binary or add OpenAttributeGraph source implementation
                // This only works for macOS build since the host OS(macOS) only have a binary slice for macOS platform.
                .unsafeFlags([systemFrameworkSearchFlag, "/System/Library/PrivateFrameworks/"]),
                .linkedFramework("AttributeGraph"),
            ]
        ),
        .testTarget(
            name: "OpenSwiftUITests",
            dependencies: ["OpenSwiftUI"]),
    ]
)
