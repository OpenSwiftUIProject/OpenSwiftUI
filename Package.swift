// swift-tools-version: 6.0
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

// MARK: - [env] OPENGRAPH_TARGET_RELEASE

let releaseVersion = Context.environment["OPENSWIFTUI_TARGET_RELEASE"].flatMap { Int($0) } ?? 2024
sharedCSettings.append(.define("OPENSWIFTUI_RELEASE", to: "\(releaseVersion)"))
sharedSwiftSettings.append(.define("OPENSWIFTUI_RELEASE_\(releaseVersion)"))
if releaseVersion >= 2021 {
    for year in 2021 ... releaseVersion {
        sharedSwiftSettings.append(.define("OPENSWIFTUI_SUPPORT_\(year)_API"))
    }
}

// MARK: - [env] OPENSWIFTUI_DEVELOPMENT

let development = envEnable("OPENSWIFTUI_DEVELOPMENT")

if development {
    sharedSwiftSettings.append(.define("OPENSWIFTUI_DEVELOPMENT"))
}

// MARK: - [env] OPENSWIFTUI_WERROR

let warningsAsErrorsCondition = envEnable("OPENSWIFTUI_WERROR", default: isXcodeEnv && development)
if warningsAsErrorsCondition {
    // Hold off the werror feature as we can't avoid the concurrency warning.
    // Reenable the folllowing after swift-evolution#443 is release.
    
    // sharedSwiftSettings.append(.unsafeFlags(["-warnings-as-errors"]))
    // sharedSwiftSettings.append(.unsafeFlags(["-Wwarning", "concurrency"]))
}

// MARK: - [env] OPENSWIFTUI_BRIDGE_FRAMEWORK

let bridgeFramework = Context.environment["OPENSWIFTUI_BRIDGE_FRAMEWORK"] ?? "SwiftUI"

// MARK: - Targets

let cOpenSwiftUITarget = Target.target(
    name: "COpenSwiftUI",
    publicHeadersPath: ".",
    cSettings: sharedCSettings + [
        .headerSearchPath("../OpenSwiftUI_SPI"),
    ],
    cxxSettings: sharedCxxSettings
)
let openSwiftUISPITarget = Target.target(
    name: "OpenSwiftUI_SPI",
    dependencies: [
        .product(name: "OpenBox", package: "OpenBox"),
    ],
    publicHeadersPath: ".",
    cSettings: sharedCSettings + [.define("_GNU_SOURCE", .when(platforms: .nonDarwinPlatforms))],
    cxxSettings: sharedCxxSettings
)
let coreGraphicsShims = Target.target(
    name: "CoreGraphicsShims",
    swiftSettings: sharedSwiftSettings
)
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
    ],
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
    swiftSettings: sharedSwiftSettings
)
let openSwiftUIExtensionTarget = Target.target(
    name: "OpenSwiftUIExtension",
    dependencies: [
        "OpenSwiftUI",
    ],
    swiftSettings: sharedSwiftSettings
)

let openSwiftUIBridgeTarget = Target.target(
    name: "OpenSwiftUIBridge",
    dependencies: [
        "OpenSwiftUI",
    ],
    sources: ["Bridgeable.swift", bridgeFramework],
    swiftSettings: sharedSwiftSettings
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
let openSwiftUICoreTestTarget = Target.testTarget(
    name: "OpenSwiftUICoreTests",
    dependencies: [
        "OpenSwiftUICore",
        .product(name: "Numerics", package: "swift-numerics"),
    ],
    exclude: ["README.md"],
    swiftSettings: sharedSwiftSettings
)
let openSwiftUITestTarget = Target.testTarget(
    name: "OpenSwiftUITests",
    dependencies: [
        "OpenSwiftUI",
    ],
    exclude: ["README.md"],
    swiftSettings: sharedSwiftSettings
)
let openSwiftUICompatibilityTestTarget = Target.testTarget(
    name: "OpenSwiftUICompatibilityTests",
    dependencies: [
        .product(name: "Numerics", package: "swift-numerics"),
    ],
    exclude: ["README.md"],
    swiftSettings: sharedSwiftSettings
)
let openSwiftUIBridgeTestTarget = Target.testTarget(
    name: "OpenSwiftUIBridgeTests",
    dependencies: [
        "OpenSwiftUIBridge",
    ],
    exclude: ["README.md"],
    sources: ["BridgeableTests.swift", bridgeFramework],
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
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.2"),
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
        coreGraphicsShims,
        cOpenSwiftUITarget,
        openSwiftUISPITarget,
        openSwiftUICoreTarget,
        openSwiftUITarget,
        
        openSwiftUIExtensionTarget,
        openSwiftUIBridgeTarget,
        
        openSwiftUISPITestTarget,
        openSwiftUICoreTestTarget,
        openSwiftUITestTarget,
        openSwiftUICompatibilityTestTarget,
        openSwiftUIBridgeTestTarget,
        coreGraphicsShimsTestTarget,
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
        case 2021: [.iOS(.v15), .macOS(.v12), .macCatalyst(.v15), .tvOS(.v15), .watchOS(.v7)]
        default: nil
    }
}

if useLocalDeps {
    package.dependencies += [
        .package(path: "../OpenGraph"),
        .package(path: "../OpenBox"),
    ]
    if attributeGraphCondition || renderBoxCondition {
        package.dependencies.append(
            .package(path: "../DarwinPrivateFrameworks")
        )
    }
} else {
    package.dependencies += [
        // FIXME: on Linux platform: OG contains unsafe build flags which prevents us using version dependency
        .package(url: "https://github.com/OpenSwiftUIProject/OpenGraph", branch: "main"),
        .package(url: "https://github.com/OpenSwiftUIProject/OpenBox", branch: "main"),
    ]
    if attributeGraphCondition || renderBoxCondition {
        package.dependencies.append(
            .package(url: "https://github.com/OpenSwiftUIProject/DarwinPrivateFrameworks.git", branch: "main")
        )
    }
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

extension [Platform] {
    static var nonDarwinPlatforms: [Platform] {
        [.linux, .android, .wasi, .openbsd, .windows]
    }
}
