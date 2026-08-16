// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "OpenSwiftUIMacros",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "OpenSwiftUIMacrosPlugin", targets: ["OpenSwiftUIMacros"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0"),
    ],
    targets: [
        .macro(
            name: "OpenSwiftUIMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("InternalImportsByDefault"),
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "OpenSwiftUIMacrosTests",
            dependencies: [
                "OpenSwiftUIMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("InternalImportsByDefault"),
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
