// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "StdoutRendererDependencies",
    dependencies: [
        .package(path: "../../.."),
        .package(path: "../../../../OpenAttributeGraph"),
        .package(path: "../../../../OpenRenderBox"),
        .package(path: "../../../../DarwinPrivateFrameworks"),
        .package(url: "https://github.com/OpenSwiftUIProject/SymbolLocator.git", from: "0.2.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0"),
    ]
)

#if TUIST
import ProjectDescription

let packageDestinations: Destinations = [.mac]

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
    "BacklightServices": .framework,
    "SymbolLocator": .staticFramework,
]

let packageProductDestinations: [String: Destinations] = [
    "OpenSwiftUI": packageDestinations,
    "OpenSwiftUICore": packageDestinations,
    "OpenSwiftUI_SPI": packageDestinations,
    "OpenSwiftUIExtension": packageDestinations,
    "OpenSwiftUIBridge": packageDestinations,
    "OpenSwiftUITestsSupport": packageDestinations,
    "OpenSwiftUISymbolDualTestsSupport": packageDestinations,
    "OpenAttributeGraph": packageDestinations,
    "OpenAttributeGraphShims": packageDestinations,
    "OpenRenderBox": packageDestinations,
    "OpenRenderBoxShims": packageDestinations,
    "AttributeGraph": packageDestinations,
    "RenderBox": packageDestinations,
    "CoreUI": packageDestinations,
    "CoreSVG": packageDestinations,
    "SFSymbols": packageDestinations,
    "SymbolLocator": packageDestinations,
]

let debugBuildSettings: SettingsDictionary = [
    "ALWAYS_SEARCH_USER_PATHS": "NO",
    "GCC_OPTIMIZATION_LEVEL": "0",
    "ONLY_ACTIVE_ARCH": "YES",
    "SWIFT_COMPILATION_MODE": "singlefile",
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
]

let releaseBuildSettings: SettingsDictionary = [
    "SWIFT_COMPILATION_MODE": "wholemodule",
    "SWIFT_OPTIMIZATION_LEVEL": "-O",
]

let packageSettings = PackageSettings(
    productTypes: packageProductTypes,
    productDestinations: packageProductDestinations,
    baseSettings: .settings(
        configurations: [
            .debug(name: "Debug", settings: debugBuildSettings),
            .release(name: "Release", settings: releaseBuildSettings),
        ],
        defaultSettings: .none,
        defaultConfiguration: "Debug"
    )
)
#endif
