//
//  SensitiveContent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7799685610985DBA9248562F2E4D5E6E (SwiftUICore?)

private struct SensitiveContentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    package var sensitiveContent: Bool {
        get { self[SensitiveContentKey.self] }
        set { self[SensitiveContentKey.self] = newValue }
    }
}
