// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let isXcodeEnv = ProcessInfo.processInfo.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode"
// Xcode use clang as linker which supports "-iframework" while SwiftPM use swiftc as linker which supports "-Fsystem"
let systemFrameworkSearchFlag = isXcodeEnv ? "-iframework" : "-Fsystem"

// https://github.com/llvm/llvm-project/issues/48757
let clangEnumFixSetting = CSetting.unsafeFlags(["-Wno-elaborated-enum-base"], .when(platforms: [.linux]))

let openSwiftUITarget = Target.target(
    name: "OpenSwiftUI",
    dependencies: [
        "OpenSwiftUIShims",
    ],
    swiftSettings: [
        .unsafeFlags(["-enable-library-evolution"]),
    ]
)

let package = Package(
    name: "OpenSwiftUI",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)],
    products: [
        .library(name: "OpenSwiftUI", targets: ["OpenSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kyle-Ye/OpenFoundation", from: "0.0.1"),
    ],
    targets: [
        // TODO: Add SwiftGTK as an backend alternative for UIKit/AppKit on Linux and macOS
        .systemLibrary(
            name: "CGTK",
            pkgConfig: "gtk4",
            providers: [
                .brew(["gtk4"]),
                .apt(["libgtk-4-dev clang"]),
            ]
        ),
        // C Shims for OpenSwiftUI
        .target(
            name: "OpenSwiftUIShims",
            dependencies: [.product(name: "OpenFoundation", package: "OpenFoundation")]
        ),
        openSwiftUITarget,
        .testTarget(name: "OpenSwiftUITests", dependencies: ["OpenSwiftUI"]),
    ]
)

let useAG = ProcessInfo.processInfo.environment["OPENSWIFTUI_USE_AG"] != nil
if useAG {
    let targets: [Target] = [
        .binaryTarget(name: "AttributeGraph", path: "Sources/AttributeGraph.xcframework"),
        // FIXME: The binary of AG for macOS is copied from dyld shared cache and it will cause a link error when running. Use iOS Simulator to run this target as a temporary workaround
        .testTarget(
            name: "AttributeGraphTests",
            dependencies: ["AttributeGraph"]
        ),
    ]
    package.targets.append(contentsOf: targets)
    openSwiftUITarget.dependencies.append(
        "AttributeGraph"
    )
    var swiftSettings: [SwiftSetting] = (openSwiftUITarget.swiftSettings ?? [])
    swiftSettings.append(.define("OPENSWIFTUI_USE_AG"))
    openSwiftUITarget.swiftSettings = swiftSettings
} else {
    package.products.append(
        .library(name: "OpenGraph", targets: ["OpenGraph", "_OpenGraph"])
    )
    let targets: [Target] = [
        // FIXME: Merge into one target
        // OpenGraph is a C++ & Swift mix target.
        // The SwiftPM support for such usage is still in progress.
        .target(
            name: "_OpenGraph",
            dependencies: [.product(name: "OpenFoundation", package: "OpenFoundation")],
            cSettings: [clangEnumFixSetting]
        ),
        .target(
            name: "OpenGraph",
            dependencies: ["_OpenGraph"],
            cSettings: [clangEnumFixSetting]
        ),
        .testTarget(
            name: "OpenGraphTests",
            dependencies: ["OpenGraph"]
        ),
    ]
    package.targets.append(contentsOf: targets)
    openSwiftUITarget.dependencies.append(
        "OpenGraph"
    )
}

let useCombine = ProcessInfo.processInfo.environment["OPENSWIFTUI_USE_COMBINE"] != nil
if useCombine {
    var swiftSettings: [SwiftSetting] = (openSwiftUITarget.swiftSettings ?? [])
    swiftSettings.append(.define("OPENSWIFTUI_USE_COMBINE"))
    openSwiftUITarget.swiftSettings = swiftSettings
} else {
    package.dependencies.append(
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.14.0")
    )
    openSwiftUITarget.dependencies.append(
        .product(name: "OpenCombine", package: "OpenCombine")
    )
}
