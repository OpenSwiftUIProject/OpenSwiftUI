import ProjectDescription

// MARK: - Constants

let releaseVersion = 2024
let destinations: Destinations = [.iPhone, .iPad, .mac, .macCatalyst, .appleTv, .appleWatch, .appleVision]

// MARK: - Shared Settings

let releaseYearDefines: [String] = {
    var defines: [String] = ["OPENSWIFTUI_RELEASE_\(releaseVersion)"]
    if releaseVersion >= 2021 {
        for year in 2021...releaseVersion {
            defines.append("OPENSWIFTUI_SUPPORT_\(year)_API")
        }
    }
    return defines
}()

let availabilityMacroFlags: [String] = {
    let minimumPlatforms = ["iOS 13.0", "macOS 10.15", "tvOS 13.0", "watchOS 6.0", "visionOS 1.0"]
    let distantPlatforms = ["iOS 99.0", "macOS 99.0", "tvOS 99.0", "watchOS 99.0", "visionOS 99.0"]
    let macros: [(String, [String])] = [
        ("OpenSwiftUI_v1_0", minimumPlatforms),
        ("OpenSwiftUI_v1_4", minimumPlatforms),
        ("OpenSwiftUI_v2_0", minimumPlatforms),
        ("OpenSwiftUI_macOS_v2_0", minimumPlatforms),
        ("OpenSwiftUI_v2_1", minimumPlatforms),
        ("OpenSwiftUI_v2_3", minimumPlatforms),
        ("OpenSwiftUI_v3_0", minimumPlatforms),
        ("OpenSwiftUI_v3_2", minimumPlatforms),
        ("OpenSwiftUI_v3_4", minimumPlatforms),
        ("OpenSwiftUI_v4_0", minimumPlatforms),
        ("OpenSwiftUI_v4_1", minimumPlatforms),
        ("OpenSwiftUI_v4_4", minimumPlatforms),
        ("OpenSwiftUI_v5_0", minimumPlatforms),
        ("OpenSwiftUI_v5_1", minimumPlatforms),
        ("OpenSwiftUI_v5_2", minimumPlatforms),
        ("OpenSwiftUI_v5_4", minimumPlatforms),
        ("OpenSwiftUI_v5_5", minimumPlatforms),
        ("OpenSwiftUI_v6_0", minimumPlatforms),
        ("OpenSwiftUI_v7_0", minimumPlatforms),
        ("_distantFuture", distantPlatforms),
    ]
    return macros.flatMap { name, platforms in
        platforms.flatMap { platform in
            ["-Xfrontend", "-enable-experimental-feature", "-Xfrontend", "AvailabilityMacro=\(name):\(platform)"]
        }
    }
}()

let sharedSwiftFlags: [String] = {
    var flags: [String] = [
        "-package-name", "OpenSwiftUI",
        "-enable-library-evolution",
        "-no-verify-emitted-module-interface",
        "-Xfrontend", "-experimental-spi-only-imports",
        "-Xfrontend", "-enable-private-imports",
        "-unavailable-decl-optimization=stub",
        "-Xfrontend", "-enable-upcoming-feature", "-Xfrontend", "BareSlashRegexLiterals",
        "-Xfrontend", "-enable-upcoming-feature", "-Xfrontend", "InternalImportsByDefault",
        "-Xfrontend", "-enable-upcoming-feature", "-Xfrontend", "InferSendableFromCaptures",
        "-Xfrontend", "-enable-experimental-feature", "-Xfrontend", "Extern",
    ]
    return flags
}()

let swiftActiveCompilationConditions: [String] = {
    var conditions = [
        "OPENSWIFTUI",
        "OPENSWIFTUI_CF_CGTYPES",
        "OPENRENDERBOX_CF_CGTYPES",
        "OPENSWIFTUI_LINK_COREUI",
        "OPENSWIFTUI_LINK_SFSYMBOLS",
        "_OPENSWIFTUI_SWIFTUI_RENDER",
        "OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS",
    ]
    conditions += releaseYearDefines
    return conditions
}()

let sharedCDefines: [String] = [
    "OPENSWIFTUI=1",
    "NDEBUG=1",
    "OPENSWIFTUI_CF_CGTYPES=1",
    "OPENRENDERBOX_CF_CGTYPES=1",
    "OPENSWIFTUI_LINK_COREUI=1",
    "OPENSWIFTUI_LINK_SFSYMBOLS=1",
    "OPENSWIFTUI_LINK_BACKLIGHTSERVICES=0",
    "_OPENSWIFTUI_SWIFTUI_RENDER=1",
    "OPENSWIFTUI_INTERNAL_XR_SDK=0",
]

let renderBoxSwiftConditions = swiftActiveCompilationConditions + ["OPENSWIFTUI_RENDERBOX"]
let renderBoxCDefines = sharedCDefines + ["OPENSWIFTUI_RENDERBOX=1"]

let darwinPrivateFrameworksPath = "Tuist/.build/checkouts/DarwinPrivateFrameworks"

func sharedSettings() -> SettingsDictionary {
    [
        "SWIFT_VERSION": "5",
        "OTHER_SWIFT_FLAGS": .array(sharedSwiftFlags + ["$(inherited)"]),
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": .array(swiftActiveCompilationConditions + ["$(inherited)"]),
        "GCC_PREPROCESSOR_DEFINITIONS": .array(sharedCDefines + ["$(inherited)"]),
        "CLANG_ENABLE_MODULES": "YES",
        "OTHER_CFLAGS": .array(["-Wno-error=return-type", "$(inherited)"]),
        "OTHER_CPLUSPLUSFLAGS": .array(["-fcxx-modules", "$(inherited)"]),
        "IPHONEOS_DEPLOYMENT_TARGET": "18.0",
        "MACOSX_DEPLOYMENT_TARGET": "15.0",
        "TVOS_DEPLOYMENT_TARGET": "18.0",
        "WATCHOS_DEPLOYMENT_TARGET": "10.0",
        "XROS_DEPLOYMENT_TARGET": "2.0",
    ]
}

// MARK: - Project

let project = Project(
    name: "OpenSwiftUI",
    settings: .settings(
        base: sharedSettings(),
        configurations: [
            .debug(name: "Debug", xcconfig: "availability-macros.xcconfig"),
            .release(name: "Release", xcconfig: "availability-macros.xcconfig"),
        ]
    ),
    targets: [
        // OpenSwiftUIMacros - macro target (macOS only)
        .target(
            name: "OpenSwiftUIMacros",
            destinations: [.mac],
            product: .macro,
            bundleId: "org.openswiftui.OpenSwiftUIMacros",
            sources: "Sources/OpenSwiftUIMacros/**",
            dependencies: [
                .external(name: "SwiftSyntaxMacros"),
                .external(name: "SwiftCompilerPlugin"),
            ],
            settings: .settings(base: [
                "SWIFT_VERSION": "5",
                "OTHER_SWIFT_FLAGS": .array(sharedSwiftFlags + ["-package-name", "OpenSwiftUI", "$(inherited)"]),
            ])
        ),

        // OpenSwiftUI_SPI - static framework
        .target(
            name: "OpenSwiftUI_SPI",
            destinations: destinations,
            product: .staticFramework,
            bundleId: "org.openswiftui.OpenSwiftUI-SPI",
            sources: "Sources/OpenSwiftUI_SPI/**",
            headers: .headers(public: "Sources/OpenSwiftUI_SPI/**/*.h"),
            dependencies: [
                .external(name: "CoreUI"),
                .external(name: "OpenRenderBox"),
            ],
            settings: .settings(base: sharedSettings().merging([
                "OTHER_LDFLAGS": .array(["-lMobileGestalt", "$(inherited)"]),
                "MODULEMAP_FILE": "$(SRCROOT)/Sources/OpenSwiftUI_SPI/module.modulemap",
                "HEADER_SEARCH_PATHS": .array([
                    "$(SRCROOT)/Sources/OpenSwiftUI_SPI",
                    "$(SRCROOT)/Tuist/.build/checkouts/OpenRenderBox/Sources/OpenRenderBoxCxx/include",
                    "$(inherited)",
                ]),
            ]) { _, new in new })
        ),

        // COpenSwiftUI - static framework
        .target(
            name: "COpenSwiftUI",
            destinations: destinations,
            product: .staticFramework,
            bundleId: "org.openswiftui.COpenSwiftUI",
            sources: "Sources/COpenSwiftUI/**",
            headers: .headers(public: "Sources/COpenSwiftUI/**/*.h"),
            dependencies: [],
            settings: .settings(base: sharedSettings().merging([
                "HEADER_SEARCH_PATHS": .array(["$(SRCROOT)/Sources/OpenSwiftUI_SPI", "$(SRCROOT)/Sources/COpenSwiftUI", "$(inherited)"]),
                "MODULEMAP_FILE": "$(SRCROOT)/Sources/COpenSwiftUI/module.modulemap",
            ]) { _, new in new })
        ),

        // OpenSwiftUICore - static framework
        .target(
            name: "OpenSwiftUICore",
            destinations: destinations,
            product: .staticFramework,
            bundleId: "org.openswiftui.OpenSwiftUICore",
            sources: "Sources/OpenSwiftUICore/**",
            dependencies: [
                .target(name: "OpenSwiftUI_SPI"),
                .target(name: "OpenSwiftUIMacros"),
                .external(name: "OpenCoreGraphicsShims"),
                .external(name: "OpenQuartzCoreShims"),
                .external(name: "OpenAttributeGraphShims"),
                .external(name: "OpenRenderBoxShims"),
                .external(name: "OpenObservation"),
                .external(name: "SFSymbols"),
            ],
            settings: .settings(base: sharedSettings().merging([
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": .array(renderBoxSwiftConditions + ["$(inherited)"]),
                "GCC_PREPROCESSOR_DEFINITIONS": .array(renderBoxCDefines + ["$(inherited)"]),
            ]) { _, new in new })
        ),

        // OpenSwiftUI - dynamic framework (the XCFramework product)
        .target(
            name: "OpenSwiftUI",
            destinations: destinations,
            product: .framework,
            bundleId: "org.openswiftui.OpenSwiftUI",
            sources: "Sources/OpenSwiftUI/**",
            dependencies: [
                .target(name: "OpenSwiftUICore"),
                .target(name: "COpenSwiftUI"),
                .target(name: "OpenSwiftUISymbolDualTestsSupport"),
                .external(name: "OpenCoreGraphicsShims"),
                .external(name: "OpenQuartzCoreShims"),
                .external(name: "OpenAttributeGraphShims"),
                .external(name: "OpenRenderBoxShims"),
            ],
            settings: .settings(base: sharedSettings().merging([
                "OTHER_LDFLAGS": .array(["-framework", "CoreServices", "-lMobileGestalt", "$(inherited)"]),
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": .array(renderBoxSwiftConditions + ["$(inherited)"]),
                "GCC_PREPROCESSOR_DEFINITIONS": .array(renderBoxCDefines + ["$(inherited)"]),
                "BUILD_LIBRARY_FOR_DISTRIBUTION": "YES",
            ]) { _, new in new })
        ),

        // OpenSwiftUIExtension - static framework
        .target(
            name: "OpenSwiftUIExtension",
            destinations: destinations,
            product: .staticFramework,
            bundleId: "org.openswiftui.OpenSwiftUIExtension",
            sources: "Sources/OpenSwiftUIExtension/**",
            dependencies: [
                .target(name: "OpenSwiftUI"),
            ],
            settings: .settings(base: sharedSettings())
        ),

        // OpenSwiftUIBridge - static framework
        .target(
            name: "OpenSwiftUIBridge",
            destinations: destinations,
            product: .staticFramework,
            bundleId: "org.openswiftui.OpenSwiftUIBridge",
            sources: [
                "Sources/OpenSwiftUIBridge/Bridgeable.swift",
                "Sources/OpenSwiftUIBridge/SwiftUI/**",
            ],
            dependencies: [
                .target(name: "OpenSwiftUI"),
            ],
            settings: .settings(base: sharedSettings())
        ),

        // OpenSwiftUISymbolDualTestsSupport - static framework
        .target(
            name: "OpenSwiftUISymbolDualTestsSupport",
            destinations: destinations,
            product: .staticFramework,
            bundleId: "org.openswiftui.OpenSwiftUISymbolDualTestsSupport",
            sources: "Sources/OpenSwiftUISymbolDualTestsSupport/**",
            dependencies: [
                .external(name: "SymbolLocator"),
            ],
            settings: .settings(base: sharedSettings().merging([
                "HEADER_SEARCH_PATHS": .array(["$(SRCROOT)/Sources/OpenSwiftUI_SPI", "$(inherited)"]),
                "MODULEMAP_FILE": "$(SRCROOT)/Sources/OpenSwiftUISymbolDualTestsSupport/module.modulemap",
            ]) { _, new in new })
        ),
    ]
)
