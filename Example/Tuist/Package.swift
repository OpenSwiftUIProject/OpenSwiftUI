// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ExampleDependencies",
    dependencies: [
        .package(path: "../../"),
        .package(path: "../../../OpenAttributeGraph"),
        .package(path: "../../../OpenRenderBox"),
        .package(path: "../../../DarwinPrivateFrameworks"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0"),
        .package(url: "https://github.com/OpenSwiftUIProject/equatable.git", branch: "main"),
        .package(url: "https://github.com/OpenSwiftUIProject/SymbolLocator.git", from: "0.2.0"),
        .package(url: "https://github.com/OpenSwiftUIProject/swift-snapshot-testing", exact: "1.18.9-osui"),
    ]
)

#if TUIST
import ProjectDescription

let examplePackageDestinations: Destinations = [.iPhone, .iPad, .mac, .appleVision]
let openSwiftUIPackageDebugSettings: SettingsDictionary = [
    "SWIFT_COMPILATION_MODE": "singlefile",
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
]
let openSwiftUIPackageReleaseSettings: SettingsDictionary = [
    "SWIFT_COMPILATION_MODE": "wholemodule",
    "SWIFT_OPTIMIZATION_LEVEL": "-O",
]
let openSwiftUIPackageConfigurations: [Configuration] = [
    .debug(name: "SwiftUIDebug", settings: openSwiftUIPackageDebugSettings),
    .release(name: "SwiftUIRelease", settings: openSwiftUIPackageReleaseSettings),
    .debug(name: "OpenSwiftUIDebug", settings: openSwiftUIPackageDebugSettings),
    .release(name: "OpenSwiftUIRelease", settings: openSwiftUIPackageReleaseSettings),
]
let openSwiftUITargetSettings: SettingsDictionary = [
    "DYLIB_INSTALL_NAME_BASE": "@rpath",
]

let packageSettings = PackageSettings(
    productTypes: [
        "OpenSwiftUI": ProjectDescription.Product.framework,
        "OpenSwiftUICore": ProjectDescription.Product.staticFramework,
        "OpenSwiftUI_SPI": ProjectDescription.Product.staticFramework,
        "COpenSwiftUI": ProjectDescription.Product.staticFramework,
        "OpenSwiftUIMacros": ProjectDescription.Product.macro,
        "OpenSwiftUITestsSupport": ProjectDescription.Product.staticFramework,
        "OpenSwiftUISymbolDualTestsSupport": ProjectDescription.Product.staticFramework,
        "OpenAttributeGraphShims": ProjectDescription.Product.staticFramework,
        "OpenCoreGraphicsShims": ProjectDescription.Product.staticFramework,
        "OpenObservation": ProjectDescription.Product.staticFramework,
        "OpenQuartzCoreShims": ProjectDescription.Product.staticFramework,
        "OpenRenderBoxShims": ProjectDescription.Product.staticFramework,
        "SymbolLocator": ProjectDescription.Product.staticFramework,
    ],
    productDestinations: [
        "OpenSwiftUI": examplePackageDestinations,
        "OpenSwiftUICore": examplePackageDestinations,
        "OpenSwiftUI_SPI": examplePackageDestinations,
        "OpenSwiftUIExtension": examplePackageDestinations,
        "OpenSwiftUIBridge": examplePackageDestinations,
        "OpenAttributeGraph": examplePackageDestinations,
        "OpenAttributeGraphShims": examplePackageDestinations,
        "OpenRenderBox": examplePackageDestinations,
        "OpenRenderBoxShims": examplePackageDestinations,
    ],
    baseSettings: .settings(
        configurations: openSwiftUIPackageConfigurations,
        defaultSettings: .none,
        defaultConfiguration: "OpenSwiftUIDebug"
    ),
    targetSettings: [
        "OpenSwiftUI": .settings(base: openSwiftUITargetSettings),
    ]
)
#endif
