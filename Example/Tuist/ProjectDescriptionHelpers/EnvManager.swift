import Foundation

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

public func configureOpenSwiftUIEnvironment(provider: EnvironmentProvider? = nil) {
    EnvManager.shared.reset()
    if let provider {
        EnvManager.shared.setEnvironmentProvider(provider)
    }
    EnvManager.shared.register(domain: "OpenSwiftUI")
}

public struct OpenSwiftUIExampleServerConfiguration {
    public static let lookInsideServerEnvKey = "OPENSWIFTUI_EXAMPLE_LOOKINSIDE_SERVER"
    public static let lookInServerEnvKey = "OPENSWIFTUI_EXAMPLE_LOOKIN_SERVER"

    public let enableLookInsideServer: Bool
    public let enableLookInServer: Bool

    public static func resolve() -> OpenSwiftUIExampleServerConfiguration {
        let enableLookInsideServer = envBoolValue("EXAMPLE_LOOKINSIDE_SERVER", default: false)
        let enableLookInServer = envBoolValue("EXAMPLE_LOOKIN_SERVER", default: false)
        if enableLookInsideServer && enableLookInServer {
            fatalError("\(lookInsideServerEnvKey) and \(lookInServerEnvKey) cannot both be enabled")
        }
        return OpenSwiftUIExampleServerConfiguration(
            enableLookInsideServer: enableLookInsideServer,
            enableLookInServer: enableLookInServer
        )
    }
}
