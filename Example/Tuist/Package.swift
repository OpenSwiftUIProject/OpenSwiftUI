// swift-tools-version: 6.2

import PackageDescription

#if TUIST
import ProjectDescriptionHelpers

public struct PackageContextEnvironmentProvider: EnvironmentProvider {
    public init() {}

    public func value(forKey key: String) -> String? {
        Context.environment[key]
    }
}

configureOpenSwiftUIEnvironment(provider: PackageContextEnvironmentProvider())
let exampleServerConfiguration = OpenSwiftUIExampleServerConfiguration.resolve()
let enableLookInsideServer = exampleServerConfiguration.enableLookInsideServer
let enableLookInServer = exampleServerConfiguration.enableLookInServer
#else
let enableLookInsideServer = true
let enableLookInServer = true
#endif

var dependencies: [PackageDescription.Package.Dependency] = [
    .package(path: "../../"),
    .package(path: "../../../OpenAttributeGraph"),
    .package(path: "../../../OpenRenderBox"),
    .package(path: "../../../DarwinPrivateFrameworks"),
    .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3"),
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0"),
    .package(url: "https://github.com/OpenSwiftUIProject/equatable.git", branch: "main"),
    .package(url: "https://github.com/OpenSwiftUIProject/SymbolLocator.git", from: "0.2.0"),
    .package(url: "https://github.com/OpenSwiftUIProject/swift-snapshot-testing.git", exact: "1.19.2"),
]

if enableLookInsideServer {
    dependencies.append(.package(url: "https://github.com/LookInsideApp/LookInside-Release.git", from: "0.2.2"))
}

if enableLookInServer {
    dependencies.append(.package(url: "https://github.com/QMUI/LookinServer.git", from: "1.2.8"))
}

let package = PackageDescription.Package(
    name: "ExampleDependencies",
    dependencies: dependencies
)

#if TUIST
import ProjectDescription

let examplePackageDestinations: Destinations = [.iPhone, .iPad, .mac, .appleVision]
let openSwiftUIPackageDebugSettings: SettingsDictionary = [
    "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) DEBUG=1",
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG",
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

var packageProductTypes: [String: ProjectDescription.Product] = [
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
]

var packageProductDestinations: [String: Destinations] = [
    "OpenSwiftUI": examplePackageDestinations,
    "OpenSwiftUICore": examplePackageDestinations,
    "OpenSwiftUI_SPI": examplePackageDestinations,
    "OpenSwiftUIExtension": examplePackageDestinations,
    "OpenSwiftUIBridge": examplePackageDestinations,
    "OpenAttributeGraph": examplePackageDestinations,
    "OpenAttributeGraphShims": examplePackageDestinations,
    "OpenRenderBox": examplePackageDestinations,
    "OpenRenderBoxShims": examplePackageDestinations,
]

if enableLookInsideServer {
    packageProductTypes["LookInsideServer"] = ProjectDescription.Product.framework
    packageProductDestinations["LookInsideServer"] = [.iPhone, .iPad, .mac]
}

if enableLookInServer {
    packageProductTypes["LookinServer"] = ProjectDescription.Product.framework
    packageProductDestinations["LookinServer"] = [.iPhone, .iPad]
}

let packageSettings = PackageSettings(
    productTypes: packageProductTypes,
    productDestinations: packageProductDestinations,
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
