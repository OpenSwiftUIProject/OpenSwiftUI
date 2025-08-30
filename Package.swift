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

#if os(macOS)
// NOTE: #if os(macOS) check is not accurate if we are cross compiling for Linux platform. So we add an env key to specify it.
let buildForDarwinPlatform = envEnable("OPENSWIFTUI_BUILD_FOR_DARWIN_PLATFORM", default: true)
#else
let buildForDarwinPlatform = envEnable("OPENSWIFTUI_BUILD_FOR_DARWIN_PLATFORM")
#endif

// https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/3061#issuecomment-2118821061
// By-pass https://github.com/swiftlang/swift-package-manager/issues/7580
let isSPIDocGenerationBuild = envEnable("SPI_GENERATE_DOCS")
let isSPIBuild = envEnable("SPI_BUILD")

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
    .unsafeFlags(["-Wwarning", "DeprecatedDeclaration"]), // We want to use deprecated APIs in test targets
    // FIXME: -unavailable-decl-optimization=stub is not working somehow (eg. Color.vibrancy). Dig into this later
    .unsafeFlags(["-unavailable-decl-optimization=stub"]),
    .swiftLanguageMode(.v5),
]

// MARK: - [env] OPENSWIFTUI_ANY_ATTRIBUTE_FIX

// For #39
let anyAttributeFix = envEnable("OPENSWIFTUI_ANY_ATTRIBUTE_FIX", default: !buildForDarwinPlatform)
if anyAttributeFix {
    sharedSwiftSettings.append(.define("OPENSWIFTUI_ANY_ATTRIBUTE_FIX"))
}

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

let linkCoreUI = envEnable("OPENSWIFTUI_LINK_COREUI", default: buildForDarwinPlatform && !isSPIBuild)

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

let symbolLocatorCondition = envEnable("OPENGSWIFTUI_SYMBOL_LOCATOR", default: buildForDarwinPlatform)

// MARK: - [env] OPENSWIFTUI_OPENCOMBINE

let openCombineCondition = envEnable("OPENSWIFTUI_OPENCOMBINE", default: !buildForDarwinPlatform)

// MARK: - [env] OPENSWIFTUI_SWIFT_LOG

let swiftLogCondition = envEnable("OPENSWIFTUI_SWIFT_LOG", default: !buildForDarwinPlatform)

// MARK: - [env] OPENSWIFTUI_SWIFT_CRYPTO

let swiftCryptoCondition = envEnable("OPENSWIFTUI_SWIFT_CRYPTO", default: !buildForDarwinPlatform)

// MARK: - [env] OPENSWIFTUI_RENDER_GTK

let renderGTKCondition = envEnable("OPENSWIFTUI_RENDER_GTK", default: !buildForDarwinPlatform)

let cgtkTarget = Target.systemLibrary(
    name: "CGTK",
    pkgConfig: "gtk4",
    providers: [
        .brew(["gtk4"]),
        .apt(["libgtk-4-dev clang"]),
    ]
)

// MARK: - [env] OPENGSWIFTUI_SWIFTUI_RENDER

let swiftUIRenderCondition = envEnable("OPENSWIFTUI_SWIFTUI_RENDER", default: buildForDarwinPlatform)
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
    sharedSwiftSettings.append(.unsafeFlags(["-Werror", "Unsafe"]))
    sharedSwiftSettings.append(.unsafeFlags(["-Werror", "UnknownWarningGroup"]))
    sharedSwiftSettings.append(.unsafeFlags(["-Werror", "ExistentialAny"]))
}

// MARK: - [env] OPENSWIFTUI_LIBRARY_EVOLUTION

let libraryEvolutionCondition = envEnable("OPENSWIFTUI_LIBRARY_EVOLUTION", default: buildForDarwinPlatform)
if libraryEvolutionCondition && !openCombineCondition && !swiftLogCondition {
    // NOTE: -enable-library-evolution will cause module verify failure for `swift build`.
    // Either set OPENSWIFTUI_LIBRARY_EVOLUTION=0 or add `-Xswiftc -no-verify-emitted-module-interface` after `swift build`
    sharedSwiftSettings.append(.unsafeFlags(["-enable-library-evolution", "-no-verify-emitted-module-interface"]))
}

// MARK: - [env] OPENSWIFTUI_COMPATIBILITY_TEST

let compatibilityTestCondition = envEnable("OPENSWIFTUI_COMPATIBILITY_TEST")
sharedCSettings.append(.define("OPENSWIFTUI", to: compatibilityTestCondition ? "0" : "1"))
sharedCxxSettings.append(.define("OPENSWIFTUI", to: compatibilityTestCondition ? "0" : "1"))
if !compatibilityTestCondition {
    sharedSwiftSettings.append(.define("OPENSWIFTUI"))
}

// MARK: - [env] OPENSWIFTUI_IGNORE_AVAILABILITY

let ignoreAvailability = envEnable("OPENSWIFTUI_IGNORE_AVAILABILITY", default: !isSPIDocGenerationBuild && !compatibilityTestCondition)
sharedSwiftSettings.append(contentsOf: [SwiftSetting].availabilityMacroSettings(ignoreAvailability: ignoreAvailability))

// MARK: - OpenSwiftUISPI Target

let openSwiftUISPITarget = Target.target(
    name: "OpenSwiftUI_SPI",
    dependencies: [
        .product(name: "OpenRenderBox", package: "OpenRenderBox"),
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
        .product(name: "OpenCoreGraphicsShims", package: "OpenCoreGraphics"),
        .product(name: "OpenQuartzCoreShims", package: "OpenCoreGraphics"),
        .product(name: "OpenAttributeGraphShims", package: "OpenAttributeGraph"),
        .product(name: "OpenRenderBoxShims", package: "OpenRenderBox"),
        .product(name: "OpenObservation", package: "OpenObservation"),
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
        .product(name: "OpenCoreGraphicsShims", package: "OpenCoreGraphics"),
        .product(name: "OpenQuartzCoreShims", package: "OpenCoreGraphics"),
        .product(name: "OpenAttributeGraphShims", package: "OpenAttributeGraph"),
        .product(name: "OpenRenderBoxShims", package: "OpenRenderBox"),
    ],
    cSettings: sharedCSettings,
    cxxSettings: sharedCxxSettings,
    swiftSettings: sharedSwiftSettings,
    linkerSettings: [.unsafeFlags(["-framework", "CoreServices"], .when(platforms: [.iOS]))] // For CS private API link support
)

let openSwiftUITestsSupportTarget = Target.target(
    name: "OpenSwiftUITestsSupport",
    dependencies: [
        "OpenSwiftUI",
    ],
    cSettings: sharedCSettings,
    cxxSettings: sharedCxxSettings,
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
    ] + (compatibilityTestCondition ? [] : ["OpenSwiftUI"]),
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
        .product(name: "Numerics", package: "swift-numerics"),
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
        openSwiftUISPITarget,
        openSwiftUICoreTarget,
        cOpenSwiftUITarget,
        openSwiftUITarget,
        openSwiftUITestsSupportTarget,
        openSwiftUIExtensionTarget,
        openSwiftUIBridgeTarget,
    ]
)

if renderGTKCondition {
    package.targets.append(cgtkTarget)
}

if !compatibilityTestCondition {
    package.targets += [
        openSwiftUISPITestTarget,
        openSwiftUICoreTestTarget,
        openSwiftUITestTarget,
        openSwiftUIBridgeTestTarget,
    ]
}

if buildForDarwinPlatform {
    package.targets.append(openSwiftUICompatibilityTestTarget)
}

// MARK: - SymbolLocator

if symbolLocatorCondition {
    package.dependencies.append(
        .package(url: "https://github.com/OpenSwiftUIProject/SymbolLocator.git", from: "0.2.0")
    )
    package.targets += [
        openSwiftUISymbolDualTestsSupportTarget
    ]
    if !compatibilityTestCondition {
        package.targets.append(openSwiftUISymbolDualTestsTarget)
    }
}

extension Target {
    func addAGSettings() {
        // FIXME: Weird SwiftPM behavior for test Target. Otherwize we'll get the following error message
        // "could not determine executable path for bundle 'AttributeGraph.framework'"
        dependencies.append(.product(name: "AttributeGraph", package: "DarwinPrivateFrameworks"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENATTRIBUTEGRAPH_ATTRIBUTEGRAPH"))
        self.swiftSettings = swiftSettings
    }

    func addRBSettings() {
        // FIXME: Weird SwiftPM behavior for test Target. Otherwize we'll get the following error message
        // "could not determine executable path for bundle 'RenderBox.framework'"
        dependencies.append(.product(name: "RenderBox", package: "DarwinPrivateFrameworks"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENRENDERBOX_RENDERBOX"))
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

let attributeGraphCondition = envEnable("OPENATTRIBUTEGRAPH_ATTRIBUTEGRAPH", default: buildForDarwinPlatform && !isSPIBuild)
if attributeGraphCondition {
    openSwiftUICoreTarget.addAGSettings()
    openSwiftUITarget.addAGSettings()

    openSwiftUISPITestTarget.addAGSettings()
    openSwiftUICoreTestTarget.addAGSettings()
    openSwiftUITestTarget.addAGSettings()
    openSwiftUICompatibilityTestTarget.addAGSettings()
    openSwiftUIBridgeTestTarget.addAGSettings()
}

let renderBoxCondition = envEnable("OPENRENDERBOX_RENDERBOX", default: buildForDarwinPlatform && !isSPIBuild)
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
} else {
    // For SPI build issue
    package.platforms = [.iOS(.v18), .macOS(.v15), .macCatalyst(.v18), .tvOS(.v18), .watchOS(.v10), .visionOS(.v2)]
}

if linkCoreUI {
    openSwiftUICoreTarget.addCoreUISettings()
    openSwiftUISPITarget.addCoreUISettings()
}

if useLocalDeps {
    var dependencies: [Package.Dependency] = [
        .package(path: "../OpenCoreGraphics"),
        .package(path: "../OpenAttributeGraph"),
        .package(path: "../OpenRenderBox"),
        .package(path: "../OpenObservation"),
    ]
    if attributeGraphCondition || renderBoxCondition || linkCoreUI {
        dependencies.append(.package(path: "../DarwinPrivateFrameworks"))
    }
    package.dependencies += dependencies
} else {
    var dependencies: [Package.Dependency] = [
        .package(url: "https://github.com/OpenSwiftUIProject/OpenCoreGraphics", branch: "main"),
        // FIXME: on Linux platform: OG contains unsafe build flags which prevents us using version dependency
        .package(url: "https://github.com/OpenSwiftUIProject/OpenAttributeGraph", branch: "main"),
        .package(url: "https://github.com/OpenSwiftUIProject/OpenRenderBox", branch: "main"),
        .package(url: "https://github.com/OpenSwiftUIProject/OpenObservation", branch: "main"),
    ]
    if attributeGraphCondition || renderBoxCondition || linkCoreUI {
        dependencies.append(.package(url: "https://github.com/OpenSwiftUIProject/DarwinPrivateFrameworks.git", branch: "main"))
    }
    package.dependencies += dependencies
}

if openCombineCondition {
    package.dependencies.append(
        .package(url: "https://github.com/OpenSwiftUIProject/OpenCombine.git", from: "0.15.0")
    )
    openSwiftUICoreTarget.addOpenCombineSettings()
    openSwiftUITarget.addOpenCombineSettings()
}

if swiftLogCondition {
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-log", from: "1.5.3")
    )
    openSwiftUICoreTarget.addSwiftLogSettings()
    openSwiftUITarget.addSwiftLogSettings()
}

if swiftCryptoCondition {
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.8.0")
    )
    openSwiftUICoreTarget.addSwiftCryptoSettings()
    openSwiftUITarget.addSwiftCryptoSettings()
}

extension [Platform] {
    static var darwinPlatforms: [Platform] {
        [.macOS, .iOS, .macCatalyst, .tvOS, .watchOS, .visionOS]
    }

    static var nonDarwinPlatforms: [Platform] {
        [.linux, .android, .wasi, .openbsd, .windows]
    }
}

extension [SwiftSetting] {
    /// Settings which define commonly-used OS availability macros.
    ///
    /// These leverage a pseudo-experimental feature in the Swift compiler for
    /// setting availability definitions, which was added in
    /// [swift#65218](https://github.com/swiftlang/swift/pull/65218).
    fileprivate static func availabilityMacroSettings(ignoreAvailability: Bool) -> Self {
        let minimumVersion = "iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0"
        return [
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v1_0:\(ignoreAvailability ? minimumVersion : "iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v1_4:\(ignoreAvailability ? minimumVersion : "iOS 13.4, macOS 10.15.4, tvOS 13.4, watchOS 6.2")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v2_0:\(ignoreAvailability ? minimumVersion : "iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v2_1:\(ignoreAvailability ? minimumVersion : "iOS 14.2, macOS 11.0, tvOS 14.1, watchOS 7.1")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v2_3:\(ignoreAvailability ? minimumVersion : "iOS 14.5, macOS 11.3, tvOS 14.5, watchOS 7.4")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v3_0:\(ignoreAvailability ? minimumVersion : "iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v3_2:\(ignoreAvailability ? minimumVersion : "iOS 15.2, macOS 12.1, tvOS 15.2, watchOS 8.3")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v3_4:\(ignoreAvailability ? minimumVersion : "iOS 15.4, macOS 12.3, tvOS 15.4, watchOS 8.5")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v4_0:\(ignoreAvailability ? minimumVersion : "iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v4_1:\(ignoreAvailability ? minimumVersion : "iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v4_4:\(ignoreAvailability ? minimumVersion : "iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v5_0:\(ignoreAvailability ? minimumVersion : "iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v5_1:\(ignoreAvailability ? minimumVersion : "iOS 17.1, macOS 14.1, tvOS 17.1, watchOS 10.1, visionOS 1.0")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v5_2:\(ignoreAvailability ? minimumVersion : "iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.0")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v5_4:\(ignoreAvailability ? minimumVersion : "iOS 17.4, macOS 14.4, tvOS 17.4, watchOS 10.4, visionOS 1.1")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v6_0:\(ignoreAvailability ? minimumVersion : "iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0")"),
            .enableExperimentalFeature("AvailabilityMacro=OpenSwiftUI_v7_0:\(ignoreAvailability ? minimumVersion : "iOS 19.0, macOS 16.0, tvOS 19.0, watchOS 12.0, visionOS 3.0")"),
            .enableExperimentalFeature("AvailabilityMacro=_distantFuture:iOS 99.0, macOS 99.0, tvOS 99.0, watchOS 99.0, visionOS 99.0"),
        ]
    }
}
