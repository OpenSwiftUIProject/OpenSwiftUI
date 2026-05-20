import ProjectDescription

// MARK: - Constants

let destinations: Destinations = [.iPhone, .iPad, .mac, .appleVision]

let deploymentTargets = DeploymentTargets.multiplatform(
    iOS: "18.0",
    macOS: "15.0",
    visionOS: "2.0"
)

let openSwiftUIDebug = ConfigurationName.configuration("OpenSwiftUIDebug")
let openSwiftUIRelease = ConfigurationName.configuration("OpenSwiftUIRelease")
let swiftUIDebug = ConfigurationName.configuration("SwiftUIDebug")
let swiftUIRelease = ConfigurationName.configuration("SwiftUIRelease")

let projectConfigurations: [Configuration] = [
    .debug(name: swiftUIDebug, xcconfig: "../Configurations/Shared/SwiftUI-debug.xcconfig"),
    .release(name: swiftUIRelease, xcconfig: "../Configurations/Shared/SwiftUI-release.xcconfig"),
    .debug(name: openSwiftUIDebug, xcconfig: "../Configurations/Shared/OpenSwiftUI-debug.xcconfig"),
    .release(name: openSwiftUIRelease, xcconfig: "../Configurations/Shared/OpenSwiftUI-release.xcconfig"),
]

let swiftUIModeSettings: SettingsDictionary = [
    "OPENSWIFTUI_TARGET_BUNDLE_ID": "SwiftUI",
    "SWIFT_VERSION": "5.0",
]

let openSwiftUIModeSettings: SettingsDictionary = [
    "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) OPENSWIFTUI=1",
    "OPENSWIFTUI_TARGET_BUNDLE_ID": "OpenSwiftUI",
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) OPENSWIFTUI",
    "SWIFT_VERSION": "5.0",
]

let debugModeSettings: SettingsDictionary = [
    "ENABLE_TESTABILITY": "YES",
    "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) DEBUG=1",
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG",
    "SWIFT_COMPILATION_MODE": "singlefile",
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
]

let openSwiftUIDebugModeSettings = openSwiftUIModeSettings.merging([
    "ENABLE_TESTABILITY": "YES",
    "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) OPENSWIFTUI=1 DEBUG=1",
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) OPENSWIFTUI DEBUG",
    "SWIFT_COMPILATION_MODE": "singlefile",
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
])

func targetConfigurations(_ xcconfig: Path) -> [Configuration] {
    [
        .debug(name: swiftUIDebug, settings: swiftUIModeSettings.merging(debugModeSettings), xcconfig: xcconfig),
        .release(name: swiftUIRelease, settings: swiftUIModeSettings, xcconfig: xcconfig),
        .debug(name: openSwiftUIDebug, settings: openSwiftUIDebugModeSettings, xcconfig: xcconfig),
        .release(name: openSwiftUIRelease, settings: openSwiftUIModeSettings, xcconfig: xcconfig),
    ]
}

func settings(base: SettingsDictionary = [:], xcconfig: Path) -> Settings {
    .settings(
        base: base,
        configurations: targetConfigurations(xcconfig),
        defaultSettings: .none,
        defaultConfiguration: "OpenSwiftUIDebug"
    )
}

let commonAppSettings: SettingsDictionary = [
    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
    "CODE_SIGN_STYLE": "Automatic",
    "DEVELOPMENT_TEAM": "",
    "ENABLE_PREVIEWS": "YES",
    "GENERATE_INFOPLIST_FILE": "YES",
    "INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphoneos*]": "YES",
    "INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphonesimulator*]": "YES",
    "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphoneos*]": "YES",
    "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphonesimulator*]": "YES",
    "INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphoneos*]": "YES",
    "INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphonesimulator*]": "YES",
    "INFOPLIST_KEY_UIStatusBarStyle[sdk=iphoneos*]": "UIStatusBarStyleDefault",
    "INFOPLIST_KEY_UIStatusBarStyle[sdk=iphonesimulator*]": "UIStatusBarStyleDefault",
    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone": "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
    "FRAMEWORK_SEARCH_PATHS": [
        "$(inherited)",
        "$(BUILD_DIR)/Debug$(EFFECTIVE_PLATFORM_NAME)",
        "$(BUILD_DIR)/Release$(EFFECTIVE_PLATFORM_NAME)",
    ],
    "LD_RUNPATH_SEARCH_PATHS": [
        "@executable_path/Frameworks",
    ],
    "LD_RUNPATH_SEARCH_PATHS[sdk=macosx*]": "@executable_path/../Frameworks",
    "LIBRARY_SEARCH_PATHS": [
        "$(inherited)",
        "$(BUILD_DIR)/Debug$(EFFECTIVE_PLATFORM_NAME)",
        "$(BUILD_DIR)/Release$(EFFECTIVE_PLATFORM_NAME)",
    ],
    "SDKROOT": "auto",
    "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator macosx xros xrsimulator",
    "SUPPORTS_MACCATALYST": "NO",
    "SWIFT_EMIT_LOC_STRINGS": "YES",
    "SWIFT_INCLUDE_PATHS": [
        "$(inherited)",
        "$(SRCROOT)/Modules/Platform/cocoa",
    ],
    "SWIFT_VERSION": "5.0",
    "TARGETED_DEVICE_FAMILY": "1,2,7",
]

let exampleSettings = commonAppSettings.merging([
    "ENABLE_HARDENED_RUNTIME": "YES",
])

let hostingExampleSettings = commonAppSettings.merging([
    "CLANG_ENABLE_MODULES": "YES",
    "GENERATE_INFOPLIST_FILE": "YES",
    "INFOPLIST_FILE": "HostingExample/Info.plist",
    "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
    "INFOPLIST_KEY_UILaunchStoryboardName": "LaunchScreen",
    "INFOPLIST_KEY_UIMainStoryboardFile": "Main",
    "LD_RUNPATH_SEARCH_PATHS": [
        "$(inherited)",
        "@executable_path/Frameworks",
    ],
    "REGISTER_APP_GROUPS": "NO",
    "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD": "NO",
    "SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD": "NO",
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
    "XROS_DEPLOYMENT_TARGET": "2.0",
])

let testingHostSettings = commonAppSettings.merging([
    "REGISTER_APP_GROUPS": "YES",
])

let uiTestsSettings: SettingsDictionary = [
    "BUNDLE_LOADER": "$(TEST_HOST)",
    "CODE_SIGN_STYLE": "Automatic",
    "FRAMEWORK_SEARCH_PATHS": [
        "$(inherited)",
        "$(BUILD_DIR)/Debug$(EFFECTIVE_PLATFORM_NAME)",
        "$(BUILD_DIR)/Release$(EFFECTIVE_PLATFORM_NAME)",
    ],
    "GENERATE_INFOPLIST_FILE": "YES",
    "LIBRARY_SEARCH_PATHS": [
        "$(inherited)",
        "$(BUILD_DIR)/Debug$(EFFECTIVE_PLATFORM_NAME)",
        "$(BUILD_DIR)/Release$(EFFECTIVE_PLATFORM_NAME)",
    ],
    "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
    "SDKROOT": "auto",
    "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator macosx xros xrsimulator",
    "SUPPORTS_MACCATALYST": "NO",
    "SWIFT_EMIT_LOC_STRINGS": "NO",
    "SWIFT_INCLUDE_PATHS": [
        "$(inherited)",
        "$(SRCROOT)/Modules/Platform/cocoa",
    ],
    "SWIFT_OBJC_BRIDGING_HEADER": "OpenSwiftUIUITests/OpenSwiftUIUITests-Bridging-Header.h",
    "SWIFT_VERSION": "5.0",
    "TARGETED_DEVICE_FAMILY": "1,2,7",
    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/TestingHost.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/TestingHost",
]

let sharedSources: SourceFilesList = [
    "Shared/**/*.swift",
]

let sharedResources: ResourceFileElements = [
    "Shared/Assets/Assets.xcassets",
    "Shared/Assets/images/**",
]

let privateFrameworkDependencies: [TargetDependency] = [
    .external(name: "AttributeGraph"),
    .external(name: "RenderBox"),
    .external(name: "CoreUI"),
    .external(name: "CoreSVG"),
    .external(name: "SFSymbols"),
    .external(name: "BacklightServices", condition: .when([.ios, .visionos])),
]

let appDependencies: [TargetDependency] = [
    .external(name: "OpenSwiftUI"),
    .external(name: "Equatable"),
] + privateFrameworkDependencies

let testArguments = Arguments.arguments(
    environmentVariables: [
        "SWIFTUI_PRINT_TREE": .environmentVariable(value: "1", isEnabled: false),
    ]
)

let launchArguments = Arguments.arguments(
    environmentVariables: [
        "SWIFTUI_PRINT_TREE": .environmentVariable(value: "1", isEnabled: false),
    ]
)

let openSwiftUILaunchArguments = Arguments.arguments(
    environmentVariables: [
        "OPENSWIFTUI_PRINT_TREE": .environmentVariable(value: "1", isEnabled: false),
        "SWIFTUI_PRINT_TREE": .environmentVariable(value: "1", isEnabled: false),
    ]
)

let openSwiftUIHostingLaunchArguments = Arguments.arguments(
    environmentVariables: [
        "SWIFTUI_PRINT_TREE": .environmentVariable(value: "1", isEnabled: false),
        "OPENSWIFTUI_PRINT_TREE": .environmentVariable(value: "1", isEnabled: false),
    ]
)

let swiftUIHostingLaunchArguments = Arguments.arguments(
    environmentVariables: [
        "SWIFTUI_PRINT_TREE": .environmentVariable(value: "1", isEnabled: false),
        "AG_PRINT_CYCLES": .environmentVariable(value: "2", isEnabled: false),
        "AG_TRAP_CYCLES": .environmentVariable(value: "1", isEnabled: false),
        "OPENSWIFTUI_PRINT_TREE": .environmentVariable(value: "1", isEnabled: false),
    ]
)

// MARK: - Targets

let targets: [Target] = [
    .target(
        name: "Example",
        destinations: destinations,
        product: .app,
        bundleId: "org.OpenSwiftUIProject.$(OPENSWIFTUI_TARGET_BUNDLE_ID).Example",
        deploymentTargets: deploymentTargets,
        infoPlist: .extendingDefault(with: [:]),
        sources: [
            "Example/**/*.swift",
            "Shared/**/*.swift",
        ],
        resources: sharedResources,
        entitlements: "Example/Example.entitlements",
        dependencies: appDependencies,
        settings: settings(base: exampleSettings, xcconfig: "../Configurations/Example.xcconfig")
    ),
    .target(
        name: "HostingExample",
        destinations: destinations,
        product: .app,
        bundleId: "org.OpenSwiftUIProject.$(OPENSWIFTUI_TARGET_BUNDLE_ID).HostingExample",
        deploymentTargets: deploymentTargets,
        infoPlist: "HostingExample/Info.plist",
        sources: [
            .glob("HostingExample/**/*.swift"),
            .glob("Shared/**/*.swift"),
        ],
        resources: [
            "HostingExample/Base.lproj/**",
            "Shared/Assets/Assets.xcassets",
            "Shared/Assets/images/**",
        ],
        dependencies: appDependencies,
        settings: settings(base: hostingExampleSettings, xcconfig: "../Configurations/HostingExample.xcconfig")
    ),
    .target(
        name: "TestingHost",
        destinations: destinations,
        product: .app,
        bundleId: "org.OpenSwiftUIProject.$(OPENSWIFTUI_TARGET_BUNDLE_ID).TestingHost",
        deploymentTargets: deploymentTargets,
        infoPlist: .extendingDefault(with: [:]),
        sources: [
            "TestingHost/**/*.swift",
            "Shared/**/*.swift",
        ],
        resources: sharedResources,
        entitlements: "TestingHost/TestingHost.entitlements",
        dependencies: appDependencies,
        settings: settings(base: testingHostSettings, xcconfig: "../Configurations/TestingHost.xcconfig")
    ),
    .target(
        name: "OpenSwiftUIUITests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "org.OpenSwiftUIProject.$(OPENSWIFTUI_TARGET_BUNDLE_ID).OpenSwiftUIUITests",
        deploymentTargets: deploymentTargets,
        infoPlist: .default,
        sources: [
            "OpenSwiftUIUITests/**/*.swift",
            "OpenSwiftUIUITests/**/*.m",
            "OpenSwiftUIUITests/**/*.c",
        ],
        dependencies: [
            .target(name: "TestingHost"),
            .external(name: "SnapshotTesting"),
            .external(name: "Equatable"),
        ] + privateFrameworkDependencies,
        settings: settings(base: uiTestsSettings, xcconfig: "../Configurations/OpenSwiftUIUITests.xcconfig")
    ),
]

// MARK: - Schemes

func scheme(
    name: String,
    target: TargetReference,
    debugConfiguration: ConfigurationName,
    releaseConfiguration: ConfigurationName,
    testableTargets: [TestableTarget] = [
        .testableTarget(target: "OpenSwiftUIUITests", parallelization: .enabled),
    ],
    includeTestAction: Bool = true,
    runArguments: Arguments = launchArguments
) -> Scheme {
    .scheme(
        name: name,
        shared: true,
        buildAction: .buildAction(targets: [target]),
        testAction: includeTestAction
            ? .targets(
                testableTargets,
                arguments: testArguments,
                configuration: debugConfiguration,
                expandVariableFromTarget: "TestingHost"
            )
            : nil,
        runAction: .runAction(
            configuration: debugConfiguration,
            executable: .executable(target),
            arguments: runArguments
        ),
        archiveAction: .archiveAction(configuration: releaseConfiguration),
        profileAction: .profileAction(
            configuration: releaseConfiguration,
            executable: .executable(target)
        ),
        analyzeAction: .analyzeAction(configuration: debugConfiguration)
    )
}

let schemes: [Scheme] = [
    scheme(
        name: "OSUI_Example",
        target: "Example",
        debugConfiguration: openSwiftUIDebug,
        releaseConfiguration: openSwiftUIRelease,
        runArguments: openSwiftUILaunchArguments
    ),
    scheme(
        name: "SUI_Example",
        target: "Example",
        debugConfiguration: swiftUIDebug,
        releaseConfiguration: swiftUIRelease
    ),
    scheme(
        name: "OSUI_HostingExample",
        target: "HostingExample",
        debugConfiguration: openSwiftUIDebug,
        releaseConfiguration: openSwiftUIRelease,
        testableTargets: [],
        runArguments: openSwiftUIHostingLaunchArguments
    ),
    scheme(
        name: "SUI_HostingExample",
        target: "HostingExample",
        debugConfiguration: swiftUIDebug,
        releaseConfiguration: swiftUIRelease,
        testableTargets: [],
        runArguments: swiftUIHostingLaunchArguments
    ),
    scheme(
        name: "OSUI_TestingHost",
        target: "TestingHost",
        debugConfiguration: openSwiftUIDebug,
        releaseConfiguration: openSwiftUIRelease,
        includeTestAction: false
    ),
    scheme(
        name: "SUI_TestingHost",
        target: "TestingHost",
        debugConfiguration: swiftUIDebug,
        releaseConfiguration: swiftUIRelease,
        includeTestAction: false
    ),
    .scheme(
        name: "OSUI_UITests",
        shared: true,
        buildAction: .buildAction(targets: ["OpenSwiftUIUITests"]),
        testAction: .targets(
            [.testableTarget(target: "OpenSwiftUIUITests", parallelization: .enabled)],
            arguments: testArguments,
            configuration: openSwiftUIDebug,
            expandVariableFromTarget: "TestingHost"
        ),
        analyzeAction: .analyzeAction(configuration: openSwiftUIDebug)
    ),
    .scheme(
        name: "SUI_UITests",
        shared: true,
        buildAction: .buildAction(targets: ["OpenSwiftUIUITests"]),
        testAction: .targets(
            [.testableTarget(target: "OpenSwiftUIUITests", parallelization: .enabled)],
            arguments: testArguments,
            configuration: swiftUIDebug,
            expandVariableFromTarget: "TestingHost"
        ),
        analyzeAction: .analyzeAction(configuration: swiftUIDebug)
    ),
]

// MARK: - Project

let project = Project(
    name: "Example",
    options: .options(
        automaticSchemesOptions: .disabled,
        developmentRegion: "en"
    ),
    settings: .settings(
        configurations: projectConfigurations,
        defaultSettings: .none,
        defaultConfiguration: "OpenSwiftUIDebug"
    ),
    targets: targets,
    schemes: schemes,
    additionalFiles: [
        "../Configurations/**",
        "Modules/**",
        "ReferenceImages/**",
        "OpenSwiftUIUITests/OpenSwiftUIUITests.xctestplan",
    ]
)
