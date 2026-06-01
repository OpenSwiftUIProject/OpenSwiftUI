import ProjectDescription

let appName = "StdoutRendererDemo"

let debugBuildSettings: SettingsDictionary = [
    "ALWAYS_SEARCH_USER_PATHS": "NO",
    "GCC_OPTIMIZATION_LEVEL": "0",
    "ONLY_ACTIVE_ARCH": "YES",
    "SWIFT_COMPILATION_MODE": "singlefile",
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
]

let releaseBuildSettings: SettingsDictionary = [
    "SWIFT_COMPILATION_MODE": "wholemodule",
    "SWIFT_OPTIMIZATION_LEVEL": "-O",
]

let appSettings: SettingsDictionary = [
    "CODE_SIGN_STYLE": "Automatic",
    "DEVELOPMENT_TEAM": "",
    "ENABLE_HARDENED_RUNTIME": "YES",
    "FRAMEWORK_SEARCH_PATHS": [
        "$(inherited)",
        "$(BUILD_DIR)/Debug$(EFFECTIVE_PLATFORM_NAME)",
        "$(BUILD_DIR)/Release$(EFFECTIVE_PLATFORM_NAME)",
    ],
    "GENERATE_INFOPLIST_FILE": "YES",
    "LD_RUNPATH_SEARCH_PATHS": [
        "$(inherited)",
        "@executable_path/../Frameworks",
    ],
    "LIBRARY_SEARCH_PATHS": [
        "$(inherited)",
        "$(BUILD_DIR)/Debug$(EFFECTIVE_PLATFORM_NAME)",
        "$(BUILD_DIR)/Release$(EFFECTIVE_PLATFORM_NAME)",
    ],
    "PRODUCT_BUNDLE_IDENTIFIER": "org.OpenSwiftUIProject.OpenSwiftUI.StdoutRendererDemo",
    "SWIFT_VERSION": "5.0",
]

let privateFrameworkDependencies: [TargetDependency] = [
    .external(name: "AttributeGraph"),
    .external(name: "RenderBox"),
    .external(name: "CoreUI"),
    .external(name: "CoreSVG"),
    .external(name: "SFSymbols"),
]

let target = Target.target(
    name: appName,
    destinations: [.mac],
    product: .app,
    bundleId: "org.OpenSwiftUIProject.OpenSwiftUI.StdoutRendererDemo",
    deploymentTargets: .macOS("15.0"),
    infoPlist: .extendingDefault(with: [:]),
    sources: [
        "ExampleApp/**/*.swift",
    ],
    dependencies: [
        .external(name: "OpenSwiftUI"),
    ] + privateFrameworkDependencies,
    settings: .settings(
        base: appSettings,
        configurations: [
            .debug(name: "Debug", settings: debugBuildSettings),
            .release(name: "Release", settings: releaseBuildSettings),
        ],
        defaultSettings: .none
    )
)

let scheme = Scheme.scheme(
    name: appName,
    shared: true,
    buildAction: .buildAction(targets: [.target(appName)]),
    runAction: .runAction(
        configuration: "Debug",
        executable: .executable(.target(appName))
    ),
    archiveAction: .archiveAction(configuration: "Release"),
    profileAction: .profileAction(
        configuration: "Release",
        executable: .executable(.target(appName))
    ),
    analyzeAction: .analyzeAction(configuration: "Debug")
)

let project = Project(
    name: "StdoutRenderer",
    options: .options(
        automaticSchemesOptions: .disabled,
        developmentRegion: "en"
    ),
    settings: .settings(
        configurations: [
            .debug(name: "Debug", settings: debugBuildSettings),
            .release(name: "Release", settings: releaseBuildSettings),
        ],
        defaultSettings: .none,
        defaultConfiguration: "Debug"
    ),
    targets: [
        target,
    ],
    schemes: [
        scheme,
    ],
    additionalFiles: [
        "README.md",
        "Package.swift",
        "run-example.sh",
    ]
)
