//
//  RedactionReasons.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 18671928047E57F039DC339288B6FAFB (SwiftUICore)

// MARK: - EnvironmentValues + RedactionReasons

// TODO
private struct ShouldRedactContentKey: DerivedEnvironmentKey {
    static func value(in environment: EnvironmentValues) -> Bool {
        // redaction
        false
    }
}

extension EnvironmentValues {
    package var shouldRedactContent: Bool {
        self[ShouldRedactContentKey.self]
    }
}
