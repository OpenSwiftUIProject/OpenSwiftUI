// swift-tools-version: 6.1

import PackageDescription

// MARK: - EnvManager

public protocol EnvironmentProvider {
    func value(forKey key: String) -> String?
}

public struct PackageContextEnvironmentProvider: EnvironmentProvider {
    public init() {}

    public func value(forKey key: String) -> String? {
        Context.environment[key]
    }
}

public final class EnvManager {
    nonisolated(unsafe) public static let shared = EnvManager()

    private var domains: [String] = []
    private var environmentProvider: EnvironmentProvider

    /// When true, append raw key as fallback when searching in domains
    public var includeFallbackToRawKey: Bool = false

    private init() {
        self.environmentProvider = PackageContextEnvironmentProvider()
    }

    /// Set a custom environment provider (useful for testing)
    public func setEnvironmentProvider(_ provider: EnvironmentProvider) {
        self.environmentProvider = provider
    }

    /// Reset domains and environment provider (useful for testing)
    public func reset() {
        domains.removeAll()
        includeFallbackToRawKey = false
        self.environmentProvider = PackageContextEnvironmentProvider()
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

let lookInsideServerEnvKey = "OPENSWIFTUI_EXAMPLE_LOOKINSIDE_SERVER"
let lookInServerEnvKey = "OPENSWIFTUI_EXAMPLE_LOOKIN_SERVER"

let enableLookInsideServer = envBoolValue("EXAMPLE_LOOKINSIDE_SERVER", default: true)
let enableLookInServer = envBoolValue("EXAMPLE_LOOKIN_SERVER", default: false)

if enableLookInsideServer && enableLookInServer {
    fatalError("\(lookInsideServerEnvKey) and \(lookInServerEnvKey) cannot both be enabled")
}

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
    .package(url: "https://github.com/OpenSwiftUIProject/swift-snapshot-testing", exact: "1.18.9-osui"),
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
