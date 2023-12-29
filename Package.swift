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
        "CoreServices",
        "UIKitCore",
    ],
    swiftSettings: [
        .enableExperimentalFeature("AccessLevelOnImport"),
        .define("OPENSWIFTUI_SUPPRESS_DEPRECATED_WARNINGS"),
    ],
    linkerSettings: [
        .unsafeFlags(
            [systemFrameworkSearchFlag, "/System/Library/PrivateFrameworks/"],
            .when(platforms: [.iOS], configuration: .debug)
        ),
        .linkedFramework(
            "CoreServices",
            .when(platforms: [.iOS], configuration: .debug)
        ),
    ]
)
let openSwiftUITestTarget = Target.testTarget(
    name: "OpenSwiftUITests",
    dependencies: [
        "OpenSwiftUI",
    ],
    exclude: ["README.md"]
)
let openSwiftUICompatibilityTestTarget = Target.testTarget(
    name: "OpenSwiftUICompatibilityTests",
    exclude: ["README.md"]
)

let package = Package(
    name: "OpenSwiftUI",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "OpenSwiftUI", targets: ["OpenSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenSwiftUIProject/OpenFoundation", from: "0.0.1"),
        .package(url: "https://github.com/OpenSwiftUIProject/OpenGraph", from: "0.0.1"),
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
        .target(name: "CoreServices", path: "PrivateFrameworks/CoreServices"),
        .target(name: "UIKitCore", path: "PrivateFrameworks/UIKitCore"),
        openSwiftUITarget,
        openSwiftUITestTarget,
        openSwiftUICompatibilityTestTarget,
    ]
)

func envEnable(_ key: String, default defaultValue: Bool = false) -> Bool {
    guard let value = ProcessInfo.processInfo.environment[key] else {
        return defaultValue
    }
    if value == "1" {
        return true
    } else if value == "0" {
        return false
    } else {
        return defaultValue
    }
}

#if os(macOS)
let attributeGraphCondition = envEnable("OPENSWIFTUI_ATTRIBUTEGRAPH", default: true)
#else
let attributeGraphCondition = envEnable("OPENSWIFTUI_ATTRIBUTEGRAPH")
#endif
if attributeGraphCondition {
    openSwiftUITarget.dependencies.append(
        .product(name: "AttributeGraph", package: "OpenGraph")
    )
    var swiftSettings: [SwiftSetting] = (openSwiftUITarget.swiftSettings ?? [])
    swiftSettings.append(.define("OPENSWIFTUI_ATTRIBUTEGRAPH"))
    openSwiftUITarget.swiftSettings = swiftSettings
} else {
    openSwiftUITarget.dependencies.append(
        .product(name: "OpenGraph", package: "OpenGraph")
    )
}

#if os(macOS)
let openCombineCondition = envEnable("OPENSWIFTUI_OPENCOMBINE")
#else
let openCombineCondition = envEnable("OPENSWIFTUI_OPENCOMBINE", default: true)
#endif
if openCombineCondition {
    package.dependencies.append(
        .package(url: "https://github.com/OpenSwiftUIProject/OpenCombine.git", from: "0.15.0")
    )
    openSwiftUITarget.dependencies.append(
        .product(name: "OpenCombine", package: "OpenCombine")
    )
    var swiftSettings: [SwiftSetting] = (openSwiftUITarget.swiftSettings ?? [])
    swiftSettings.append(.define("OPENSWIFTUI_OPENCOMBINE"))
    openSwiftUITarget.swiftSettings = swiftSettings
}

#if os(macOS)
let swiftLogCondition = envEnable("OPENSWIFTUI_SWIFT_LOG")
#else
let swiftLogCondition = envEnable("OPENSWIFTUI_SWIFT_LOG", default: true)
#endif
if swiftLogCondition {
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-log", from: "1.5.3")
    )
    openSwiftUITarget.dependencies.append(
        .product(name: "Logging", package: "swift-log")
    )
    var swiftSettings: [SwiftSetting] = (openSwiftUITarget.swiftSettings ?? [])
    swiftSettings.append(.define("OPENSWIFTUI_SWIFT_LOG"))
    openSwiftUITarget.swiftSettings = swiftSettings
}

// Remove the check when swift-testing reaches 1.0.0
let swiftTestingCondition = envEnable("OPENSWIFTUI_SWIFT_TESTING")
if swiftTestingCondition {
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-testing", from: "0.2.0")
    )
    openSwiftUITestTarget.dependencies.append(
        .product(name: "Testing", package: "swift-testing")
    )
    var swiftSettings: [SwiftSetting] = (openSwiftUITestTarget.swiftSettings ?? [])
    swiftSettings.append(.define("OPENSWIFTUI_SWIFT_TESTING"))
    openSwiftUITestTarget.swiftSettings = swiftSettings
}

let compatibilityTestCondition = envEnable("OPENSWIFTUI_COMPATIBILITY_TEST")
if compatibilityTestCondition {
    var swiftSettings: [SwiftSetting] = (openSwiftUICompatibilityTestTarget.swiftSettings ?? [])
    swiftSettings.append(.define("OPENSWIFTUI_COMPATIBILITY_TEST"))
    openSwiftUICompatibilityTestTarget.swiftSettings = swiftSettings
} else {
    openSwiftUICompatibilityTestTarget.dependencies.append("OpenSwiftUI")
}
