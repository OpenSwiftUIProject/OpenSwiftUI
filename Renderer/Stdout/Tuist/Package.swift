// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "StdoutRendererDependencies",
    dependencies: [
        .package(path: "../../.."),
        .package(path: "../../../../OpenAttributeGraph"),
        .package(path: "../../../../OpenRenderBox"),
        .package(path: "../../../../DarwinPrivateFrameworks"),
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
]

let packageProductDestinations: [String: Destinations] = [
    "OpenSwiftUI": packageDestinations,
    "OpenSwiftUICore": packageDestinations,
    "OpenSwiftUI_SPI": packageDestinations,
    "OpenAttributeGraph": packageDestinations,
    "OpenAttributeGraphShims": packageDestinations,
    "OpenRenderBox": packageDestinations,
    "OpenRenderBoxShims": packageDestinations,
    "AttributeGraph": packageDestinations,
    "RenderBox": packageDestinations,
    "CoreUI": packageDestinations,
    "CoreSVG": packageDestinations,
    "SFSymbols": packageDestinations,
]

let packageSettings = PackageSettings(
    productTypes: packageProductTypes,
    productDestinations: packageProductDestinations,
    baseSettings: .settings(
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ],
        defaultSettings: .none,
        defaultConfiguration: "Debug"
    ),
    targetSettings: [
        "OpenSwiftUI": .settings(
            base: [
                "DYLIB_INSTALL_NAME_BASE": "@rpath",
            ]
        ),
    ]
)
#endif
