import Foundation
import ProjectDescription

// MARK: - EnvManager

public protocol EnvironmentProvider {
    func value(forKey key: String) -> String?
}

public struct ProcessInfoEnvironmentProvider: EnvironmentProvider {
    public init() {}

    public func value(forKey key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
}

public final class EnvManager {
    nonisolated(unsafe) public static let shared = EnvManager()

    private var domains: [String] = []
    private var environmentProvider: EnvironmentProvider

    /// When true, append raw key as fallback when searching in domains
    public var includeFallbackToRawKey: Bool = false

    private init() {
        self.environmentProvider = ProcessInfoEnvironmentProvider()
    }

    /// Set a custom environment provider (useful for testing)
    public func setEnvironmentProvider(_ provider: EnvironmentProvider) {
        self.environmentProvider = provider
    }

    /// Reset domains and environment provider (useful for testing)
    public func reset() {
        domains.removeAll()
        includeFallbackToRawKey = false
        self.environmentProvider = ProcessInfoEnvironmentProvider()
    }

    public func register(domain: String) {
        domains.append(domain)
    }

    public func withDomain<T>(_ domain: String, perform: () throws -> T) rethrows -> T {
        domains.append(domain)
        defer { domains.removeAll { $0 == domain } }
        return try perform()
    }

    private func envValue<T>(rawKey: String, default defaultValue: T?, searchInDomain: Bool, parser: (String) -> T?) -> T? {
        func parseEnvValue(_ key: String) -> (String, T)? {
            guard let value = environmentProvider.value(forKey: key),
                  let result = parser(value) else { return nil }
            return (value, result)
        }
        var keys: [String] = searchInDomain ? domains.map { "\($0.uppercased())_\(rawKey)" } : []
        if !searchInDomain || includeFallbackToRawKey {
            keys.append(rawKey)
        }
        for key in keys {
            if let (value, result) = parseEnvValue(key) {
                print("[Env] \(key)=\(value) -> \(result)")
                return result
            }
        }
        let primaryKey = keys.first ?? rawKey
        if let defaultValue {
            print("[Env] \(primaryKey) not set -> \(defaultValue)(default)")
        }
        return defaultValue
    }

    public func envBoolValue(rawKey: String, default defaultValue: Bool? = nil, searchInDomain: Bool) -> Bool? {
        envValue(rawKey: rawKey, default: defaultValue, searchInDomain: searchInDomain) { value in
            switch value {
            case "1": true
            case "0": false
            default: nil
            }
        }
    }

    public func envIntValue(rawKey: String, default defaultValue: Int? = nil, searchInDomain: Bool) -> Int? {
        envValue(rawKey: rawKey, default: defaultValue, searchInDomain: searchInDomain) { Int($0) }
    }

    public func envStringValue(rawKey: String, default defaultValue: String? = nil, searchInDomain: Bool) -> String? {
        envValue(rawKey: rawKey, default: defaultValue, searchInDomain: searchInDomain) { $0 }
    }
}

public func envBoolValue(_ key: String, default defaultValue: Bool = false, searchInDomain: Bool = true) -> Bool {
    EnvManager.shared.envBoolValue(rawKey: key, default: defaultValue, searchInDomain: searchInDomain)!
}

public func envIntValue(_ key: String, default defaultValue: Int = 0, searchInDomain: Bool = true) -> Int {
    EnvManager.shared.envIntValue(rawKey: key, default: defaultValue, searchInDomain: searchInDomain)!
}

public func envStringValue(_ key: String, default defaultValue: String, searchInDomain: Bool = true) -> String {
    EnvManager.shared.envStringValue(rawKey: key, default: defaultValue, searchInDomain: searchInDomain)!
}

public func envStringValue(_ key: String, searchInDomain: Bool = true) -> String? {
    EnvManager.shared.envStringValue(rawKey: key, searchInDomain: searchInDomain)
}

EnvManager.shared.register(domain: "OpenSwiftUI")

// MARK: - Constants

let lookInsideServerEnvKey = "OPENSWIFTUI_EXAMPLE_LOOKINSIDE_SERVER"
let lookInServerEnvKey = "OPENSWIFTUI_EXAMPLE_LOOKIN_SERVER"

let enableLookInsideServer = envBoolValue("EXAMPLE_LOOKINSIDE_SERVER", default: true)
let enableLookInServer = envBoolValue("EXAMPLE_LOOKIN_SERVER", default: false)

if enableLookInsideServer && enableLookInServer {
    fatalError("\(lookInsideServerEnvKey) and \(lookInServerEnvKey) cannot both be enabled")
}

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

let debugServerReleaseExclusionSettings: SettingsDictionary = (enableLookInsideServer || enableLookInServer)
    ? [
        "EXCLUDED_SOURCE_FILE_NAMES": "$(inherited) LookInsideServer* LookinServer*",
    ]
    : [:]

func targetConfigurations(_ xcconfig: Path) -> [Configuration] {
    [
        .debug(name: swiftUIDebug, settings: swiftUIModeSettings.merging(debugModeSettings), xcconfig: xcconfig),
        .release(name: swiftUIRelease, settings: swiftUIModeSettings.merging(debugServerReleaseExclusionSettings), xcconfig: xcconfig),
        .debug(name: openSwiftUIDebug, settings: openSwiftUIDebugModeSettings, xcconfig: xcconfig),
        .release(name: openSwiftUIRelease, settings: openSwiftUIModeSettings.merging(debugServerReleaseExclusionSettings), xcconfig: xcconfig),
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

let debugServerDependencies: [TargetDependency]
if enableLookInsideServer {
    debugServerDependencies = [
        .external(name: "LookInsideServer", condition: .when([.ios, .macos])),
    ]
} else if enableLookInServer {
    debugServerDependencies = [
        .external(name: "LookinServer", condition: .when([.ios])),
    ]
} else {
    debugServerDependencies = []
}

let appDependencies: [TargetDependency] = [
    .external(name: "OpenSwiftUI"),
    .external(name: "Equatable"),
] + privateFrameworkDependencies + debugServerDependencies

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
