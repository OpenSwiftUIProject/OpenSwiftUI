// swift-tools-version: 6.1
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "OpenRenderBox": .staticFramework,
        "OpenCoreGraphicsShims": .staticFramework,
        "OpenQuartzCoreShims": .staticFramework,
        "OpenAttributeGraphShims": .staticFramework,
        "OpenRenderBoxShims": .staticFramework,
        "OpenObservation": .staticFramework,
        "SwiftSyntaxMacros": .staticFramework,
        "SwiftCompilerPlugin": .staticFramework,
        "Numerics": .staticFramework,
        "RealModule": .staticFramework,
        "ComplexModule": .staticFramework,
        "SymbolLocator": .staticFramework,
        "AttributeGraph": .staticFramework,
        "CoreUI": .staticFramework,
        "SFSymbols": .staticFramework,
        "BacklightServices": .staticFramework,
    ],
    targetSettings: [
        "OpenRenderBoxCxx": .settings(base: [
            "DEFINES_MODULE": "NO",
        ]),
    ]
)
#endif

let package = Package(
    name: "OpenSwiftUIDeps",
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0"),
        .package(url: "https://github.com/OpenSwiftUIProject/OpenCoreGraphics", branch: "main"),
        .package(url: "https://github.com/OpenSwiftUIProject/OpenAttributeGraph", branch: "main"),
        .package(url: "https://github.com/OpenSwiftUIProject/OpenRenderBox", branch: "main"),
        .package(url: "https://github.com/OpenSwiftUIProject/OpenObservation", branch: "main"),
        .package(url: "https://github.com/OpenSwiftUIProject/DarwinPrivateFrameworks.git", branch: "main"),
        .package(url: "https://github.com/OpenSwiftUIProject/SymbolLocator.git", from: "0.2.0"),
    ]
)
