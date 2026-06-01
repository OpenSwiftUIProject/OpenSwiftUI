import ProjectDescription

let appName = "StdoutRendererDemo"

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
            .debug(name: "Debug"),
            .release(name: "Release"),
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
            .debug(name: "Debug"),
            .release(name: "Release"),
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
