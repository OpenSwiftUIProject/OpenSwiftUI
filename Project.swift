import ProjectDescription

// MARK: - Constants

let releaseVersion = "2024"

let destinations: Destinations = [.iPhone, .iPad, .mac]
// TODO: Add tvOS, watchOS, visionOS support
// let destinations: Destinations = [.iPhone, .iPad, .mac, .macCatalyst, .appleTV, .appleWatch, .appleVision]

let deploymentTargets: DeploymentTargets = .multiplatform(
    iOS: "18.0",
    macOS: "15.0"
)

// MARK: - Shared Settings

let sharedSwiftFlags: [String] = [
    "-DOPENSWIFTUI_RENDERBOX",
]

let sharedActiveCompilationConditions: [String] = [
    "OPENSWIFTUI_RENDERBOX",
]

// MARK: - Modulemap Strategy
//
// Problem:
// The SPM module.modulemap at Sources/OpenSwiftUI_SPI/ defines 12 standalone modules
// (CoreFoundation_Private, UIFoundation_Private, etc.) alongside the main OpenSwiftUI_SPI
// module. These private-framework-named modules conflict with system module resolution
// when Xcode's explicit module precompilation tries to build them independently.
//
// Solution:
// 1. Before building, hide the SPM modulemap: Scripts/hide_spi_modulemap.sh hide
//    This prevents Clang auto-discovery from header search paths.
// 2. Use Configs/OpenSwiftUI_SPI.modulemap (relocated copy with relative paths) as
//    MODULEMAP_FILE for the SPI target and via -Xcc -fmodule-map-file= for consumers.
// 3. Set CLANG_ENABLE_EXPLICIT_MODULES=NO on C/ObjC targets that compile SPI headers,
//    falling back to implicit module compilation (matching SPM behavior).
// 4. After building, restore: Scripts/hide_spi_modulemap.sh restore
//
// The build_xcframework_tuist.sh script handles hide/restore automatically via trap.
// For interactive Xcode use: run Scripts/hide_spi_modulemap.sh hide before opening.

let spiModuleMapFlag = "-fmodule-map-file=$(SRCROOT)/Configs/OpenSwiftUI_SPI.modulemap"
let cOpenSwiftUIModuleMapFlag = "-fmodule-map-file=$(SRCROOT)/Sources/COpenSwiftUI/module.modulemap"

// MARK: - Targets

let macrosTarget: Target = .target(
    name: "OpenSwiftUIMacros",
    destinations: [.mac],
    product: .macro,
    bundleId: "org.OpenSwiftUIProject.OpenSwiftUIMacros",
    sources: ["Sources/OpenSwiftUIMacros/**"],
    dependencies: [
        .external(name: "SwiftSyntax"),
        .external(name: "SwiftSyntaxMacros"),
        .external(name: "SwiftCompilerPlugin"),
    ],
    settings: .settings(
        base: [
            "MACOSX_DEPLOYMENT_TARGET": "15.0",
            "SWIFT_VERSION": "5.0",
            "OTHER_SWIFT_FLAGS": "$(inherited) -package-name OpenSwiftUI",
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) OPENSWIFTUI",
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: "availability-macros.xcconfig"),
            .release(name: "Release", xcconfig: "availability-macros.xcconfig"),
        ],
        defaultSettings: .none
    )
)

let spiTarget: Target = .target(
    name: "OpenSwiftUI_SPI",
    destinations: destinations,
    product: .staticFramework,
    bundleId: "org.OpenSwiftUIProject.OpenSwiftUI-SPI",
    deploymentTargets: deploymentTargets,
    sources: [
        .glob("Sources/OpenSwiftUI_SPI/**",
              excluding: ["Sources/OpenSwiftUI_SPI/module.modulemap"]),
    ],
    dependencies: [
        .external(name: "CoreUI"),
        .external(name: "OpenRenderBoxShims"),
    ],
    settings: .settings(
        base: [
            "OTHER_LDFLAGS": ["-weak-lMobileGestalt"],
            "DEFINES_MODULE": "NO",
            // Relocated modulemap — the original at Sources/OpenSwiftUI_SPI/module.modulemap
            // must be hidden before build (see Modulemap Strategy above).
            "MODULEMAP_FILE": "$(SRCROOT)/Configs/OpenSwiftUI_SPI.modulemap",
            // Disable explicit module precompilation: the SPI sub-modules'
            // umbrella headers transitively include system headers that fail
            // under isolated explicit module compilation. Implicit modules
            // (matching SPM behavior) avoid this.
            "CLANG_ENABLE_EXPLICIT_MODULES": "NO",
            "HEADER_SEARCH_PATHS": [
                "$(inherited)",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Overlay",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Overlay/CoreGraphics",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims/QuartzCore",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims/CoreFoundation",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims/CoreGraphics",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims/CoreText",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims/CoreUI",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims/CSymbols",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims/dyld",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims/GraphicsServices",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims/MobileGestalt",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims/UIFoundation",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Shims/kdebug",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI/Util",
            ],
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/Common.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/Common.xcconfig"),
        ],
        defaultSettings: .none
    )
)

let cOpenSwiftUITarget: Target = .target(
    name: "COpenSwiftUI",
    destinations: destinations,
    product: .staticFramework,
    bundleId: "org.OpenSwiftUIProject.COpenSwiftUI",
    deploymentTargets: deploymentTargets,
    sources: [
        .glob("Sources/COpenSwiftUI/**",
              excluding: ["Sources/COpenSwiftUI/module.modulemap"]),
    ],
    headers: .headers(
        project: [
            "Sources/COpenSwiftUI/Overlay/**/*.h",
            "Sources/COpenSwiftUI/Shims/**/*.h",
            "Sources/COpenSwiftUI/Util/**/*.h",
        ]
    ),
    settings: .settings(
        base: [
            "DEFINES_MODULE": "NO",
            "MODULEMAP_FILE": "$(SRCROOT)/Sources/COpenSwiftUI/module.modulemap",
            // Disable explicit modules — COpenSwiftUI headers include SPI headers
            // which trigger the same system module conflicts (see SPI target).
            "CLANG_ENABLE_EXPLICIT_MODULES": "NO",
            "HEADER_SEARCH_PATHS": [
                "$(inherited)",
                "$(SRCROOT)/Sources/COpenSwiftUI",
                "$(SRCROOT)/Sources/COpenSwiftUI/Overlay",
                "$(SRCROOT)/Sources/COpenSwiftUI/Shims",
                "$(SRCROOT)/Sources/COpenSwiftUI/Util",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI",
            ],
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/Common.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/Common.xcconfig"),
        ],
        defaultSettings: .none
    )
)

let coreTarget: Target = .target(
    name: "OpenSwiftUICore",
    destinations: destinations,
    product: .staticFramework,
    bundleId: "org.OpenSwiftUIProject.OpenSwiftUICore",
    deploymentTargets: deploymentTargets,
    sources: ["Sources/OpenSwiftUICore/**"],
    dependencies: [
        .target(name: "OpenSwiftUI_SPI"),
        .target(name: "OpenSwiftUIMacros"),
        .external(name: "OpenAttributeGraphShims"),
        .external(name: "OpenCoreGraphicsShims"),
        .external(name: "OpenQuartzCoreShims"),
        .external(name: "OpenRenderBoxShims"),
        .external(name: "OpenObservation"),
        .external(name: "CoreUI"),
        .external(name: "SFSymbols"),
    ],
    settings: .settings(
        base: [
            "OTHER_SWIFT_FLAGS": .array(
                ["$(inherited)"] + sharedSwiftFlags + [
                    "-Xcc", spiModuleMapFlag,
                    "-Xcc", cOpenSwiftUIModuleMapFlag,
                ]
            ),
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": .array(
                ["$(inherited)"] + sharedActiveCompilationConditions
            ),
            // Disable explicit modules for Swift's embedded Clang — the SPI
            // sub-modules (CoreUI_Private, UIFoundation_Private, etc.) fail
            // under explicit precompilation (same reason as C/ObjC targets).
            "CLANG_ENABLE_EXPLICIT_MODULES": "NO",
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/Common.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/Common.xcconfig"),
        ],
        defaultSettings: .none
    )
)

let openSwiftUISwiftFlags: [String] = ["$(inherited)"] + sharedSwiftFlags + [
    "-Xcc", spiModuleMapFlag,
    "-Xcc", cOpenSwiftUIModuleMapFlag,
]

// Disable public re-exports of SPI sub-modules (UIFoundation_Private,
// etc.) from the OpenSwiftUI module interface. These modules can't
// be fully resolved during interface generation due to system module
// conflicts (NSAttributedStringDocumentType from AppKit/UIKit).
// The SPM xcframework build also sets this flag.
let openSwiftUICompilationConditions: [String] =
    ["$(inherited)"] + sharedActiveCompilationConditions + ["OPENSWIFTUI_XCFRAMEWORK_BUILD"]

let openSwiftUITarget: Target = .target(
    name: "OpenSwiftUI",
    destinations: destinations,
    product: .framework,
    bundleId: "org.OpenSwiftUIProject.OpenSwiftUI",
    deploymentTargets: deploymentTargets,
    sources: ["Sources/OpenSwiftUI/**"],
    dependencies: [
        .target(name: "OpenSwiftUICore"),
        .target(name: "COpenSwiftUI"),
        .target(name: "OpenSwiftUISymbolDualTestsSupport"),
        .external(name: "OpenAttributeGraphShims"),
        .external(name: "OpenCoreGraphicsShims"),
        .external(name: "OpenQuartzCoreShims"),
        .external(name: "OpenRenderBoxShims"),
    ],
    settings: .settings(
        base: [
            "OTHER_SWIFT_FLAGS": .array(openSwiftUISwiftFlags),
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": .array(openSwiftUICompilationConditions),
            // Disable explicit modules — imports SPI sub-modules that fail
            // under explicit precompilation.
            "CLANG_ENABLE_EXPLICIT_MODULES": "NO",
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/OpenSwiftUI.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/OpenSwiftUI.xcconfig"),
        ],
        defaultSettings: .none
    )
)

let extensionTarget: Target = .target(
    name: "OpenSwiftUIExtension",
    destinations: destinations,
    product: .staticFramework,
    bundleId: "org.OpenSwiftUIProject.OpenSwiftUIExtension",
    deploymentTargets: deploymentTargets,
    sources: ["Sources/OpenSwiftUIExtension/**"],
    dependencies: [
        .target(name: "OpenSwiftUI"),
    ],
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/Common.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/Common.xcconfig"),
        ],
        defaultSettings: .none
    )
)

let bridgeTarget: Target = .target(
    name: "OpenSwiftUIBridge",
    destinations: destinations,
    product: .staticFramework,
    bundleId: "org.OpenSwiftUIProject.OpenSwiftUIBridge",
    deploymentTargets: deploymentTargets,
    sources: [
        "Sources/OpenSwiftUIBridge/Bridgeable.swift",
        "Sources/OpenSwiftUIBridge/SwiftUI/**",
    ],
    dependencies: [
        .target(name: "OpenSwiftUI"),
    ],
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/Common.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/Common.xcconfig"),
        ],
        defaultSettings: .none
    )
)

let symbolDualTestsSupportTarget: Target = .target(
    name: "OpenSwiftUISymbolDualTestsSupport",
    destinations: destinations,
    product: .staticFramework,
    bundleId: "org.OpenSwiftUIProject.OpenSwiftUISymbolDualTestsSupport",
    deploymentTargets: deploymentTargets,
    sources: ["Sources/OpenSwiftUISymbolDualTestsSupport/**"],
    dependencies: [
        .external(name: "SymbolLocator"),
    ],
    settings: .settings(
        base: [
            "DEFINES_MODULE": "NO",
            "MODULEMAP_FILE": "$(SRCROOT)/Sources/OpenSwiftUISymbolDualTestsSupport/module.modulemap",
            // Disable explicit modules — SPI headers included via OpenSwiftUIBase.h
            "CLANG_ENABLE_EXPLICIT_MODULES": "NO",
            "HEADER_SEARCH_PATHS": [
                "$(inherited)",
                "$(SRCROOT)/Sources/OpenSwiftUI_SPI",
            ],
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/Common.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/Common.xcconfig"),
        ],
        defaultSettings: .none
    )
)

// MARK: - Project

let project = Project(
    name: "OpenSwiftUI",
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "availability-macros.xcconfig"),
            .release(name: "Release", xcconfig: "availability-macros.xcconfig"),
        ],
        defaultSettings: .none
    ),
    targets: [
        macrosTarget,
        spiTarget,
        cOpenSwiftUITarget,
        coreTarget,
        openSwiftUITarget,
        extensionTarget,
        bridgeTarget,
        symbolDualTestsSupportTarget,
    ]
)
