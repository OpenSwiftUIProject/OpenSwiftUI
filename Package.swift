// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

func envEnable(_ key: String, default defaultValue: Bool = false) -> Bool {
    guard let value = Context.environment[key] else {
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

// MARK: - Env and Config

let isXcodeEnv = Context.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode"

// Xcode use clang as linker which supports "-iframework" while SwiftPM use swiftc as linker which supports "-Fsystem"
let systemFrameworkSearchFlag = isXcodeEnv ? "-iframework" : "-Fsystem"

let swiftBinPath = Context.environment["_"] ?? "/usr/bin/swift"
let swiftBinURL = URL(fileURLWithPath: swiftBinPath)
let SDKPath = swiftBinURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().path
let includePath = SDKPath.appending("/usr/lib/swift")

var sharedCSettings: [CSetting] = [
    .unsafeFlags(["-I", includePath], .when(platforms: .nonDarwinPlatforms)),
    .unsafeFlags(["-fmodules"]),
    .define("__COREFOUNDATION_FORSWIFTFOUNDATIONONLY__", to: "1", .when(platforms: .nonDarwinPlatforms)),
    .define("_WASI_EMULATED_SIGNAL", .when(platforms: [.wasi])),
]

var sharedCxxSettings: [CXXSetting] = [
    .unsafeFlags(["-I", includePath], .when(platforms: .nonDarwinPlatforms)),
    .unsafeFlags(["-fcxx-modules"]),
    .define("__COREFOUNDATION_FORSWIFTFOUNDATIONONLY__", to: "1", .when(platforms: .nonDarwinPlatforms)),
    .define("_WASI_EMULATED_SIGNAL", .when(platforms: [.wasi])),
]

var sharedSwiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("InferSendableFromCaptures"),
    .define("OPENSWIFTUI_SUPPRESS_DEPRECATED_WARNINGS"),
    .swiftLanguageMode(.v5),
]

// MARK: - [env] OPENSWIFTUI_TARGET_RELEASE

let releaseVersion = Context.environment["OPENSWIFTUI_TARGET_RELEASE"].flatMap { Int($0) } ?? 2024
sharedCSettings.append(.define("OPENSWIFTUI_RELEASE", to: "\(releaseVersion)"))
sharedSwiftSettings.append(.define("OPENSWIFTUI_RELEASE_\(releaseVersion)"))
if releaseVersion >= 2024 {
    for year in 2024 ... releaseVersion {
        sharedSwiftSettings.append(.define("OPENSWIFTUI_SUPPORT_\(year)_API"))
    }
}

// MARK: - [env] OPENSWIFTUI_DEVELOPMENT

let development = envEnable("OPENSWIFTUI_DEVELOPMENT")

if development {
    sharedSwiftSettings.append(.define("OPENSWIFTUI_DEVELOPMENT"))
}

// MARK: - [env] OPENSWIFTUI_LINK_COREUI

#if os(macOS)
let linkCoreUI = envEnable("OPENSWIFTUI_LINK_COREUI", default: true)
#else
let linkCoreUI = envEnable("OPENSWIFTUI_LINK_COREUI")
#endif

if linkCoreUI {
    sharedCSettings.append(
        .define("OPENSWIFTUI_LINK_COREUI")
    )
    sharedCxxSettings.append(
        .define("OPENSWIFTUI_LINK_COREUI")
    )
    sharedSwiftSettings.append(
        .define("OPENSWIFTUI_LINK_COREUI")
    )
}

// MARK: - [env] OPENGSWIFTUI_SYMBOL_LOCATOR

#if os(macOS)
let symbolLocatorCondition = envEnable("OPENGSWIFTUI_SYMBOL_LOCATOR", default: true)
#else
let symbolLocatorCondition = envEnable("OPENGSWIFTUI_SYMBOL_LOCATOR")
#endif

// MARK: - [env] OPENGSWIFTUI_SWIFTUI_RENDER

#if os(macOS)
let swiftUIRenderCondition = envEnable("OPENSWIFTUI_SWIFTUI_RENDER", default: true)
#else
let swiftUIRenderCondition = envEnable("OPENSWIFTUI_SWIFTUI_RENDER")
#endif

if swiftUIRenderCondition {
    sharedCSettings.append(.define("_OPENSWIFTUI_SWIFTUI_RENDER"))
    sharedCxxSettings.append(.define("_OPENSWIFTUI_SWIFTUI_RENDER"))
    sharedSwiftSettings.append(.define("_OPENSWIFTUI_SWIFTUI_RENDER"))
}

// MARK: - [env] OPENSWIFTUI_WERROR

let warningsAsErrorsCondition = envEnable("OPENSWIFTUI_WERROR", default: isXcodeEnv && development)
if warningsAsErrorsCondition {
    // Hold off the werror feature as we can't avoid the concurrency warning.
    // Since there is no such group for diagnostic we want to ignore, we enable werror for all known groups instead.
    // See detail on [#443](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0443-warning-control-flags.md)
    // items we want it to be error:
    // [remove_package_import]
    // items we want to ignore:
    // [error_from_clang] [error_in_future_swift_version]
    // sharedSwiftSettings.append(.unsafeFlags(["-warnings-as-errors"]))
    sharedSwiftSettings.append(.unsafeFlags(["-Werror", "DeprecatedDeclaration"]))
    sharedSwiftSettings.append(.unsafeFlags(["-Werror", "Unsafe"]))
    sharedSwiftSettings.append(.unsafeFlags(["-Werror", "UnknownWarningGroup"]))
    sharedSwiftSettings.append(.unsafeFlags(["-Werror", "ExistentialAny"]))
}

// MARK: - [env] OPENSWIFTUI_LIBRARY_EVOLUTION

#if os(macOS)
let libraryEvolutionCondition = envEnable("OPENSWIFTUI_LIBRARY_EVOLUTION", default: true)
#else
let libraryEvolutionCondition = envEnable("OPENSWIFTUI_LIBRARY_EVOLUTION")
#endif

if libraryEvolutionCondition {
    // NOTE: -enable-library-evolution will cause module verify failure for `swift build`.
    // Either set OPENSWIFTUI_LIBRARY_EVOLUTION=0 or add `-Xswiftc -no-verify-emitted-module-interface` after `swift build`
    sharedSwiftSettings.append(.unsafeFlags(["-enable-library-evolution", "-no-verify-emitted-module-interface"]))
}

// MARK: - CoreGraphicsShims Target

let coreGraphicsShimsTarget = Target.target(
    name: "CoreGraphicsShims",
    swiftSettings: sharedSwiftSettings
)
let coreGraphicsShimsTestTarget = Target.testTarget(
    name: "CoreGraphicsShimsTests",
    dependencies: [
        "CoreGraphicsShims",
        .product(name: "Numerics", package: "swift-numerics"),
    ],
    exclude: ["README.md"],
    swiftSettings: sharedSwiftSettings
)

// MARK: - OpenSwiftUISPI Target

let openSwiftUISPITarget = Target.target(
    name: "OpenSwiftUI_SPI",
    dependencies: [
        .product(name: "OpenBox", package: "OpenBox"),
    ],
    publicHeadersPath: ".",
    cSettings: sharedCSettings + [.define("_GNU_SOURCE", .when(platforms: .nonDarwinPlatforms))],
    cxxSettings: sharedCxxSettings,
    linkerSettings: [.unsafeFlags(["-lMobileGestalt"], .when(platforms: .darwinPlatforms))] // For MGCopyAnswer API support
)

let openSwiftUISPITestTarget = Target.testTarget(
    name: "OpenSwiftUI_SPITests",
    dependencies: [
        "OpenSwiftUI_SPI",
        // For ProtocolDescriptor symbol linking
        "OpenSwiftUI",
        .product(name: "Numerics", package: "swift-numerics"),
    ],
    exclude: ["README.md"],
    swiftSettings: sharedSwiftSettings
)

// MARK: - OpenSwiftUICore Target

// NOTE:
// In macOS: Mac Catalyst App will use macOS-varient build of SwiftUI.framework in /System/Library/Framework and iOS varient of SwiftUI.framework in /System/iOSSupport/System/Library/Framework
// Add `|| Mac Catalyst` check everywhere in `OpenSwiftUICore` and `OpenSwiftUI_SPI`.
let openSwiftUICoreTarget = Target.target(
    name: "OpenSwiftUICore",
    dependencies: [
        "OpenSwiftUI_SPI",
        "CoreGraphicsShims",
        .product(name: "OpenGraphShims", package: "OpenGraph"),
        .product(name: "OpenBoxShims", package: "OpenBox"),
    ] + (swiftUIRenderCondition && symbolLocatorCondition ? ["OpenSwiftUISymbolDualTestsSupport"] : []),
    cSettings: sharedCSettings,
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings
)

let openSwiftUICoreTestTarget = Target.testTarget(
    name: "OpenSwiftUICoreTests",
    dependencies: [
        "OpenSwiftUI", // NOTE: For the Glue link logic only, do not call `import OpenSwiftUI` in this target
        "OpenSwiftUICore",
        "OpenSwiftUITestsSupport",
        .product(name: "Numerics", package: "swift-numerics"),
    ],
    exclude: ["README.md"],
    cSettings: sharedCSettings,
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings
)

// MARK: OpenSwiftUI Target

let cOpenSwiftUITarget = Target.target(
    name: "COpenSwiftUI",
    publicHeadersPath: ".",
    cSettings: sharedCSettings + [
        .headerSearchPath("../OpenSwiftUI_SPI"),
    ],
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings
)

let openSwiftUITarget = Target.target(
    name: "OpenSwiftUI",
    dependencies: [
        "OpenSwiftUICore",
        "COpenSwiftUI",
        "CoreGraphicsShims",
        .target(name: "CoreServices", condition: .when(platforms: [.iOS])),
        .product(name: "OpenGraphShims", package: "OpenGraph"),
        .product(name: "OpenBoxShims", package: "OpenBox"),
    ],
    cSettings: sharedCSettings,
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings
)

let openSwiftUITestsSupportTarget = Target.target(
    name: "OpenSwiftUITestsSupport",
    dependencies: [
        "OpenSwiftUI",
    ],
    swiftSettings: sharedSwiftSettings
)

let openSwiftUIExtensionTarget = Target.target(
    name: "OpenSwiftUIExtension",
    dependencies: [
        "OpenSwiftUI",
    ],
    cSettings: sharedCSettings,
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings
)

let openSwiftUITestTarget = Target.testTarget(
    name: "OpenSwiftUITests",
    dependencies: [
        "OpenSwiftUI",
        "OpenSwiftUITestsSupport",
    ],
    exclude: ["README.md"],
    cSettings: sharedCSettings,
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings
)

let openSwiftUICompatibilityTestTarget = Target.testTarget(
    name: "OpenSwiftUICompatibilityTests",
    dependencies: [
        "OpenSwiftUITestsSupport",
        .product(name: "Numerics", package: "swift-numerics"),
    ],
    exclude: ["README.md"],
    cSettings: sharedCSettings,
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings
)

// MARK: - [env] OPENSWIFTUI_BRIDGE_FRAMEWORK

let bridgeFramework = Context.environment["OPENSWIFTUI_BRIDGE_FRAMEWORK"] ?? "SwiftUI"

// MARK: - OpenSwiftUIBridge Target

let openSwiftUIBridgeTarget = Target.target(
    name: "OpenSwiftUIBridge",
    dependencies: [
        "OpenSwiftUI",
    ],
    sources: ["Bridgeable.swift", bridgeFramework],
    cSettings: sharedCSettings,
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings
)

let openSwiftUIBridgeTestTarget = Target.testTarget(
    name: "OpenSwiftUIBridgeTests",
    dependencies: [
        "OpenSwiftUIBridge",
        "OpenSwiftUITestsSupport",
    ],
    exclude: ["README.md"],
    sources: ["BridgeableTests.swift", bridgeFramework],
    cSettings: sharedCSettings,
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings
)

// MARK: - OpenSwiftUISymbolDualTests Target

let openSwiftUISymbolDualTestsSupportTarget = Target.target(
    name: "OpenSwiftUISymbolDualTestsSupport",
    dependencies: [
        .product(name: "SymbolLocator", package: "SymbolLocator"),
    ],
    publicHeadersPath: ".",
    cSettings: sharedCSettings + [
        .headerSearchPath("../OpenSwiftUI_SPI"),
    ],
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings
)

let openSwiftUISymbolDualTestsTarget = Target.testTarget(
    name: "OpenSwiftUISymbolDualTests",
    dependencies: [
        "OpenSwiftUI",
        "OpenSwiftUITestsSupport",
        "OpenSwiftUISymbolDualTestsSupport",
    ],
    exclude: ["README.md"],
    cSettings: sharedCSettings,
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings
)

// Workaround iOS CI build issue (We need to disable this on iOS CI)
let supportMultiProducts: Bool = envEnable("OPENSWIFTUI_SUPPORT_MULTI_PRODUCTS", default: true)

let libraryType: Product.Library.LibraryType?
switch Context.environment["OPENSWIFTUI_LIBRARY_TYPE"] {
case "dynamic":
    libraryType = .dynamic
case "static":
    libraryType = .static
default:
    libraryType = nil
}

var products: [Product] = [
    .library(name: "OpenSwiftUI", type: libraryType, targets: ["OpenSwiftUI"])
]
if supportMultiProducts {
    products += [
        .library(name: "OpenSwiftUICore", type: libraryType, targets: ["OpenSwiftUICore"]),
        .library(name: "OpenSwiftUI_SPI", targets: ["OpenSwiftUI_SPI"]),
        .library(name: "OpenSwiftUIExtension", targets: ["OpenSwiftUIExtension"]),
        .library(name: "OpenSwiftUIBridge", targets: ["OpenSwiftUIBridge"])
    ]
}

let package = Package(
    name: "OpenSwiftUI",
    products: products,
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3"),
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
        .binaryTarget(name: "CoreServices", path: "PrivateFrameworks/CoreServices.xcframework"),

        coreGraphicsShimsTarget,
        coreGraphicsShimsTestTarget,

        openSwiftUISPITarget,
        openSwiftUISPITestTarget,

        openSwiftUICoreTarget,
        openSwiftUICoreTestTarget,

        cOpenSwiftUITarget,
        openSwiftUITarget,
        openSwiftUITestsSupportTarget,
        openSwiftUIExtensionTarget,
        openSwiftUITestTarget,
        openSwiftUICompatibilityTestTarget,

        openSwiftUIBridgeTarget,
        openSwiftUIBridgeTestTarget,
    ]
)

extension Target {
    func addAGSettings() {
        // FIXME: Weird SwiftPM behavior for test Target. Otherwize we'll get the following error message
        // "could not determine executable path for bundle 'AttributeGraph.framework'"
        dependencies.append(.product(name: "AttributeGraph", package: "DarwinPrivateFrameworks"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENGRAPH_ATTRIBUTEGRAPH"))
        self.swiftSettings = swiftSettings
    }

    func addRBSettings() {
        // FIXME: Weird SwiftPM behavior for test Target. Otherwize we'll get the following error message
        // "could not determine executable path for bundle 'RenderBox.framework'"
        dependencies.append(.product(name: "RenderBox", package: "DarwinPrivateFrameworks"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENBOX_RENDERBOX"))
        self.swiftSettings = swiftSettings
    }

    func addCoreUISettings() {
        // FIXME: Weird SwiftPM behavior for test Target. Otherwize we'll get the following error message
        // "could not determine executable path for bundle 'CoreUI.framework'"
        dependencies.append(.product(name: "CoreUI", package: "DarwinPrivateFrameworks"))
    }

    func addOpenCombineSettings() {
        dependencies.append(.product(name: "OpenCombine", package: "OpenCombine"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENSWIFTUI_OPENCOMBINE"))
        self.swiftSettings = swiftSettings
    }

    func addSwiftLogSettings() {
        dependencies.append(.product(name: "Logging", package: "swift-log"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENSWIFTUI_SWIFT_LOG"))
        self.swiftSettings = swiftSettings
    }

    func addSwiftCryptoSettings() {
        dependencies.append(.product(name: "Crypto", package: "swift-crypto"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENSWIFTUI_SWIFT_CRYPTO"))
        self.swiftSettings = swiftSettings
    }
}

let useLocalDeps = envEnable("OPENSWIFTUI_USE_LOCAL_DEPS")

#if os(macOS)
let attributeGraphCondition = envEnable("OPENGRAPH_ATTRIBUTEGRAPH", default: true)
#else
let attributeGraphCondition = envEnable("OPENGRAPH_ATTRIBUTEGRAPH")
#endif

if attributeGraphCondition {
    openSwiftUICoreTarget.addAGSettings()
    openSwiftUITarget.addAGSettings()

    openSwiftUISPITestTarget.addAGSettings()
    openSwiftUICoreTestTarget.addAGSettings()
    openSwiftUITestTarget.addAGSettings()
    openSwiftUICompatibilityTestTarget.addAGSettings()
    openSwiftUIBridgeTestTarget.addAGSettings()
}

#if os(macOS)
let renderBoxCondition = envEnable("OPENBOX_RENDERBOX", default: true)
#else
let renderBoxCondition = envEnable("OPENBOX_RENDERBOX")
#endif

if renderBoxCondition {
    openSwiftUICoreTarget.addRBSettings()
    openSwiftUITarget.addRBSettings()

    openSwiftUISPITestTarget.addRBSettings()
    openSwiftUICoreTestTarget.addRBSettings()
    openSwiftUITestTarget.addRBSettings()
    openSwiftUICompatibilityTestTarget.addRBSettings()
    openSwiftUIBridgeTestTarget.addRBSettings()
}

if attributeGraphCondition || renderBoxCondition {
    let release = Context.environment["DARWIN_PRIVATE_FRAMEWORKS_TARGET_RELEASE"].flatMap { Int($0) } ?? 2024
    package.platforms = switch release {
        case 2024: [.iOS(.v18), .macOS(.v15), .macCatalyst(.v18), .tvOS(.v18), .watchOS(.v10), .visionOS(.v2)]
        default: nil
    }
}

if linkCoreUI {
    openSwiftUICoreTarget.addCoreUISettings()
    openSwiftUISPITarget.addCoreUISettings()
}

if useLocalDeps {
    var dependencies: [Package.Dependency] = [
        .package(path: "../OpenGraph"),
        .package(path: "../OpenBox"),
    ]
    if attributeGraphCondition || renderBoxCondition || linkCoreUI {
        dependencies.append(.package(path: "../DarwinPrivateFrameworks"))
    }
    package.dependencies += dependencies
} else {
    var dependencies: [Package.Dependency] = [
        // FIXME: on Linux platform: OG contains unsafe build flags which prevents us using version dependency
        .package(url: "https://github.com/OpenSwiftUIProject/OpenGraph", branch: "main"),
        .package(url: "https://github.com/OpenSwiftUIProject/OpenBox", branch: "main"),
    ]
    if attributeGraphCondition || renderBoxCondition || linkCoreUI {
        dependencies.append(.package(url: "https://github.com/OpenSwiftUIProject/DarwinPrivateFrameworks.git", branch: "main"))
    }
    package.dependencies += dependencies
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
    openSwiftUICoreTarget.addOpenCombineSettings()
    openSwiftUITarget.addOpenCombineSettings()
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
    openSwiftUICoreTarget.addSwiftLogSettings()
    openSwiftUITarget.addSwiftLogSettings()
}

#if os(macOS)
let swiftCryptoCondition = envEnable("OPENSWIFTUI_SWIFT_CRYPTO")
#else
let swiftCryptoCondition = envEnable("OPENSWIFTUI_SWIFT_CRYPTO", default: true)
#endif
if swiftCryptoCondition {
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.8.0")
    )
    openSwiftUICoreTarget.addSwiftCryptoSettings()
    openSwiftUITarget.addSwiftCryptoSettings()
}

let compatibilityTestCondition = envEnable("OPENSWIFTUI_COMPATIBILITY_TEST")
if compatibilityTestCondition {
    var swiftSettings: [SwiftSetting] = (openSwiftUICompatibilityTestTarget.swiftSettings ?? [])
    swiftSettings.append(.define("OPENSWIFTUI_COMPATIBILITY_TEST"))
    openSwiftUICompatibilityTestTarget.swiftSettings = swiftSettings
} else {
    openSwiftUICompatibilityTestTarget.dependencies.append("OpenSwiftUI")
}

// MARK: - SymbolLocator

if symbolLocatorCondition {
    package.dependencies.append(
        .package(url: "https://github.com/OpenSwiftUIProject/SymbolLocator.git", from: "0.2.0")
    )

    package.targets += [
        openSwiftUISymbolDualTestsSupportTarget,
        openSwiftUISymbolDualTestsTarget,
    ]
}

extension [Platform] {
    static var darwinPlatforms: [Platform] {
        [.macOS, .iOS, .macCatalyst, .tvOS, .watchOS, .visionOS]
    }

    static var nonDarwinPlatforms: [Platform] {
        [.linux, .android, .wasi, .openbsd, .windows]
    }
}
