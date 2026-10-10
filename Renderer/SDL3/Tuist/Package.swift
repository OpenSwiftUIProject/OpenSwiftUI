// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "SDL3Dependencies",
    dependencies: [
        .package(path: "../../.."),
        .package(path: "../../../../OpenAttributeGraph"),
        .package(path: "../../../../OpenRenderBox"),
        .package(path: "../../../../DarwinPrivateFrameworks"),
        .package(path: "../../../../SwiftSDL3"),
        .package(path: "../../../../Shaft"),
        .package(url: "https://github.com/OpenSwiftUIProject/SymbolLocator.git", from: "0.2.0"),
        .package(url: "https://github.com/ShaftUI/swift-collections", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0"),
    ]
)

#if TUIST
import ProjectDescription

let packageProductTypes: [String: ProjectDescription.Product] = [
    "OpenSwiftUI": .framework,
    "OpenSwiftUICore": .staticFramework,
    "OpenSwiftUI_SPI": .staticFramework,
    "COpenSwiftUI": .staticFramework,
    "OpenSwiftUIMacros": .macro,
    "OpenSwiftUITestsSupport": .staticFramework,
    "OpenSwiftUISymbolDualTestsSupport": .staticFramework,
    "OpenAttributeGraphShims": .staticFramework,
    "OpenCoreGraphicsShims": .staticFramework,
    "OpenObservation": .staticFramework,
    "OpenQuartzCoreShims": .staticFramework,
    "OpenRenderBoxShims": .staticFramework,
    "AttributeGraph": .framework,
    "RenderBox": .framework,
    "CoreUI": .framework,
    "CoreSVG": .framework,
    "SFSymbols": .framework,
    "FeatureFlags": .framework,
    "BacklightServices": .framework,
    "SymbolLocator": .staticFramework,
    "SwiftSDL3": .staticFramework,
    "OpenSwiftUISkia": .staticFramework,
    "OpenSwiftUITextLayout": .staticFramework,
    "ShaftSkia": .staticFramework,
    "Shaft": .staticFramework,
    "CSkia": .staticFramework,
]

let packageProductDestinations: [String: Destinations] = [
    "OpenSwiftUI": [.mac],
    "OpenSwiftUICore": [.mac],
    "OpenSwiftUI_SPI": [.mac],
    "OpenSwiftUIExtension": [.mac],
    "OpenSwiftUIBridge": [.mac],
    "OpenSwiftUITestsSupport": [.mac],
    "OpenSwiftUISymbolDualTestsSupport": [.mac],
    "OpenAttributeGraph": [.mac],
    "OpenAttributeGraphShims": [.mac],
    "OpenRenderBox": [.mac],
    "OpenRenderBoxShims": [.mac],
    "AttributeGraph": [.mac],
    "RenderBox": [.mac],
    "CoreUI": [.mac],
    "CoreSVG": [.mac],
    "SFSymbols": [.mac],
    "FeatureFlags": [.mac],
    "SymbolLocator": [.mac],
    "SwiftSDL3": [.mac],
]

let packageSettings = PackageSettings(
    productTypes: packageProductTypes,
    productDestinations: packageProductDestinations,
    baseSettings: .settings(
        base: ["DYLIB_INSTALL_NAME_BASE": "@rpath"],
        configurations: [
            .debug(name: "Debug", settings: [
                "ALWAYS_SEARCH_USER_PATHS": "NO",
                "GCC_OPTIMIZATION_LEVEL": "0",
                "ONLY_ACTIVE_ARCH": "YES",
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": ["$(inherited)", "DEBUG"],
                "SWIFT_COMPILATION_MODE": "singlefile",
                "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
            ]),
            .release(name: "Release", settings: [
                "SWIFT_COMPILATION_MODE": "wholemodule",
                "SWIFT_OPTIMIZATION_LEVEL": "-O",
            ]),
        ],
        defaultSettings: .none,
        defaultConfiguration: "Debug"
    ),
    targetSettings: [
        "SwiftSDL3": .settings(base: [
            // Match SwiftPM's Objective-C compilation and SDK framework autolinking.
            "CLANG_ENABLE_MODULES": "YES",
            "CLANG_ENABLE_OBJC_ARC": "YES",
        ]),
    ]
)
#endif
